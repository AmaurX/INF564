(** Typage du code source *)

exception Error of string

val program: debug:bool -> Ptree.file -> Ttree.file

(* val type_block: Ptree.block -> Ttree.block *)
