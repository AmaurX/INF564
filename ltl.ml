open Ltltree
open Ops
open Register
open Format
exception Error of string

type color_graph_m = {mutable map : Ltltree.arcs Register.map;}
type color = Ltltree.operand
type coloring = color Register.map

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

let print ig =
  Register.M.iter (fun r arcs ->
      Format.printf "%s: prefs=@[%a@] intfs=@[%a@]@." (r :> string)
        Register.print_set arcs.prefs Register.print_set arcs.intfs) ig


(**
    This part is coloring the graph    
*)

type todo_set_m = {mutable set : Register.set}

(*WRONG ! TO DO*)
let find_best_coloring todo potential_colors interference_graph =
  let iter_best_coloring register potential_color found_one = 0
  in
  (false, Register.result) 


let remove_color potential_colors_hashtbl colored_register chosen_color interference_graph = 
  let arcs_from_register = Register.M.find colored_register interference_graph in
  let rec remove_color_rec interfered_registers  =
    if not (Register.S.is_empty interfered_registers) 
    then
      begin
        let reg = Register.S.choose interfered_registers in
        if not (Register.S.mem reg Register.allocatable) 
        then 
          begin
            let new_interfered_registers = Register.S.remove reg interfered_registers in
            let old_potential_colors = Hashtbl.find potential_colors_hashtbl reg  in
            let new_potential_colors = Register.S.remove chosen_color old_potential_colors in 
            Hashtbl.replace potential_colors_hashtbl reg new_potential_colors ;
            remove_color_rec new_interfered_registers 
          end
        else
          begin
            let new_interfered_registers = Register.S.remove reg interfered_registers in
            remove_color_rec new_interfered_registers  
          end
      end
  in
  remove_color_rec arcs_from_register.intfs

let rec color_one interference_graph todo potential_colors_hashtbl color_map number_of_spill =
  if not (Register.S.is_empty todo) then 
    begin
      let (coloring_is_possible, register_to_color) = find_best_coloring todo potential_colors_hashtbl interference_graph in
      if coloring_is_possible then
        begin
          let new_color = Register.S.choose (Hashtbl.find potential_colors_hashtbl register_to_color ) in
          let new_color_map = Register.M.add register_to_color (Ltltree.Reg new_color) in
          let new_todo = Register.S.remove register_to_color todo in
          remove_color potential_colors_hashtbl register_to_color new_color interference_graph;
          color_one interference_graph todo potential_colors_hashtbl color_map number_of_spill
        end
      else 
        begin
          (color_map, number_of_spill) (*WRONG!!!* TO DO : SPILL!*)
        end
    end
  else
    begin
      (color_map, number_of_spill)
    end


let color interference_graph = 
  let todo = {set = Register.S.empty} in
  let fill_todo register arcs =
    if not (Register.S.mem register Register.allocatable) then
    todo.set <- Register.S.add register todo.set
  in
  Register.M.iter fill_todo interference_graph;
  let potential_colors_hashtbl = Hashtbl.create 16 
  in
  let fill_potential_colors_hashtbl register arcs = 
    let potential_colors = Register.S.diff Register.allocatable arcs.intfs
    in Hashtbl.add potential_colors_hashtbl register potential_colors 
  in
  Register.M.iter fill_potential_colors_hashtbl interference_graph;
  let empty_color_map = Register.M.empty in
  let zero = 0 in
  color_one interference_graph todo.set potential_colors_hashtbl empty_color_map zero




(**
    This part is creating the graph    
*)
let add_friends reg1 reg2 interference_graph =
  if Register.M.mem reg1 interference_graph.map 
  then let arcR1 = Register.M.find reg1 interference_graph.map in
  arcR1.prefs <- Register.S.add reg2 arcR1.prefs;
  else let prefs = Register.S.singleton reg2 in
  let newarcR1 = {prefs = prefs; intfs = Register.S.empty} in
  interference_graph.map <- Register.M.add reg1 newarcR1 interference_graph.map;
  
  if Register.M.mem reg2 interference_graph.map 
  then let arcR2 = Register.M.find reg2 interference_graph.map in
  arcR2.prefs <- Register.S.add reg1 arcR2.prefs;
  else let prefs = Register.S.singleton reg1 in
  let newarcR2 = {prefs = prefs; intfs = Register.S.empty} in
  interference_graph.map <- Register.M.add reg2 newarcR2 interference_graph.map
   

let iter_pref label live_info interference_graph = 
  match live_info.Ertltree.instr with
  | Ertltree.Embinop (Mmov, reg1, reg2, l ) -> if reg1 <> reg2 then add_friends reg1 reg2 interference_graph 
  | _ -> ()

let add_interfs reg1 reg2 interference_graph =
  (* fprintf std_formatter "add interf %a %a @\n" Register.print reg1 Register.print reg2; *)
  if Register.M.mem reg1 interference_graph.map 
  then begin let arcR1 = Register.M.find reg1 interference_graph.map in
  arcR1.intfs <- Register.S.add reg2 arcR1.intfs;
     if Register.S.mem reg2 arcR1.prefs then arcR1.prefs <- Register.S.remove reg2 arcR1.prefs
    end
  else begin let intfs = Register.S.singleton reg2 in
  let newarcR1 = {prefs = Register.S.empty; intfs = intfs} in
  interference_graph.map <- Register.M.add reg1 newarcR1 interference_graph.map
  end ;

  if Register.M.mem reg2 interference_graph.map 
  then begin let arcR2 = Register.M.find reg2 interference_graph.map in
  arcR2.intfs <- Register.S.add reg1 arcR2.intfs;
     if Register.S.mem reg1 arcR2.prefs then arcR2.prefs <- Register.S.remove reg1 arcR2.prefs
    end
  else begin let intfs = Register.S.singleton reg1 in
  let newarcR2 = {prefs = Register.S.empty; intfs = intfs} in
  interference_graph.map <- Register.M.add reg2 newarcR2 interference_graph.map
  end

let check_outs reg_out reg_def interference_graph= 
  if reg_out <> reg_def then
  add_interfs reg_out reg_def interference_graph


let handle_interferences live_info interference_graph =
  if not (Register.S.is_empty live_info.Ertltree.defs) then
Register.S.iter (fun reg_out -> check_outs reg_out (Register.S.choose live_info.Ertltree.defs) interference_graph) live_info.Ertltree.outs


let check_outs_mov reg_friend reg_out reg_def interference_graph= 
  if reg_out <> reg_def && reg_out <> reg_friend then
  add_interfs reg_out reg_def interference_graph


let handle_interferences_mov reg_friend live_info interference_graph = 
  if not (Register.S.is_empty live_info.Ertltree.defs) then
Register.S.iter (fun reg_out -> check_outs_mov reg_friend reg_out (Register.S.choose live_info.Ertltree.defs) interference_graph) live_info.Ertltree.outs


let iter_intfs label live_info interference_graph = 
  match live_info.Ertltree.instr with
  | Ertltree.Embinop (Mmov, reg1, reg2, l ) -> if reg1 <> reg2 then handle_interferences_mov reg1 live_info interference_graph 
  | _ -> handle_interferences live_info interference_graph




let construct_interference_graph live_info_map =
  let interference_graph = {map = Register.M.empty} in
  Label.M.iter (fun label live_info -> iter_pref label live_info interference_graph) live_info_map;
  Label.M.iter (fun label live_info -> iter_intfs label live_info interference_graph) live_info_map;
  interference_graph.map 


(* ================================================
    1.3 LTL translation
*)

let ltl_i_binop colors binop reg1 reg2 lb = 
  let op1 = lookup colors reg1 in
  let op2 = lookup colors reg2 in
   
  match binop with
  | Ops.Mmov -> Embinop(Ops.Mmov, op1, op2, lb)
  | _ -> raise (Error "binop insupported")

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
  let final_interference_graph = construct_interference_graph p.Ertltree.liveness in
  print final_interference_graph;
  let colors = Register.M.empty in
  (* let funlist = ltl_funlist colors p.Ertltree.funs in *)
  {
    funs = [];
  }
