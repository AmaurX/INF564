(* open Ttree *)
open Rtltree

exception Error of string

let graph = ref Label.M.empty

let generate i =
    let l = Label.fresh () in
    graph := Label.M.add l i !graph;
    l

let rtl_expr expr locals destl dest_register= match expr.Ttree.expr_node with
  | Ttree.Econst i -> generate (Econst (i, dest_register, destl))
  | Ttree.Eaccess_local var_ident -> let var_reg = Hashtbl.find locals var_ident in generate (Embinop (Ops.Mmov, var_reg, dest_register, destl))
  | _ -> Label.fresh()
  (* | Eaccess_field of expr * field
  | Eassign_local of ident * expr
  | Eassign_field of expr * field * expr
  | Eunop of unop * expr (* fait *)
  | Ebinop of binop * expr * expr (* fait *)
  | Ecall of ident * expr list
  | Esizeof of structure *)

let rtl_stmt stmt locals destl retr exitl = 
  match stmt with 
| Ttree.Sreturn expr -> rtl_expr expr locals exitl retr
| Ttree.Sexpr expr -> let result_reg = Register.fresh() in rtl_expr expr locals destl result_reg 
  | _ -> Label.fresh()




let rec rtl_stmt_list stmtlist locals destl (result:Register.t) exit = 
  match stmtlist with
    | stmt::[] -> let stmtlabel = rtl_stmt stmt locals destl result exit in stmtlabel
    | stmt::remain -> let stmtlabel = rtl_stmt stmt locals destl result exit in rtl_stmt_list remain locals stmtlabel result exit
    | [] -> raise (Error "body vide")



let rtl_body body locals (result:Register.t) exit = 
  let (varlist, stmtlist) = body in
  let rec fill_locals = function 
    | var::remain -> Hashtbl.add locals (snd var) (Register.fresh()); fill_locals remain
    | [] -> ()
  in
  fill_locals varlist;
  let reversed_stmtlist = List.rev stmtlist in
  rtl_stmt_list reversed_stmtlist locals exit result exit


let rtl_fun fn = 
  let exit = Label.fresh() in 
  let result = Register.fresh() in
  let locals = Hashtbl.create 16 in
let entry = rtl_body fn.Ttree.fun_body locals result exit in
  {fun_name = fn.Ttree.fun_name;
    fun_formals = [];
    fun_result = result;
    fun_locals = Register.set_of_list [];
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