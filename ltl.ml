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

type todo_set_m = {mutable set : Register.set}

let find_best_coloring_preference_four todo potential_colors_map interference_graph =
  let is_of_preference_four register potential_colors = 
  if Register.S.is_empty potential_colors then false 
  else true 

  in
  
  let filtered_potential_colors_map = Register.M.filter is_of_preference_four potential_colors_map in
  
  if not (Register.M.is_empty filtered_potential_colors_map) 
  then 
    begin
      let (register_to_color, potential_colors)= Register.M.choose filtered_potential_colors_map in
      (true, register_to_color, Register.S.choose potential_colors)
    end
  else
    begin
      (false, Register.fresh(), Register.fresh())
    end


let find_best_coloring_preference_three todo potential_colors_map interference_graph = 
  let is_of_preference_three register potential_colors = 
    if Register.S.is_empty potential_colors then begin false end 
    else
      begin
        let arcs_of_reg = Register.M.find register interference_graph in
        let preference_inter_potential = Register.S.inter arcs_of_reg.prefs potential_colors in
        if Register.S.is_empty preference_inter_potential then begin false end 
        else begin true end
      end 

    in
    
    let filtered_potential_colors_map = Register.M.filter is_of_preference_three potential_colors_map in
    
    if not (Register.M.is_empty filtered_potential_colors_map) 
    then 
      begin
        let (register_to_color, potential_colors)= Register.M.choose filtered_potential_colors_map in
        let arcs_of_reg = Register.M.find register_to_color interference_graph in
        let preference_inter_potential = Register.S.inter arcs_of_reg.prefs potential_colors in
        (true, register_to_color, Register.S.choose preference_inter_potential)
      end
    else
      begin
        find_best_coloring_preference_four todo potential_colors_map interference_graph
      end
    

let find_best_coloring_preference_two todo potential_colors_map interference_graph = 
  let is_of_preference_two register potential_colors = 
  if Register.S.is_empty potential_colors || (Register.S.cardinal potential_colors) > 1 then  false 
  else true
  in
  
  let filtered_potential_colors_map = Register.M.filter is_of_preference_two potential_colors_map in
  
  if not (Register.M.is_empty filtered_potential_colors_map) 
  then 
    begin
      let (register_to_color, potential_colors)= Register.M.choose filtered_potential_colors_map in
      (true, register_to_color, Register.S.choose potential_colors)
    end
  else
    begin
      find_best_coloring_preference_three todo potential_colors_map interference_graph
    end


let find_best_coloring_preference_one todo potential_colors_map interference_graph =
  let filter_to_do register potential_colors = 
    if Register.S.mem register todo then true else false
  in
  let potential_colors_map_todo = Register.M.filter filter_to_do potential_colors_map in

  let is_of_preference_one register potential_colors = 
  if Register.S.is_empty potential_colors || (Register.S.cardinal potential_colors) > 1 then begin false end
  else 
    begin
      let only_potential_color = Register.S.choose potential_colors in
      let arcs_of_reg = Register.M.find register interference_graph in
      if Register.S.mem only_potential_color arcs_of_reg.prefs then begin true end
      else begin false end
    end 
  in
  
  let filtered_potential_colors_map = Register.M.filter is_of_preference_one potential_colors_map_todo in
  
  if not (Register.M.is_empty filtered_potential_colors_map) 
  then 
    begin
      let (register_to_color, potential_colors)= Register.M.choose filtered_potential_colors_map in
      (true, register_to_color, Register.S.choose potential_colors)
    end
  else
    begin
      find_best_coloring_preference_two todo potential_colors_map_todo interference_graph
    end


let remove_color potential_colors_map colored_register chosen_color interference_graph = 

  let arcs_from_register = Register.M.find colored_register interference_graph in
  let rec remove_color_rec interfered_registers potential_colors_map =
    if not (Register.S.is_empty interfered_registers) 
    then
      begin
        let reg = Register.S.choose interfered_registers in
        if not (Register.S.mem reg Register.allocatable) 
        then 
          begin
            (* fprintf std_formatter "hi! with reg %a  @\n" Register.print reg; *)
            let new_interfered_registers = Register.S.remove reg interfered_registers in
            let old_potential_colors = Register.M.find reg potential_colors_map in
            let new_potential_colors = Register.S.remove chosen_color old_potential_colors in 
            let new_potential_colors_map = Register.M.add  reg new_potential_colors potential_colors_map in
            remove_color_rec new_interfered_registers new_potential_colors_map
          end
        else
          begin
            let new_interfered_registers = Register.S.remove reg interfered_registers in
            remove_color_rec new_interfered_registers potential_colors_map
          end
      end
    else
      begin
        potential_colors_map
      end
  in
  remove_color_rec arcs_from_register.intfs potential_colors_map

let rec color_one interference_graph todo potential_colors_map color_map number_of_spill =
  if not (Register.S.is_empty todo) then 
    begin
      let (coloring_is_possible, register_to_color , new_color) = find_best_coloring_preference_one todo potential_colors_map interference_graph in
      if coloring_is_possible then
        begin
          (* fprintf std_formatter "Hello @\n"; *)
          fprintf std_formatter "Lets color %a with color %a @\n" Register.print register_to_color Register.print new_color;
          let new_color_map = Register.M.add register_to_color (Ltltree.Reg new_color) color_map in
          let new_todo = Register.S.remove register_to_color todo in
          (* let new_potential_colors_map_1 = Register.M.remove register_to_color potential_colors_map in *)
          let new_potential_colors_map = remove_color potential_colors_map register_to_color new_color interference_graph in
          color_one interference_graph new_todo new_potential_colors_map new_color_map number_of_spill
        end
      else 
        begin
          fprintf std_formatter "Coucou @\n";
          (color_map, number_of_spill) (*WRONG!!!* TO DO : SPILL!*)
        end
    end
  else
    begin
      (color_map, number_of_spill)
    end

type potential_colors_map_m = {mutable reg_map : Register.set Register.map}

let color interference_graph = 
  let todo = {set = Register.S.empty} in
  let fill_todo register arcs =
    if not (Register.S.mem register Register.allocatable) then
    todo.set <- Register.S.add register todo.set
  in
  Register.M.iter fill_todo interference_graph;
  let potential_colors_map = {reg_map= Register.M.empty} 
  in
  let fill_potential_colors_map register arcs = 
    let potential_colors = Register.S.diff Register.allocatable arcs.intfs
    in potential_colors_map.reg_map <- Register.M.add register potential_colors potential_colors_map.reg_map 
  in
  Register.M.iter fill_potential_colors_map interference_graph;
  let empty_color_map = Register.M.empty in
  let zero = 0 in
  color_one interference_graph todo.set potential_colors_map.reg_map empty_color_map zero




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
  | Ops.Mmov when op1 = op2 -> Egoto lb
  | Ops.Mmov when not (col_is_hw colors op1)
               && not (col_is_hw colors op2) ->
    (* use one temp register *)
    let tmp_reg = Register.tmp1 in
    let mov2_lb = generate(Embinop (Ops.Mmov, op1, Reg(tmp_reg), lb)) in
    Embinop (Ops.Mmov, Reg(tmp_reg), op2, mov2_lb)
  | Ops.Mmov -> Embinop (Ops.Mmov, op1, op2, lb)
  (* | Ops.Mmul when not (col_is_hw colors op2) -> *)
  (* second must be in hw *)
  

  | _ -> raise (Error "binop insupported")

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
  | Ertltree.Estore (srcReg, destReg, destOffset, lb) ->
    ltl_i_store colors srcReg destReg destOffset lb
  | Ertltree.Epush_param (reg, lb) -> 
    let op = lookup colors reg in
    Epush (op, lb)
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
  print_graph final_interference_graph;
  let (colors, spilledNumber) = color final_interference_graph in
  print_color_graph colors;
  fprintf std_formatter "%i" (Register.M.cardinal colors);
  (* let colors = Register.M.empty in *)
  (* let funlist = ltl_funlist colors p.Ertltree.funs in *)
  {
    funs = [];
  }
