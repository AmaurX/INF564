open Ltltree
open Ops
open Register
open Format
exception Error of string


let program p = {funs = []}