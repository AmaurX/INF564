(**
RTL to ERTL translator
*)

open Ertltree
open Ops
open Register
open Format
exception Error of string

(**
  The ERTL output graph
  *)
let graph = ref Label.M.empty

(**
  Map where all pseudo-registers lifespans are stored
  *)
let live_info_map = ref Label.M.empty

type remaining_label_m = {mutable set : Label.set;}

let generate instr =
  let l = Label.fresh () in
  graph := Label.M.add l instr !graph;
  l

  (**
  Converts function calls to ERTL

  saves caller_saved registers

  passes 6+th args with the stack frame

  @pm dest_reg dest register
  @pm fun_name function name
  @pm rList the list of registers given as args
  @pm l label of next instr after function call
  *)
let treat_ecall (dest_reg, fun_name, rList, lb) =  
  let lastLabel = if  List.length rList > 6 then generate (Emunop ( Maddi ( Int32.of_int(((List.length rList) - 6) * 8 )) , Register.rsp, l)) else lb
  in
  let labelcopy = generate (Embinop(Mmov, Register.result, dest_reg, lastLabel)) in
  let usedRegs = if List.length rList <= 6 then List.length rList else 6  in
  let labelCall = generate (Ecall (fun_name, usedRegs, labelcopy)) in
  let rec fill_recursif registerList index label=
    if index < 6 then 
      begin match registerList with 
      | reg::remain -> let newLabel = generate (Embinop (Mmov, reg, (List.nth Register.parameters index), label)) in fill_recursif remain (index+1) newLabel
      | [] -> label
      end
    else 
      begin match registerList with 
    | reg::remain -> let newLabel = generate (Epush_param (reg, label)) in fill_recursif remain (index+1) newLabel
    | [] -> label
      end
  in let secondLabel = fill_recursif rList 0 labelCall in
  
  (* let firstlabel = if  List.length rList > 6 then generate (Emunop ( Maddi (Int32.of_int( - ((List.length rList) - 6) * 8 )) , Register.rsp, secondLabel)) else secondLabel in *)
  let goto = Egoto secondLabel in goto 
    

let treat_div (binop, r1, r2, l) = 
  let label1 = generate (Embinop (Mmov, Register.rax, r2 , l)) in
  let label2 = generate (Embinop (Mdiv, r1, Register.rax, label1)) in
  Embinop (Mmov ,r2, Register.rax, label2)


let instr = function
  | Rtltree.Econst (n, r, l) -> Econst (n, r, l)
  | Rtltree.Eload (r1, n, r2, l) -> Eload (r1, n, r2, l)
  | Rtltree.Estore (r1, r2, n, l) -> Estore (r1, r2, n, l)
  | Rtltree.Emunop  (m, r, l) -> Emunop (m, r, l)
  | Rtltree.Embinop (Mdiv, r1, r2, l) -> treat_div (Mdiv, r1, r2, l)
  | Rtltree.Embinop (m, r1, r2, l) -> Embinop (m, r1, r2, l)
    (** attention au sens : [op r1 r2] représente [r2 <- r2 op r1] *)
  | Rtltree.Emubranch (m, r, l1, l2) -> Emubranch (m, r, l1, l2)
  | Rtltree.Embbranch (m, r1, r2, l1, l2) -> Embbranch (m, r1, r2, l1, l2)
    (** attention au sens : [br r1 r2] représente [r2 br r1] *)
  | Rtltree.Ecall (r, s, rlist, l) -> treat_ecall (r, s, rlist, l)
  | Rtltree.Egoto (l) -> Egoto (l)
  | _ -> raise (Error "Wrong type of instruction")

let treat_instr_label l i =
  let i = instr i in 
  graph := Label.M.add l i !graph
  


let ertl_body fun_body = Label.M.iter treat_instr_label fun_body





let livenessHashtbl = Hashtbl.create 32

let create_live_info mylabel myinstr = 
  let successeurs = Ertltree.succ myinstr in
  let defs, uses = Ertltree.def_use myinstr in
  let my_live_info = {
    instr = myinstr;
    succ = successeurs;    (* successeurs *)
    pred = Label.S.empty;       (* prédécesseurs *)
    defs = Register.set_of_list defs;    (* définitions *)
    uses = Register.set_of_list uses;    (* utilisations *)
    ins = Register.S.empty;    (* variables vivantes en entrée *)
    outs = Register.S.empty;    (* variables vivantes en sortie *)
  } in
  Hashtbl.add livenessHashtbl mylabel my_live_info

let update_pred mylabel my_live_info =

  let add_one_succ onesucc_lb = 
    if Hashtbl.mem livenessHashtbl onesucc_lb then let one_succ = Hashtbl.find livenessHashtbl onesucc_lb in
    one_succ.pred <- Label.S.add mylabel one_succ.pred
    else  fprintf std_formatter "%a isn't in livenessHatbl @\n"  Label.print onesucc_lb;

  in

  if my_live_info.succ <> [] then List.iter add_one_succ my_live_info.succ


let compute_outs live_info = 
  let add_ins_of_succ label =
    let this_succ = Hashtbl.find livenessHashtbl label in
    live_info.outs <- Register.S.union live_info.outs this_succ.ins 
  in
  List.iter add_ins_of_succ live_info.succ

let compute_ins live_info = 
  let diff = Register.S.diff live_info.outs live_info.defs in 
  live_info.ins <- Register.S.union live_info.uses diff

  
let kildall livenesstbl = 

  let remaining_labels = {set = Label.S.empty} in
  let fillSet label info = remaining_labels.set <- Label.S.add label remaining_labels.set
  in  
  Hashtbl.iter fillSet livenessHashtbl;
  while (not (Label.S.is_empty remaining_labels.set))
  do 
    let mylabel = Label.S.min_elt remaining_labels.set in
    remaining_labels.set <- Label.S.remove mylabel remaining_labels.set;
    let my_live_info = Hashtbl.find livenessHashtbl mylabel in
    let old_ins = my_live_info.ins in
    compute_outs (my_live_info);
    compute_ins (my_live_info);
    (* Maybe put my_live_info back into the hashtable i dont know... *)
    if not (Register.S.equal old_ins my_live_info.ins) 
    then remaining_labels.set <- Label.S.union my_live_info.pred remaining_labels.set;
  done



let fill_the_map label my_live_info = 
  live_info_map := Label.M.add label my_live_info !live_info_map 


let liveness instrMap = 
  (* Hashtbl.clear livenessHashtbl; *)
  Label.M.iter create_live_info instrMap;

  Hashtbl.iter update_pred livenessHashtbl;

  kildall livenessHashtbl;

  Hashtbl.iter fill_the_map livenessHashtbl;

  !live_info_map

  
(**
  RTL => ERTL fun translation
  explicitly saves callee-saved registers
  allocates a frame for eventual 6+ parameters
  expects return value into %rax

  @param fn function
  @return ERTL function definition to insert into program
*)
let ertl_fun fn = 
  ertl_body fn.Rtltree.fun_body;

  (* entrée de la fonction*)
  let rec get_args argList count label =
    if count < 6 then 
    begin match argList with 
    | reg::remain -> let newLabel = generate (Embinop (Mmov, (List.nth Register.parameters count), reg , label)) in get_args remain (count+1) newLabel
    | [] -> label
    end
  else 
    begin match argList with 
    | reg::remain -> let newLabel = generate (Eget_param ((count - 6) * 8 + 16, reg, label)) in get_args remain (count+1) newLabel
    | [] -> label
    end
  in
  let first_arg_label = get_args fn.Rtltree.fun_formals 0 fn.Rtltree.fun_entry
  in
  let savedRegisterHsh = Hashtbl.create 16 in
  let rec save_register registerList label = 
    match registerList with
    | registre::remain -> let savedRegister = Register.fresh()  
                          in Hashtbl.add savedRegisterHsh registre  savedRegister;
                          let newLabel = generate (Embinop (Mmov, registre, savedRegister, label))
                          in save_register remain newLabel
    | [] -> label 
  in
  let first_calle_saved_lb = save_register Register.callee_saved first_arg_label in
  let alloc_lb = generate (Ealloc_frame first_calle_saved_lb) 
  in
  (*Fin de l'entrée de la fonction*)

  (*Debut de la sortie de fonction*)
  (* graph := Label.M.add fn.Rtltree.fun_exit Ereturn !graph; *)
  let return_lb = generate(Ereturn)  in
  let delete_frame_lb = generate(Edelete_frame return_lb) 
  in 
  let rec restore_register registerList label = 
    match registerList with
    | registre::remain -> let savedRegister = Hashtbl.find savedRegisterHsh registre in let newLabel = generate (Embinop (Mmov, savedRegister, registre, label)) in restore_register remain newLabel
    | [] -> label
  in
  let first_restore_register_lb = restore_register Register.callee_saved delete_frame_lb in
  let result_copy = Embinop(Mmov, fn.Rtltree.fun_result, Register.result, first_restore_register_lb) in
  graph := Label.M.add fn.Rtltree.fun_exit result_copy !graph;
  (*Fin de la sortie de fonction*)
  {
  fun_name = fn.Rtltree.fun_name;
  fun_formals = List.length fn.Rtltree.fun_formals; (* nb total d'arguments *)
  fun_locals = fn.Rtltree.fun_locals;
  fun_entry = alloc_lb;
  fun_body = !graph;
  }

let rec ertl_funlist = function
| fn::remain -> ertl_fun fn :: ertl_funlist remain
| [] -> []

let program p = 
let funlist = ertl_funlist p.Rtltree.funs in 
let livenessMap = liveness !graph in
{
  funs = funlist;
  liveness = livenessMap;
}