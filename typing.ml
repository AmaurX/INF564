
(* open Ptree *)
open Ttree

(* utiliser cette exception pour signaler une erreur de typage *)
exception Error of string

let string_of_type = function
  | Tint       -> "int"
  | Tstructp x -> "struct " ^ x.str_name ^ " *"
  | Tvoidstar  -> "void*"
  | Ttypenull  -> "typenull"


let handle_type = function
| Ptree.Tint -> Tint
| _ -> Tint


let type_var (mytype , identity) = (handle_type mytype , identity.Ptree.id)


let rec type_varlist = function
 | var::endlist -> type_var var ::type_varlist endlist
 | [] -> []


let rec type_expr (myexpr: Ptree.expr) = 
  match myexpr.Ptree.expr_node with 
  | Ptree.Econst i -> {expr_node = Econst i;
                expr_typ = Tint}
  | Ptree.Eunop (myunop, myexpr) -> let treeexpr = type_expr myexpr in 
              begin match treeexpr.expr_typ with
                | Tint -> {expr_node = Eunop (myunop, treeexpr);
                expr_typ = Tint}
                | _ -> raise (Error ("Cannot use unop with type" ^ (string_of_type treeexpr.expr_typ)))
              end
  | Ptree.Ebinop (mybinop, expr1, expr2) -> let tr_expr1 = type_expr expr1 in
                                            let tr_expr2 = type_expr expr2 in 
                                            begin match (tr_expr1.expr_typ, tr_expr2.expr_typ) with
                | Tint, Tint -> {expr_node = Ebinop (mybinop, tr_expr1, tr_expr2);
                                 expr_typ = Tint}
                | _ -> raise (Error ("Cannot use binop with type" ^ (string_of_type tr_expr1.expr_typ) ^ " and " ^ (string_of_type tr_expr2.expr_typ)))
              end
| _ -> raise (Error "To be implemented")

let type_stmt mystmt = 
  match mystmt.Ptree.stmt_node with 
  | Ptree.Sreturn myexpr -> Sreturn (type_expr myexpr)
  | _ -> Sskip





let rec type_stmtlist = function
  | mystmt::endlist -> type_stmt mystmt ::type_stmtlist endlist
 | [] -> []


let type_block ((varlist ,stmtlist): Ptree.block ) : Ttree.block =
  (type_varlist varlist, type_stmtlist stmtlist)


let type_decl_fun (d: Ptree.decl_fun) = 
  { fun_typ = Tint;
    fun_name = d.Ptree.fun_name.id;
    fun_formals = [];
    fun_body = type_block d.Ptree.fun_body }

let type_decl_struct (d : Ptree.decl_struct) =
   

let rec type_decls = function
  | decl::declElse -> begin match decl with   
                      | Ptree.Dstruct d -> type_decl_struct d :: type_decls declElse
                      | Ptree.Dfun d -> type_decl_fun d :: type_decls declElse
                      end
  | []-> []

let program p = type_decls p
