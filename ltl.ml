open Ltltree
open Ops
open Register
open Format
exception Error of string

type color_graph_m = {mutable map : Ltltree.arcs Register.map;}
type color = Ltltree.operand
type coloring = color Register.map

let print ig =
  Register.M.iter (fun r arcs ->
    Format.printf "%s: prefs=@[%a@] intfs=@[%a@]@." (r :> string)
      Register.print_set arcs.prefs Register.print_set arcs.intfs) ig

(**
    This part is coloring the graph    
*)
let lets_color_the_graph interference_graph = 
  let todo = Hashtbl.create 16 in
  let fill_todo_hash register arcs = 
    let potential_colors = Register.S.diff Register.allocatable arcs.intfs
    in ()
  in
  Register.M.iter fill_todo_hash interference_graph.map




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
  fprintf std_formatter "add interf %a %a @\n" Register.print reg1 Register.print reg2;
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
  if reg_out <> reg_def & reg_out <> reg_friend then
  add_interfs reg_out reg_def interference_graph


let handle_interferences_mov reg_friend live_info interference_graph = 
  if not (Register.S.is_empty live_info.Ertltree.defs) then
Register.S.iter (fun reg_out -> check_outs_mov reg_friend reg_out (Register.S.choose live_info.Ertltree.defs) interference_graph) live_info.Ertltree.outs


let iter_intfs label live_info interference_graph = 
  match live_info.Ertltree.instr with
  | Ertltree.Embinop (Mmov, reg1, reg2, l ) -> if reg1 <> reg2 then handle_interferences_mov reg1 live_info interference_graph 
  | _ -> handle_interferences live_info interference_graph




let construct_color_graph live_info_map =
  let interference_graph = {map = Register.M.empty} in
  Label.M.iter (fun label live_info -> iter_pref label live_info interference_graph) live_info_map;
  Label.M.iter (fun label live_info -> iter_intfs label live_info interference_graph) live_info_map;
  interference_graph.map 


let program p = 
  let final_color_graph = construct_color_graph p.Ertltree.liveness in
print final_color_graph;
  {funs = []}