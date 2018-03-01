(**
   instruction are on x86-64 operation,source,destination format
   with dest = dest (operation) source
*)
(* open Ttree *)
open Rtltree

exception Error of string

let graph = ref Label.M.empty
let function_table = Hashtbl.create 16

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
let rec rtl_if expr if_stmt else_stmt locals locals_accumulate dest_lb dest_reg exit_lb =
  let test_reg = Register.fresh() in
  let if_lb   = rtl_stmt if_stmt   locals locals_accumulate dest_lb dest_reg exit_lb in
  let else_lb = rtl_stmt else_stmt locals locals_accumulate dest_lb dest_reg exit_lb in
  let test_lb = generate (Emubranch (Ops.Mjnz, test_reg, if_lb, else_lb)) in
  rtl_expr expr locals test_lb test_reg


(**
   RTL translation for while loops
   @param expr expression to evaluate as a condition
   @param stmt block executed while expression is true
   @param locals map of local fields
   @param destl Label of the next instruction (after the end of loop)
   @param dest_register Register to store the result of the expression (unused ?)
   @param exit_lb Label used in case we meet a return
*)
and rtl_while expr stmt locals locals_accumulate dest_lb dest_reg exit_lb =
  let test_reg = Register.fresh() in
  let test_lb = Label.fresh () in
  let block_lb = rtl_stmt stmt locals locals_accumulate test_lb dest_reg exit_lb in
  let test_instr = Emubranch (Ops.Mjnz, test_reg, block_lb, exit_lb) in
  graph := Label.M.add test_lb test_instr !graph;
  test_lb


(**
   RTL translation for binary operators
   @param unop the unary operator
   @param expr expression to give to the operator
   @param locals map of local fields
   @param destl Label of the next instruction
   @param dest_register Register to store the result of the expression
   @param exit_lb Label used in case we meet a return
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
  let translate_simple_binop binop = match binop with
    (* | Ptree.Beq-> Ops. *)
    | Ptree.Badd -> Ops.Madd
    | Ptree.Bdiv -> Ops.Mdiv
    | Ptree.Bsub -> Ops.Msub
    | Ptree.Bmul -> Ops.Mmul
    | Ptree.Bge -> Ops.Msetge
    | Ptree.Bgt -> Ops.Msetg
    | Ptree.Ble -> Ops.Msetle
    | Ptree.Blt -> Ops.Msetl
    | Ptree.Beq -> Ops.Msete
    | Ptree.Bneq -> Ops.Msetne
    | _ -> raise (Error ("non-simple binop given to translate_simple_binop"))
  in

  match binop with
  (* simple arithmetical  and ordering binops *)
  | (Ptree.Badd | Ptree.Bdiv | Ptree.Bmul | Ptree.Bsub)
  | (Ptree.Beq | Ptree.Bneq | Ptree.Bge | Ptree.Bgt | Ptree.Ble | Ptree.Blt) ->
    let conv_binop = translate_simple_binop binop in
    let reg_e1 = Register.fresh() in
    (* let reg_e2 = Register.fresh() in  fait *)
    let next_instr = generate (Embinop (conv_binop, reg_e1, dest_register, destl)) in
    let lb_e2 = rtl_expr e2 locals next_instr dest_register in
    rtl_expr e1 locals lb_e2 reg_e1
  | (Ptree.Band) ->
    let reg_e1 = Register.fresh () in
    let reg_e2 = Register.fresh () in
    (* return e2 *)
    let copy_e2_lb = generate (Embinop (Ops.Mmov, reg_e2, dest_register, destl)) in
    (* e2 = (e2 != 0) *)
    let test_e2_lb = generate (Emunop (Ops.Msetnei (Int32.zero), reg_e2, copy_e2_lb)) in
    (* if e1 true, compute e2 *)
    let calc_e2_lb = rtl_expr e2 locals test_e2_lb reg_e2 in
    (* if e1 false, return 0 *)
    let retFalse_lb = generate (Econst (Int32.zero, dest_register, destl)) in
    (* test (e1!=0) and jump *)
    let test_e1_lb = generate (Emubranch (Ops.Mjnz, reg_e1, calc_e2_lb, retFalse_lb)) in
    (* compute e1 *)
    let calc_e1_lb = rtl_expr e1 locals test_e1_lb reg_e1 in
    calc_e1_lb
  | (Ptree.Bor) ->
    let reg_e1 = Register.fresh () in
    let reg_e2 = Register.fresh () in
    (* return e2 *)
    let copy_e2_lb = generate (Embinop (Ops.Mmov, reg_e2, dest_register, destl)) in
    (* e2 = (e2 != 0) *)
    let test_e2_lb = generate (Emunop (Ops.Msetnei (Int32.zero), reg_e2, copy_e2_lb)) in
    (* if e1 false, compute e2 *)
    let calc_e2_lb = rtl_expr e2 locals test_e2_lb reg_e2 in
    (* if e1 true, return 1 *)
    let retFalse_lb = generate (Econst (Int32.one, dest_register, destl)) in
    (* test (e1==0) and jump *)
    let test_e1_lb = generate (Emubranch (Ops.Mjz, reg_e1, calc_e2_lb, retFalse_lb)) in
    (* compute e1 *)
    let calc_e1_lb = rtl_expr e1 locals test_e1_lb reg_e1 in
    calc_e1_lb
  (* | _ -> raise( Error "binop not supported") *)

(**
   Calls a function
   @param fun_ident name of called function
   @param expr_arglist list of expressions given as arguments
   @param destl next instruction
   @param dest_register return register
*)
and rtl_funcall fun_ident expr_arglist locals destl dest_register = 
  (**
     Compute and store each argument into the appropriate register
     @param expr_list arguments
     @param formal_reglist register
     @finalDest_lb where to give control after all caluclations
  *)
  let rec create_reglist n = 
    if n==0 then []
    else Register.fresh() :: create_reglist (n-1)
  in
  let rec parse_formals expr_list formal_reglist finalDest_lb = match expr_list, formal_reglist with
    | expr::expRemain, form::formRemain -> 
      let next_lb = parse_formals expRemain formRemain finalDest_lb in
      rtl_expr expr locals next_lb form
    | [],[] -> finalDest_lb
    | _,_ -> raise (Error "invalid arg length in function call")
  in
  let get_fun_infos fun_ident = match fun_ident with
    | "putchar" -> ("putchar", 1)
    | "sbrk" -> ("sbrk", 1)
    | name when Hashtbl.mem function_table name -> 
      let fun_descr = Hashtbl.find function_table name in
      (name, List.length fun_descr.fun_formals)
    | _ -> raise (Error ("RTL : undefined function "^fun_ident))
  in
  let (f_name, f_argLength) = get_fun_infos fun_ident in
  let arg_reglist = create_reglist f_argLength in
  let fun_lb = generate (Ecall (dest_register, fun_ident, arg_reglist, destl)) in
  let start_lb = parse_formals expr_arglist arg_reglist fun_lb in
  start_lb


(**
   RTL translation of a generic expression
   a call to rtl expr is expected to generate all needed instructions -> no need to 'generate (rtl_expr ...)'
   @param binop binay opeator
   @param expr expression to translate
   @param locals map of local fields
   @param destl Label of the next instruction
   @param dest_register Register to store the result of the expression
*)
and rtl_expr expr locals destl dest_register= match expr.Ttree.expr_node with
  | Ttree.Econst i -> generate (Econst (i, dest_register, destl))
  | Ttree.Ebinop (binop, e1, e2) ->  rtl_binop binop e1 e2 locals destl dest_register
  | Ttree.Eunop (unop, expr) ->  rtl_unop unop expr locals destl dest_register
  | Ttree.Eaccess_local var_ident ->
    begin try
        let var_reg = Hashtbl.find locals var_ident in
        generate (Embinop (Ops.Mmov, var_reg, dest_register, destl))
      with 
      |Not_found -> raise (Error ("Variable not found " ^ var_ident))
    end
  (* | Eassign_local of ident * expr *)
  | Ttree.Eassign_local (var_ident, myexpr) -> 
    begin try
        let var_reg = Hashtbl.find locals var_ident in
        let calc_reg = Register.fresh() in
        let sideAssign_lb = generate (Embinop (Ops.Mmov, calc_reg, dest_register, destl)) in
        let assign_lb = generate (Embinop (Ops.Mmov, calc_reg, var_reg, sideAssign_lb)) in
        rtl_expr myexpr locals assign_lb calc_reg
      with 
      |Not_found -> raise (Error ("Variable not found " ^ var_ident))
    end
  (* | Ecall of ident * expr list *)
  | Ttree.Ecall (fun_ident, expr_list) -> rtl_funcall fun_ident expr_list locals destl dest_register
  (* | Esizeof of structure *) 
  | Ttree.Esizeof (structure) -> generate (Econst ((Int32.of_int structure.Ttree.str_totalSize), dest_register, destl))
  (* | Eaccess_field of expr * field *)
  | Ttree.Eaccess_field (structExpr, field) -> 
    let offset = field.Ttree.field_pos in
    let calc_reg = Register.fresh () in
    let access_lb = generate (Eload (calc_reg, offset, dest_register, destl)) in
    let calc_lb = rtl_expr structExpr locals access_lb calc_reg in
    calc_lb
  (* | Eassign_field of expr * field * expr *)
  | Ttree.Eassign_field (structExpr, field, assignExpr) ->
    let offset = field.Ttree.field_pos in
    let struct_reg = Register.fresh () in
    let assign_reg = Register.fresh () in
    (* copy assigned value as return value *)
    let return_lb = generate (Embinop (Ops.Mmov, assign_reg, dest_register, destl)) in
    (* assign value to field *)
    let access_lb = generate (Estore (assign_reg, struct_reg, offset, return_lb)) in
    (* compute struct pointer *)
    let calcStruct_lb = rtl_expr structExpr locals access_lb struct_reg in
    (* compute assigned expression *)
    let calcAssign_lb = rtl_expr assignExpr locals calcStruct_lb assign_reg in
    calcAssign_lb
(* | _ -> raise (Error "expression not supported") *)


(** 
   translation of  a stmt
   @param stmt the statement
   @param locals map of accessibles locals
   @param locals_accumulate not modified
   @param dest_lb label of next instruction
   @param return_reg register for result
   @param exit_lb used for return instruction - to leave function body
*)
and rtl_stmt stmt locals locals_accumulate dest_lb return_reg exit_lb =
  match stmt with
  (* decided to explicitly force a move *)
  (* | Ttree.Sreturn expr -> rtl_expr expr locals exit_lb return_reg *)
  | Ttree.Sreturn expr -> 
    let result_reg = Register.fresh () in
    let ret_lb = generate (Embinop (Ops.Mmov, result_reg, return_reg, exit_lb)) in
    rtl_expr expr locals ret_lb result_reg
  | Ttree.Sexpr expr -> 
    let result_reg = Register.fresh() in rtl_expr expr locals dest_lb result_reg
  | Ttree.Sif (expr, if_stmt, else_stmt) -> 
    rtl_if expr if_stmt else_stmt locals locals_accumulate dest_lb return_reg exit_lb
  | Ttree.Sskip -> 
    generate (Egoto dest_lb)
  | Ttree.Sblock block -> 
    rtl_body block locals locals_accumulate dest_lb return_reg exit_lb
  | Ttree.Swhile (expr, stmt) -> 
    rtl_while expr stmt locals locals_accumulate dest_lb return_reg exit_lb
(* | _ -> raise (Error "statement not supported") *)



and rtl_stmt_list stmtlist locals locals_accumulate destl (result:Register.t) exit_lb =
  match stmtlist with
  | stmt::[] -> let stmtlabel = rtl_stmt stmt locals locals_accumulate destl result exit_lb in stmtlabel
  | stmt::remain -> let stmtlabel = rtl_stmt stmt locals locals_accumulate destl result exit_lb in rtl_stmt_list remain locals locals_accumulate stmtlabel result exit_lb
  | [] -> raise (Error "body vide")

(**
   Block translation
   @param body block to translate
   @param locals map of internal variables (empty if main block of function)
   @param locals_accumulate the same, except it doesn't get cleaned up after block translation -> used for later
   @param dest_lb where to go after the last instruction of the block
   @param result register where to store result values (for returns)
   @param exit_lb in case of return where to go
*)
and rtl_body body locals locals_accumulate dest_lb (result:Register.t) exit_lb =
  let (varlist, stmtlist) = body in
  let rec fill_locals = function
    | var::remain ->
      let reg = Register.fresh () in
      Hashtbl.add locals (snd var) (reg);
      Hashtbl.add locals_accumulate (snd var) (reg);
      fill_locals remain
    | [] -> ()
  in
  let rec unfill_locals = function
    | var::remain -> Hashtbl.remove locals (snd var); unfill_locals remain
    | [] -> ()
  in
  fill_locals varlist;
  let reversed_stmtlist = List.rev stmtlist in
  let body_lb = rtl_stmt_list reversed_stmtlist locals locals_accumulate dest_lb result exit_lb in
  unfill_locals varlist;
  body_lb

let rtl_fun fn =
  let extract_values table =
    Hashtbl.fold (fun key value val_list -> val_list@[value]) table []
  in
  let add_formal locals locals2 (var_t, var_ident) = 
    let reg = Register.fresh() in
    Hashtbl.add locals var_ident reg;
    Hashtbl.add locals2 var_ident reg;
    reg
  in
  let exit = Label.fresh() in
  let result = Register.fresh() in
  let locals = Hashtbl.create 16 in
  let locals_accumulate = Hashtbl.create 16 in
  let formals_reg = List.map (add_formal locals locals_accumulate) fn.Ttree.fun_formals in
  (* create partial entry to allow recursive calls *)
  let partial_fun_descr = 
    {fun_name = fn.Ttree.fun_name;
     fun_formals = formals_reg;
     fun_result = result;
     fun_locals = Register.set_of_list ([]);
     fun_entry = Label.fresh();
     fun_exit = exit;
     fun_body = !graph ;} in
  Hashtbl.add function_table partial_fun_descr.fun_name partial_fun_descr;

  (* translate body *)
  let entry = rtl_body fn.Ttree.fun_body locals locals_accumulate exit result exit in

  (* final entry *)
  let fun_descr = 
    {fun_name = fn.Ttree.fun_name;
     fun_formals = formals_reg;
     fun_result = result;
     (* new *)
     fun_locals = Register.set_of_list (extract_values locals_accumulate);
     (* new *)
     fun_entry = entry;
     fun_exit = exit;
     fun_body = !graph ;}
  in 
  Hashtbl.replace function_table fun_descr.fun_name fun_descr;
  fun_descr


let rec rtl_funlist fun_list = 
  List.map (fun fn -> rtl_fun fn) fun_list
(* | fn::remain -> rtl_fun fn :: rtl_funlist remain *)
(* | [] -> [] *)

let program p =
  {
    funs = rtl_funlist p
  }