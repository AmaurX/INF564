(** ERTL to LTL translator *)

open Ltltree
open Ops
open Register
open Format
open Coloring
open Interference
exception Error of string



type color = Ltltree.operand
type coloring = color Register.map

let graph = ref Label.M.empty

(**
   Adds instruction to graph
   @param i instruction
*)
let generate i =
  let l = Label.fresh () in
  graph := Label.M.add l i !graph;
  l

(**
   Colors a register name 
   @param c color Map
   @param r registre
   @return hw register name or stack position
*)
let lookup c r =
  if Register.is_hw r then Reg r else M.find r c

(**
   True of register is colored as a real hardware register
   false if spilled

*)
let col_is_hw colors operand =
  match operand with
  | Reg (reg) -> true
  | Spilled (i) -> false

let print_graph ig =
  Register.M.iter (fun r arcs ->
      Format.printf "%s: prefs=@[%a@] intfs=@[%a@]@." (r :> string)
        Register.print_set arcs.prefs Register.print_set arcs.intfs) ig

let print_color fmt = function
  | Reg hr    -> fprintf fmt "%a" Register.print hr
  | Spilled n -> fprintf fmt "stack %d" n

let print_color_graph cm =
  Register.M.iter
    (fun r cr -> printf "%a -> %a@\n" Register.print r print_color cr) cm
(**
    This part is coloring the graph    
*)






(* ================================================
    1.3 LTL translation
*)

(**
   Converts a binop to its LTL equivalent
   @param colors the color map
   @param binop given binop
   @param reg1 first reg
   @param reg2 second & destination reg
   @param lb next label
*)
let ltl_i_binop colors binop reg1 reg2 lb = 
  let op1 = lookup colors reg1 in
  let op2 = lookup colors reg2 in

  match binop with
  | Mmov when op1 = op2 -> Egoto lb
  | Mmov when not (col_is_hw colors op1)
           && not (col_is_hw colors op2) ->
    (* use one temp register *)
    let tmp_reg = Register.tmp1 in
    let mov2_lb = generate(Embinop (Mmov, Reg(tmp_reg), op2, lb)) in
    Embinop (Mmov, op1 , Reg(tmp_reg), mov2_lb)
  | Mmov -> Embinop (Mmov, op1, op2, lb)
  | Mmul when not (col_is_hw colors op2) ->
    let tmp_reg = Register.tmp1 in
    let last_move_lb = generate (Embinop (Mmov, Reg(tmp_reg), op2, lb)) in
    let mult_lb = generate (Embinop (Mmul, op1, Reg(tmp_reg), last_move_lb)) in
    Embinop (Mmov, op2,  Reg(tmp_reg) , mult_lb)
  | _ when not (col_is_hw colors op1)
        && not (col_is_hw colors op2) ->
    let tmp_reg = Register.tmp1 in
    let last_move_lb = generate (Embinop (Mmov, Reg(tmp_reg) , op2 , lb)) in
    let binop_lb = generate (Embinop (binop, op1, Reg(tmp_reg), last_move_lb)) in
    Embinop (Mmov, op2 ,Reg(tmp_reg) , binop_lb)
  | _ -> Embinop (binop, op1, op2, lb)

(**
   Converts a 'load' to its LTL equivalent
   @param colors the color map
   @param src_preg src pseudo-register
   @param srcOffset offset to src_preg
   @param dest_preg dest pseudo-register
   @param lb next label
*)
let ltl_i_load colors src_preg srcOffset dest_preg lb = 
  let dest_op = lookup colors dest_preg in
  let src_op = lookup colors src_preg in
  let post_lb, dest_reg = match dest_op with
    | Reg (r) -> lb, r
    | Spilled (i) -> 
      let destOpS = Reg (Register.tmp1) in
      let postcopy_lb = generate (Embinop (Ops.Mmov, destOpS, dest_op, lb)) in
      (postcopy_lb, Register.tmp1)
  in
  let pre_instr = match src_op with 
    | Reg (r) -> 
      let load_instr = Eload(r, srcOffset, dest_reg, post_lb) in
      load_instr
    | Spilled (i) -> 
      let tmp_reg = Register.tmp2 in
      let src_op = Reg (tmp_reg) in
      let load_lb = generate(Eload(tmp_reg, srcOffset, dest_reg, post_lb)) in
      let precopy_instr = Embinop (Ops.Mmov, src_op, src_op, load_lb) in
      precopy_instr
  in 
  pre_instr

(**
   Converts a 'store' to its LTL equivalent
   @param colors the color map
   @param src_preg src pseudo-register
   @param dest_preg dest pseudo-register
   @param destOffset offset to dest_preg
   @param lb next label
*)
let ltl_i_store colors src_preg dest_preg destOffset lb = 
  let dest_op = lookup colors dest_preg in
  let src_op = lookup colors src_preg in
  let post_lb, dest_reg = match dest_op with
    | Reg (r) -> lb, r
    | Spilled (i) -> 
      let destOpS = Reg (Register.tmp1) in
      let postcopy_lb = generate (Embinop (Ops.Mmov, destOpS, dest_op, lb)) in
      (postcopy_lb, Register.tmp1)
  in
  let pre_instr = match src_op with 
    | Reg (r) -> 
      let load_instr = Estore(r, dest_reg, destOffset, post_lb) in
      load_instr
    | Spilled (i) -> 
      let tmp_reg = Register.tmp2 in
      let src_op = Reg (tmp_reg) in
      let load_lb = generate(Estore(tmp_reg, dest_reg, destOffset, post_lb)) in
      let precopy_instr = Embinop (Ops.Mmov, src_op, src_op, load_lb) in
      precopy_instr
  in 
  pre_instr

(**
   Converts a ERTL instr to LTL
   @param colors the color map
   @param spilledNumber num of spilled registers
   @param myinstr the instruction
   @return the "not generated" first instruction of the translation
*)
let ltl_instr colors spilledNumber myinstr = match myinstr with 
  | Ertltree.Econst(n, reg, lb) -> Econst (n, lookup colors reg, lb)
  | Ertltree.Ereturn -> Ereturn
  | Ertltree.Egoto (lb)-> Egoto lb
  | Ertltree.Ecall (ident, nReg, lb) -> Ecall (ident, lb)
  | Ertltree.Emunop (unop, reg, lb) -> 
    let op = lookup colors reg in
    Emunop (unop, op, lb) 
  | Ertltree.Emubranch (branch, reg, lb1, lb2) ->
    let op = lookup colors reg in
    Emubranch (branch, op, lb1, lb2)
  | Ertltree.Embbranch (branch, reg1, reg2, lb1, lb2) ->
    let op1 = lookup colors reg1 in
    let op2 = lookup colors reg2 in
    Embbranch (branch, op1, op2, lb1, lb2)
  | Ertltree.Embinop (binop, reg1, reg2, lb) ->
    ltl_i_binop colors binop reg1 reg2 lb
  | Ertltree.Eload (srcReg, srcOffset, destReg, lb) -> 
    ltl_i_load colors srcReg srcOffset  destReg lb
  | Ertltree.Estore (srcReg, destReg, destOffset, lb) ->
    ltl_i_store colors srcReg destReg destOffset lb
  | Ertltree.Epush_param (reg, lb) -> 
    let op = lookup colors reg in
    Epush (op, lb)
  | Ertltree.Ealloc_frame (lb)->
    let last_label = if spilledNumber <> 0 then generate (Emunop(Maddi (Int32.of_int(- 8 * spilledNumber)), Reg(Register.rsp), lb)) else lb in
    let second_label = generate (Embinop(Mmov, Reg(Register.rsp), Reg(Register.rbp), last_label)) in
    Epush (Reg (Register.rbp), second_label)
  | Ertltree.Edelete_frame (lb) ->
    let label = generate (Epop (Register.rbp, lb)) in
    Embinop(Mmov, Reg(Register.rbp), Reg(Register.rsp), label)
  | Ertltree.Eget_param (n, reg, lb) -> let op = lookup colors reg in
    if not (col_is_hw colors op) then 
      let tmp_reg = Register.tmp1 in
      let last_move_lb = generate (Embinop (Mmov, Reg(tmp_reg), op, lb)) in
      Embinop (Mmov, Spilled(n) , Reg(tmp_reg), last_move_lb)
    else
      Embinop(Mmov, Spilled(n), op , lb)
  (* | _ -> raise (Error "instruction not supported") *)

(**
   Translate a ERTL instr.
   Inserts in LTL tree, at same label, the first instruction of the LTL translation
   The following are expected to be generated and properly "linked" by ltl_instr & co.
   @param colors the color map
   @param spilledNumber num of spilled registers
   @param myinstr the instruction
*)
let ltl_treat_instr_label colors spilledNumber label instr = 
  let i = ltl_instr colors spilledNumber instr in
  graph := Label.M.add label i !graph

let ltl_body colors spilledNumber body = 
  Label.M.iter (ltl_treat_instr_label colors spilledNumber) body

let ltl_fun colors spilledNumber fn = 
  let () = ltl_body colors spilledNumber fn.Ertltree.fun_body in
  {
    fun_name = fn.Ertltree.fun_name;
    fun_entry = fn.Ertltree.fun_entry;
    fun_body = !graph;
  }


let rec ltl_funlist colors spilledNumber (funlist:Ertltree.deffun list) = match funlist with 
  | fn::remain -> ltl_fun colors spilledNumber fn :: ltl_funlist colors spilledNumber remain
  | [] -> []


let program p = 
  let final_interference_graph = construct_interference_graph p.Ertltree.liveness in
  (* print_graph final_interference_graph; *)
  let (colors, spilledNumber) = color final_interference_graph in
  (* print_color_graph colors; *)
  (* fprintf std_formatter "%i" (Register.M.cardinal colors); *)
  (* let colors = Register.M.empty in *)
  let funlist = ltl_funlist colors spilledNumber p.Ertltree.funs in
  {
    funs = funlist;
  }
