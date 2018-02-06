
(* open Ptree *)
open Ttree

(* utiliser cette exception pour signaler une erreur de typage *)
exception Error of string

(* Stores type of defined structures *)
let struct_table = Hashtbl.create 16

(* Stores variables defined in the current scope *)
let env_table = Hashtbl.create 16


let init_fun_table () = 
  let fun_table = Hashtbl.create 16 in
  let ext_fn = 
    [
      {  fun_typ = Tint;
         fun_name = "putchar";
         fun_formals = [(Tint, "c")];
         fun_body = ([],[]);
      };
      {  fun_typ = Tvoidstar;
         fun_name = "setbrk";
         fun_formals = [(Tint, "n")];
         fun_body = ([],[]);
      }
    ] in 
  let add_entry entry = Hashtbl.add fun_table entry.fun_name entry in
  List.iter add_entry ext_fn;
  fun_table

let fun_table = init_fun_table ()

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

(** Checks the correct typing of a statement *)
let rec type_stmt mystmt return_type = 
  match mystmt.Ptree.stmt_node with 
  | Ptree.Sreturn myexpr -> let mytype = (type_expr myexpr).expr_typ in
    if mytype = return_type 
    then raise (Error ("Invalid return type : " ^ (string_of_type mytype) ^ " { expected :" ^ (string_of_type return_type) ^ " }"))
    else Sreturn (type_expr myexpr)
  | Ptree.Sblock block -> Sblock (type_block block return_type)
  | _ -> raise (Error "To be implemented")


and type_stmtlist = function
  | mystmt::endlist -> type_stmt mystmt ::type_stmtlist endlist
  | [] -> []

(** Typing a block 


@param block the block to type
@param forbidden_names_list names of the context variables that are forbidden (bad bad bad choice)
 *)
and type_block ((varlist, stmtlist): Ptree.block) (blockType:Ttree.typ) :Ttree.block =
  print_string "block\n";
  (* Temporary table to store block-scoped variables *)
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

(** registers a function . It should check 
    - if the name doesn't already exists
    - if given args are from an existing type
    - if given args have different names
    - if body ends returning the type fun_typ
    and fail otherwise
*)
let type_decl_fun (d: Ptree.decl_fun) = 
  (** returns a list of args after having checked that names are unique *)
  let list_arg_names formals_list fun_name = 
    let add_name nlist ((t, ident):Ptree.decl_var) = 
      let name = ident.Ptree.id in
      if List.mem name nlist 
      then raise (Error ("Argument '" ^ name ^ "' is declared more than once in" ^ fun_name));
      nlist@[name] in
    List.fold_left add_name [] d.Ptree.fun_formals in
  
  let fun_type = (handle_type d.Ptree.fun_typ) in
  let fun_name = d.Ptree.fun_name.Ptree.id in
  (* check name *)
  if Hashtbl.mem fun_table fun_name
  then raise (Error ("Function " ^ fun_name ^ " is already declared"));
  (* check args *)
  let formals_name_list = list_arg_names d.Ptree.fun_formals d.Ptree.fun_name.Ptree.id in
  (* type body - when typing body we should check that the return type matches the function definition *)
  { fun_typ = fun_type;
    fun_name = fun_name;
    fun_formals = [];
    fun_body = type_block d.Ptree.fun_body fun_type}


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
