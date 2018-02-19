(**
   instruction are on x86-64 operation,source,destination format
   with dest = dest (operation) source
*)
(* open Ttree *)
open Rtltree

exception Error of string

let graph = ref Label.M.empty

let generate i =
  let l = Label.fresh () in
  graph := Label.M.add l i !graph;
  l
(**
   RTL translation for if-else branchs
   @param expr expression to evaluate as a condition
   @param if_stmt block executed if true
   @param else_stmt block executed if false
   @param locals map of local fields
   @param destl Label of the next instruction (after the end of branched block)
   @param dest_register Register to store the result of the expression (unused ?)
*)
let rec rtl_if expr if_stmt else_stmt locals dest_lb dest_reg exit_lb =
  let test_reg = Register.fresh() in 
  let if_lb = rtl_stmt if_stmt locals dest_lb dest_reg exit_lb in 
  let else_lb = rtl_stmt else_stmt locals dest_lb dest_reg exit_lb in 
  let test_lb = generate (Emubranch (Ops.Mjnz, test_reg, if_lb, else_lb)) in
  rtl_expr expr locals test_lb test_reg
(**
   RTL translation for binary operators 
   @param unop the unary operator
   @param expr expression to give to the operator
   @param locals map of local fields
   @param destl Label of the next instruction
   @param dest_register Register to store the result of the expression
*)
and rtl_unop unop expr locals destl dest_register = 
  match unop with 
  | Ptree.Uminus -> let expr_reg = Register.fresh() in
    (* dest = zero - dest *)
    let sub_lb = generate (Embinop (Ops.Msub, expr_reg, dest_register, destl)) in
    (* zero = 0 *)
    let loadZero_lb = generate(Econst (Int32.zero, dest_register, sub_lb)) in
    (* dest = compute(expr) *)
    rtl_expr expr locals loadZero_lb expr_reg
  | Ptree.Unot -> 
    let not_lb = generate (Emunop ((Ops.Msetnei Int32.zero), dest_register, destl)) in
    rtl_expr expr locals not_lb dest_register
(**
   RTL translation for binary operators 
   @param binop binay opeator
   @param e1 first expression (left side)
   @param e2 second expression (right side)
   @param locals map of local fields
   @param destl Label of the next instruction
   @param dest_register Register to store the result of the expression
*)
and rtl_binop binop e1 e2 locals destl dest_register = 
  (* match binop with
     | (Ptree.Badd | Ptree.Bdiv | Ptree.Bdiv | Ptree.Bsub) -> *)
  let translate_arith_binop binop = match binop with
    (* | Ptree.Beq-> Ops. *)
    | Ptree.Badd -> Ops.Madd
    | Ptree.Bdiv -> Ops.Mdiv
    | Ptree.Bsub -> Ops.Msub
    | Ptree.Bmul -> Ops.Mmul
    | _ -> raise (Error ("non-arith binop given to translate_artih_binop"))
  in
  let translate_order_binop = function
    | Ptree.Bge -> Ops.Msetge
    | Ptree.Bgt -> Ops.Msetg
    | Ptree.Ble -> Ops.Msetle
    | Ptree.Blt -> Ops.Msetl
    | Ptree.Beq -> Ops.Msete
    | Ptree.Bneq -> Ops.Msetne
    | _ -> raise (Error ("non-ordering binop given to translate_order_binop"))
  in

  let conv_binop = match binop with
    (* simple arithmetical binops *)
    | (Ptree.Badd | Ptree.Bdiv | Ptree.Bmul | Ptree.Bsub) ->
      translate_arith_binop binop
    | (Ptree.Beq | Ptree.Bneq | Ptree.Bge | Ptree.Bgt | Ptree.Ble | Ptree.Blt) ->
      translate_order_binop binop
    | _ -> raise( Error "binop not supported")
  in
  let reg_e1 = Register.fresh() in 
  (* let reg_e2 = Register.fresh() in  fait *)
  let next_instr = generate (Embinop (conv_binop, reg_e1, dest_register, destl)) in
  let lb_e2 = rtl_expr e2 locals next_instr dest_register in
  rtl_expr e1 locals lb_e2 reg_e1


(** 
   RTL translation of a generic expression
   @param binop binay opeator
   @param expr expression to translate
   @param locals map of local fields
   @param destl Label of the next instruction
   @param dest_register Register to store the result of the expression
*)
and rtl_expr expr locals destl dest_register= match expr.Ttree.expr_node with
  | Ttree.Econst i -> generate (Econst (i, dest_register, destl))
  | Ttree.Eaccess_local var_ident -> let var_reg = Hashtbl.find locals var_ident in generate (Embinop (Ops.Mmov, var_reg, dest_register, destl))
  | Ttree.Ebinop (binop, e1, e2) ->  rtl_binop binop e1 e2 locals destl dest_register 
  | Ttree.Eunop (unop, expr) ->  rtl_unop unop expr locals destl dest_register
  | _ -> raise (Error "expression not supported")
(* | Eaccess_field of expr * field
   | Eassign_local of ident * expr
   | Eassign_field of expr * field * expr
   | Eunop of unop * expr (* fait *)

   | Ecall of ident * expr list
   | Esizeof of structure *)


and rtl_stmt stmt locals destl return_reg exitl = 
  match stmt with 
  | Ttree.Sreturn expr -> rtl_expr expr locals exitl return_reg
  | Ttree.Sexpr expr -> let result_reg = Register.fresh() in rtl_expr expr locals destl result_reg
  | Ttree.Sif (expr, if_stmt, else_stmt) -> rtl_if expr if_stmt else_stmt locals destl return_reg exitl
  | Ttree.Sskip -> generate (Egoto destl)
  | Ttree.Sblock block -> rtl_body block locals destl return_reg exitl
  | _ -> raise (Error "statement not supported")



and rtl_stmt_list stmtlist locals destl (result:Register.t) exit_lb = 
  match stmtlist with
  | stmt::[] -> let stmtlabel = rtl_stmt stmt locals destl result exit_lb in stmtlabel
  | stmt::remain -> let stmtlabel = rtl_stmt stmt locals destl result exit_lb in rtl_stmt_list remain locals stmtlabel result exit_lb
  | [] -> raise (Error "body vide")


and rtl_body body locals dest_lb (result:Register.t) exit_lb = 
  let (varlist, stmtlist) = body in
  let rec fill_locals = function 
    | var::remain -> Hashtbl.add locals (snd var) (Register.fresh()); fill_locals remain
    | [] -> ()
  in
  let rec unfill_locals = function 
    | var::remain -> Hashtbl.remove locals (snd var); unfill_locals remain
    | [] -> ()
  in
  fill_locals varlist;
  let reversed_stmtlist = List.rev stmtlist in
  let body_lb = rtl_stmt_list reversed_stmtlist locals exit_lb result exit_lb in
  unfill_locals varlist;
  body_lb



let rtl_fun fn = 
  let extract_values table = 
    Hashtbl.fold (fun key value val_list -> val_list@[value]) table []
  in
  let exit = Label.fresh() in 
  let result = Register.fresh() in
  let locals = Hashtbl.create 16 in
  let entry = rtl_body fn.Ttree.fun_body locals exit result exit in
  {fun_name = fn.Ttree.fun_name;
   fun_formals = [];
   fun_result = result;
   fun_locals = Register.set_of_list (extract_values locals);
   fun_entry = entry;
   fun_exit = exit;
   fun_body = !graph ;}


let rec rtl_funlist = function
  | fn::remain -> rtl_fun fn :: rtl_funlist remain
  | [] -> []



let program p = 
  {
    funs = rtl_funlist p
  }