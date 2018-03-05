open Ltltree
open Ops
open Register
open Format
exception Error of string


let graph = ref Label.M.empty

let generate i =
  let l = Label.fresh () in
  graph := Label.M.add l i !graph;
  l

(**
   Remplace un nom de registre par sa couleur (id son registre physique ou son emplacement de pile)  
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

let ltl_i_load colors src_preg srcOffset dest_preg lb = 
  let dest_op = lookup colors dest_preg in
  let src_op = lookup colors src_preg in
  let post_lb, dest_reg = match dest_op with
    | Reg (r) -> lb, r
    | _ -> 
      let destOpS = Reg (Register.tmp1) in
      let postcopy_lb = generate (Embinop (Ops.Mmov, destOpS, dest_op, lb)) in
      (postcopy_lb, Register.tmp1)
  in
  let pre_instr = match src_op with 
    | Reg (r) -> 
      let load_instr = Eload(r, srcOffset, dest_reg, post_lb) in
      load_instr
    | _ -> 
      let tmp_reg = Register.tmp2 in
      let src_op = Reg (tmp_reg) in
      let load_lb = generate(Eload(tmp_reg, srcOffset, dest_reg, post_lb)) in
      let precopy_instr = Embinop (Ops.Mmov, src_op, src_op, load_lb) in
      precopy_instr
  in 
  pre_instr
let ltl_instr colors myinstr = match myinstr with 
  | Ertltree.Econst(n, reg, lb) -> Econst (n, lookup colors reg, lb)
  | Ertltree.Ereturn -> Ereturn
  | Ertltree.Egoto (lb)-> Egoto lb
  | Ertltree.Ecall (ident, nReg, lb) -> Ecall (ident, lb)
  | Ertltree.Eload (srcReg, srcOffset, destReg, lb) -> 
    ltl_i_load colors srcReg srcOffset  destReg lb
  | _ -> raise (Error "instruction not supported")

let ltl_treat_instr_label colors label instr = 
  let i = ltl_instr colors instr in
  graph := Label.M.add label i !graph

let ltl_body colors body = 
  Label.M.iter (ltl_treat_instr_label colors) body

let ltl_fun colors fn = 
  let () = ltl_body colors fn.Ertltree.fun_body in
  {
    fun_name = fn.Ertltree.fun_name;
    fun_entry = fn.Ertltree.fun_entry;
    fun_body = !graph;
  }


let rec ltl_funlist colors (funlist:Ertltree.deffun list) = match funlist with 
  | fn::remain -> ltl_fun colors fn :: ltl_funlist colors remain
  | [] -> []

let program p = 
  let colors = Register.M.empty in
  let funlist = ltl_funlist colors p.Ertltree.funs in
  {
    funs = funlist;
  }