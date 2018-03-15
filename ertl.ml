(** RTL to ERTL translator *)

open Ertltree
open Ops
open Register
open Format
open Liveness
exception Error of string

(**
  The ERTL output graph
  *)
let graph = ref Label.M.empty




let generate instr =
  let l = Label.fresh () in
  graph := Label.M.add l instr !graph;
  l

  (**
  Converts function calls to ERTL

  saves caller_saved registers

  passes 6+th args with the stack frame

  @param dest_reg dest register
  @param fun_name function name
  @param rList the list of registers given as args
  @param l label of next instr after function call
  *)
let treat_ecall dest_reg fun_name rList lb =  
  let lastLabel = if  List.length rList > 6 then generate (Emunop ( Maddi ( Int32.of_int(((List.length rList) - 6) * 8 )) , Register.rsp, lb)) else lb
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
    
(**
  Handles the binop div
  The second register of the division must be %rax 
  
  @param r1 the first operand of the division
  @param r2 the second operand of the division, and result register
  @param l  label of next instr after the division
*)
let treat_div r1 r2 l = 
  let label1 = generate (Embinop (Mmov, Register.rax, r2 , l)) in
  let label2 = generate (Embinop (Mdiv, r1, Register.rax, label1)) in
  Embinop (Mmov ,r2, Register.rax, label2)

(**
  Translate instruction from the Rtltree to the Ertltree

  Most instructions are straight forward

  Only The division (Embinop (Mdiv, ...)) and Ecall get special treatments
  See treat_div and treat_ecall.

  @param instruction from the Rtltree
*)
let instr = function
  | Rtltree.Econst (n, r, l) -> Econst (n, r, l)
  | Rtltree.Eload (r1, n, r2, l) -> Eload (r1, n, r2, l)
  | Rtltree.Estore (r1, r2, n, l) -> Estore (r1, r2, n, l)
  | Rtltree.Emunop  (m, r, l) -> Emunop (m, r, l)
  | Rtltree.Embinop (Mdiv, r1, r2, l) -> treat_div r1 r2 l
  | Rtltree.Embinop (m, r1, r2, l) -> Embinop (m, r1, r2, l)
  | Rtltree.Emubranch (m, r, l1, l2) -> Emubranch (m, r, l1, l2)
  | Rtltree.Embbranch (m, r1, r2, l1, l2) -> Embbranch (m, r1, r2, l1, l2)
  | Rtltree.Ecall (r, s, rlist, l) -> treat_ecall r s rlist l
  | Rtltree.Egoto (l) -> Egoto (l)
  | _ -> raise (Error "Wrong type of instruction")


(**
  As the function instr might have to add intermediary steps before or after an instruction
  (in treat_div or treat_ecall), the function instr doesn't bind directly the label to the 
  instruction, but returns the first instruction to be executed, which only then is binded 
  to the corresponding label.

  @param l label of the instruction to translate
  @param i the instruction to translate
*)  
let treat_instr_label l i =
  let i = instr i in 
  graph := Label.M.add l i !graph
  

(**
  Launch the iteration to translate the body of a function

  @param fun_body the body of the function to translate
*)
let ertl_body fun_body = Label.M.iter treat_instr_label fun_body

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
  fun_formals = List.length fn.Rtltree.fun_formals;
  fun_locals = fn.Rtltree.fun_locals; (*No real use in the following steps, only in the interprets*)
  fun_entry = alloc_lb;
  fun_body = !graph;
  }

(**
  Recursily handle all functions from the Rtltree

  @param fun_list List of all the functions
*)
let rec ertl_funlist = function
| fn::remain -> ertl_fun fn :: ertl_funlist remain
| [] -> []

(**
  Main function of the class

  Calls ertl_funlist to translate the tree
  Then calls liveness on the graph
*)
let program p = 
let funlist = ertl_funlist p.Rtltree.funs in 
let livenessMap = liveness !graph in
{
  funs = funlist;
  liveness = livenessMap;
}