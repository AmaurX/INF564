open Ertltree
open Ops
exception Error of string

let graph = ref Label.M.empty

let generate i =
  let l = Label.fresh () in
  graph := Label.M.add l i !graph;
  l

let treat_ecall (r, s, rList, l) =  
  let beginLabel = if  List.length rList > 6 then generate (Emunop ( Maddi ( Int32.of_int((List.length rList - 6) * 8 )) , Register.rsp, l)) else l
  in
  let labelcopy = generate (Embinop(Mmov, Register.result, r, beginLabel)) in
  let k = if List.length rList <= 6 then List.length rList else 6  in
  let labelCall = generate (Ecall (s, k, labelcopy)) in
  let rec fill_recursif registerList index label=
    if index <= 6 then 
      begin match registerList with 
      | reg::remain -> let newLabel = generate (Embinop (Mmov, reg, (List.nth Register.parameters index), label)) in fill_recursif remain (index+1) newLabel; newLabel
      | [] -> label
      end
    else 
      begin match registerList with 
    | reg::remain -> let newLabel = generate (Epush_param (reg, label)) in fill_recursif remain (index+1) newLabel;newLabel
    | [] -> label
      end
  in let lastLabel = fill_recursif rList 0 labelCall in
  let goto = Egoto lastLabel in goto 
    

let treat_div (binop, r1, r2, l) = 
  let label1 = generate (Embinop (Mmov, Register.rax, r2 , l)) in
  let label2 = generate (Embinop (Mdiv, r1, Register.rax, label1)) (*ATTENTION FAUX!!*) in
  Embinop (Mmov ,r2, Register.rax, label2)


let instr = function
  | Rtltree.Econst (r, n, l) -> Econst (r, n, l)
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
  graph := Label.M.add l (instr i) !graph
  


let ertl_body fun_body = Label.M.iter treat_instr_label fun_body


let ertl_fun fn = 
  graph := Label.M.add fn.Rtltree.fun_exit Ereturn !graph;
  ertl_body fn.Rtltree.fun_body;
 {
  fun_name = fn.Rtltree.fun_name;
  fun_formals = List.length fn.Rtltree.fun_formals; (* nb total d'arguments *)
  fun_locals = fn.Rtltree.fun_locals;
  fun_entry = fn.Rtltree.fun_entry;
  fun_body = !graph;
}

let rec ertl_funlist = function
| fn::remain -> ertl_fun fn :: ertl_funlist remain
| [] -> []

let program p = {
  funs = ertl_funlist p.Rtltree.funs;
}
