exception Error of string

type color = Ltltree.operand
type coloring = color Register.map


(* val construct_interference_graph: Ertltree.live_info Label.map -> Ltltree.igraph  *)

(* val color: Ltltree.igraph -> coloring * int *)

val program : Ertltree.file -> Ltltree.file
