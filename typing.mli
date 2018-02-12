(** Typage du code source *)

exception Error of string

val program: Ptree.file -> Ttree.file

(* val type_block: Ptree.block -> Ttree.block *)
