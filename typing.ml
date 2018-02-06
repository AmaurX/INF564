
(* open Ptree *)
open Ttree

(* utiliser cette exception pour signaler une erreur de typage *)
exception Error of string

let struct_table = Hashtbl.create 16
let env_table = Hashtbl.create 16

let string_of_type = function
  | Tint       -> "int"
  | Tstructp x -> "struct " ^ x.str_name ^ " *"
  | Tvoidstar  -> "void*"
  | Ttypenull  -> "typenull"


(** Prints all keys of a (string, 'a) Hashtable 
@param table a (string, 'a) Hashtable
*)
let print_hashtable table = 
  print_string ("\ntable\n");
  let print_couple a b = print_string (a ^ "\n") in
  Hashtbl.iter print_couple table; ()

(** Converts Ptree.typ to Ttree.typ *)
let handle_type = function
| Ptree.Tint -> Tint
| Ptree.Tstructp id -> try let tstruct = (Hashtbl.find struct_table id.Ptree.id) in Tstructp tstruct with 
    Not_found -> raise (Error ("Struct " ^ id.Ptree.id ^ " undefined"))


let type_var (mytype , identity) = (handle_type mytype , identity.Ptree.id)


(** Sequentially types all the vars of the list *)
let rec type_varlist = function
 | var::endlist -> type_var var ::type_varlist endlist
 | [] -> []


(*  *)
let varlist_to_hashtable varlist table= 
  let typedlist = type_varlist varlist in
  (* let table = Hashtbl.create 16 in *)
  let rec inner_filler table = function
    | [] -> ()
    | (mytype, identity)::remainder -> begin
        (* print_string identity ;  *)
        if Hashtbl.mem table identity 
        then raise (Error ("Field" ^ identity ^ " is already declared"));
        Hashtbl.add table identity {field_name = identity; field_typ =  mytype};
        (* print_string ("added item\n"); *)
        
        inner_filler table remainder
    end
    in inner_filler table typedlist; ()
    (* print_hashtable table;  *)

(** Checks  the type validity of an expression 
@param myexpr an expression
*)
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

let rec type_stmt mystmt = 
  match mystmt.Ptree.stmt_node with 
  | Ptree.Sreturn myexpr -> Sreturn (type_expr myexpr)
  | Ptree.Sblock block -> Sblock (type_block block)
  | _ -> raise (Error "To be implemented")


and type_stmtlist = function
  | mystmt::endlist -> type_stmt mystmt ::type_stmtlist endlist
  | [] -> []


and type_block ((varlist ,stmtlist): Ptree.block ) : Ttree.block =
  print_string "block\n";
  let block_variable_table = Hashtbl.create 17 in
  let add_variable (vartype,name) = 
    if Hashtbl.mem block_variable_table name 
    then raise (Error ("Variable already declared in scope : " ^ name));
    Hashtbl.add block_variable_table name vartype;
    Hashtbl.add env_table name vartype
  in
  let rm_variable (vartype,name) = 
    Hashtbl.remove env_table name
  in
  let typed_varlist = type_varlist varlist in
  List.iter add_variable typed_varlist;
  let typed_stmt = type_stmtlist stmtlist in
  List.iter rm_variable typed_varlist;
  (typed_varlist, typed_stmt)


let type_decl_fun (d: Ptree.decl_fun) = 
  { fun_typ = Tint;
    fun_name = d.Ptree.fun_name.Ptree.id;
    fun_formals = [];
    fun_body = type_block d.Ptree.fun_body }


let type_decl_struct ((identity, varlist) : Ptree.decl_struct) =
  if Hashtbl.mem struct_table identity.Ptree.id 
  then raise (Error ("Struct " ^ identity.Ptree.id ^ " is already declared"));
  let myfields = Hashtbl.create 16 in
  Hashtbl.add struct_table identity.Ptree.id {str_name = identity.Ptree.id; str_fields = myfields};
  varlist_to_hashtable varlist myfields
  (* let typed_struct = {str_name = identity.Ptree.id; str_fields = myfields} in *)
  (* Hashtbl.add struct_table identity.Ptree.id typed_struct *)
                 (* typed_struct  ;  *)
    (* {str_name = "a"; str_fields = Hashtbl.create 10} *)


let rec type_decls = function
  | decl::declElse -> begin match decl with   
                      | Ptree.Dstruct d -> type_decl_struct d ; type_decls declElse
                      | Ptree.Dfun d -> type_decl_fun d :: type_decls declElse
                      end
  | []-> []

let program p = type_decls p
