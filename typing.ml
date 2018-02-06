(** 
   Type-checking module of mini-c
*)

open Printf

(* open Ptree *)
open Ttree

(* utiliser cette exception pour signaler une erreur de typage *)
exception Error of string

(* Stores type of defined structures *)
let struct_table = Hashtbl.create 16

(* Stores variables defined in the current scope *)
let env_table = ( Hashtbl.create 16 : (string, Ttree.typ) Hashtbl.t)


let init_fun_table fun_table = 
  (* let fun_table = Hashtbl.create 16 in *)
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
  List.iter add_entry ext_fn

let fun_table = (Hashtbl.create 16 : (string, decl_fun) Hashtbl.t)

let () = init_fun_table fun_table

let string_of_type = function
  | Tint       -> "int"
  | Tstructp x -> "struct " ^ x.str_name ^ " *"
  | Tvoidstar  -> "void*"
  | Ttypenull  -> "typenull"


(** Prints all keys of a Hashtable 
    @param table a (string, 'a) Hashtable
*)
let print_hashtable table = 
  print_string ("\ntable\n");
  let print_couple a b = print_string ("| " ^a ^ "\n") in
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


let rec type_lvalue = function
  | Ptree.Lident varname -> begin
      let name = varname.Ptree.id in
      (* check existence *)
      if not (Hashtbl.mem env_table name)
      then raise (Error ("Var '" ^ name ^ "' unbound in scope"));
      (* return type *)
      let var_type = Hashtbl.find env_table name in
      {
        expr_node = Eaccess_local name;
        expr_typ = var_type;
      }
    end
  | Ptree.Larrow (myexpr, field_ident) -> begin
      let field_name = field_ident.Ptree.id in
      let typed_expr = type_expr myexpr in match typed_expr.expr_typ with
      | Tstructp structure -> begin
          (* check is structure has a field of name field_name *)
          try 
            let field = Hashtbl.find structure.str_fields field_name in
            {
              expr_node = Eaccess_field (typed_expr, field);
              expr_typ = field.field_typ;
            }
          with Not_found -> raise (Error ("Field '" ^ field_name ^ "' does not exist in :" ^ string_of_type typed_expr.expr_typ));
        end
      | _ -> raise (Error ("Cannot access field " ^ field_name ^ "of a non-structure"))
      (* check field existence *)
    end


(** Checks  the type validity of an expression 
    @param myexpr an expression
*)
and type_expr (myexpr: Ptree.expr) = 
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
  | Ptree.Ecall (ident, arg_list) -> begin
      let fun_name = ident.Ptree.id in
      (* Checking existence *)
      (* print_string ("<<< calling fun '" ^ fun_name);
         print_hashtable fun_table; *)
      if not (Hashtbl.mem fun_table fun_name)
      then raise (Error ("Unbound function '" ^ fun_name ^ "'"));
      let fun_decl = Hashtbl.find fun_table fun_name in
      (* checking args number *)
      if not (0 = (List.compare_lengths fun_decl.fun_formals arg_list))
      then raise (Error ("Invalid arg number for  '" ^ fun_name ^ "'"));
      (* checking args one by one *)
      let typed_expr_list = List.map2 
          (fun call_expr decl_formal -> begin
               let (decl_typ, decl_name) = decl_formal in
               let typed_expr = type_expr call_expr in
               let expr_typ = typed_expr.expr_typ in
               if not (decl_typ = expr_typ)
               then raise (Error (sprintf "incompatible types for argument '%s' of '%s' : expected '%s', got '%s'" 
                                    decl_name fun_name (string_of_type decl_typ) (string_of_type expr_typ)));
               typed_expr
             end )
          arg_list fun_decl.fun_formals in
      (* creating the typed expr object *)
      {
        expr_node = Ecall (fun_name, typed_expr_list);
        expr_typ = fun_decl.fun_typ;
      }
    end
  | Ptree.Eright mylvalue -> type_lvalue mylvalue
  | _ -> raise (Error "To be implemented")

;;
(** Checks the correct typing of a statement
    @param mystmt statement to type
    @param return_type the only allowed type for a return stmt
*)
let rec type_stmt mystmt return_type = 
  match mystmt.Ptree.stmt_node with 
  | Ptree.Sreturn myexpr -> let mytype = (type_expr myexpr).expr_typ in
    if not (mytype = return_type )
    then raise (Error ("Invalid return type : '" ^ (string_of_type mytype) ^ "' { expected : '" ^ (string_of_type return_type) ^ "' }"))
    else Sreturn (type_expr myexpr)
  | Ptree.Sblock block -> Sblock (type_block block return_type [])
  (* | Ptree.Sexpr myexpr *)
  | _ -> raise (Error "Stmt to be implemented")


and type_stmtlist stmtlist return_type = match stmtlist with
  | mystmt::endlist -> type_stmt mystmt return_type::type_stmtlist endlist return_type
  | [] -> []

(** Typing a block 
    @param block the block to type
    @param return_type expected return type of the block
    @param fun_formals forbidden variable names (non-[] if block is the major block of a function)
*)
and type_block ((varlist, stmtlist): Ptree.block) (return_type:Ttree.typ) (fun_formals: Ptree.decl_var list):Ttree.block =
  (* print_string "-------block----------\n"; *)
  (* Temporary table to store block-scoped variables *)
  let block_variable_table = Hashtbl.create 17 in
  let add_variable (vartype,name) = 
    if Hashtbl.mem block_variable_table name 
    then raise (Error ("Variable already declared in scope : " ^ name));
    Hashtbl.add block_variable_table name vartype;
    Hashtbl.add env_table name vartype
  in
  let rm_variable (vartype,name) = 
    if not (Hashtbl.mem env_table name)
    then raise (Error "Trying to delete non-existing env variable - error in formals typechecking");
    Hashtbl.remove env_table name
  in
  let typed_formals = type_varlist fun_formals in
  let typed_varlist = type_varlist varlist in
  List.iter add_variable typed_formals;
  List.iter add_variable typed_varlist;
  print_string "variables:";
  print_hashtable env_table;
  (* print_string "funs:";
     print_hashtable fun_table; *)

  let typed_stmt = type_stmtlist stmtlist return_type in
  List.iter rm_variable typed_varlist;
  List.iter rm_variable typed_formals;
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
  let type_formals formals_list = 
    let add_formal nlist ((t, ident):Ptree.decl_var) = 
      let name = ident.Ptree.id in
      (* checks if name exists already on the list *)
      if List.exists (fun (item_t, item_name) -> item_name = name) nlist 
      then raise (Error ("Argument '" ^ name ^ "' is declared more than once in" ^ d.Ptree.fun_name.Ptree.id));
      (* add the element otherwise *)
      nlist@[(handle_type t, name)] in
    List.fold_left add_formal [] d.Ptree.fun_formals
  in
  let fun_type = (handle_type d.Ptree.fun_typ) in
  let fun_name = d.Ptree.fun_name.Ptree.id in
  (* check name *)
  if Hashtbl.mem fun_table fun_name
  then raise (Error ("Function " ^ fun_name ^ " is already declared"));
  (* adding a temporary record - to allow nested function calls*)
  let (fun_record:Ttree.decl_fun) =   { fun_typ = fun_type;
                                        fun_name = fun_name;
                                        (* check args *)
                                        fun_formals = type_formals d.Ptree.fun_formals;
                                        fun_body = [],[];} in
  Hashtbl.add fun_table fun_name fun_record;
  (* let formals_name_list = list_arg_names d.Ptree.fun_formals in *)
  (* type body - when typing body we should check that the return type matches the function definition *)
  let typed_body = type_block d.Ptree.fun_body fun_type d.Ptree.fun_formals in
  let complete_fun_record = { fun_record with
                              fun_body = typed_body
                            } in
  Hashtbl.replace fun_table fun_name complete_fun_record;
  complete_fun_record

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
      | Ptree.Dfun d -> let typed_fun = type_decl_fun d in
        typed_fun:: type_decls declElse
    end
  | []-> []

let program p = 
  let total_decl = type_decls p in
  (* Checking the presence of 'int main()' *)
  if not (List.exists (fun (d: Ttree.decl_fun) -> (d.fun_name = "main" && d.fun_typ = Tint && d.fun_formals = [])) total_decl)
  then raise (Error "missing function 'int main()'");
  total_decl
