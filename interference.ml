open Ltltree
open Ops
(**
    This part is creating the graph    
*)
let add_friends reg1 reg2 interference_map =
  if Register.M.mem reg1 interference_map.map 
  then let arcR1 = Register.M.find reg1 interference_map.map in
    arcR1.prefs <- Register.S.add reg2 arcR1.prefs;
  else let prefs = Register.S.singleton reg2 in
    let newarcR1 = {prefs = prefs; intfs = Register.S.empty} in
    interference_map.map <- Register.M.add reg1 newarcR1 interference_map.map;

    if Register.M.mem reg2 interference_map.map 
    then let arcR2 = Register.M.find reg2 interference_map.map in
      arcR2.prefs <- Register.S.add reg1 arcR2.prefs;
    else let prefs = Register.S.singleton reg1 in
      let newarcR2 = {prefs = prefs; intfs = Register.S.empty} in
      interference_map.map <- Register.M.add reg2 newarcR2 interference_map.map


let iter_pref label live_info interference_map = 
  match live_info.Ertltree.instr with
  | Ertltree.Embinop (Mmov, reg1, reg2, l ) -> if reg1 <> reg2 then add_friends reg1 reg2 interference_map 
  | _ -> ()

let add_interfs reg1 reg2 interference_map =
  (* fprintf std_formatter "add interf %a %a @\n" Register.print reg1 Register.print reg2; *)
  if Register.M.mem reg1 interference_map.map 
  then begin let arcR1 = Register.M.find reg1 interference_map.map in
    arcR1.intfs <- Register.S.add reg2 arcR1.intfs;
    if Register.S.mem reg2 arcR1.prefs then arcR1.prefs <- Register.S.remove reg2 arcR1.prefs
  end
  else begin let intfs = Register.S.singleton reg2 in
    let newarcR1 = {prefs = Register.S.empty; intfs = intfs} in
    interference_map.map <- Register.M.add reg1 newarcR1 interference_map.map
  end ;

  if Register.M.mem reg2 interference_map.map 
  then begin let arcR2 = Register.M.find reg2 interference_map.map in
    arcR2.intfs <- Register.S.add reg1 arcR2.intfs;
    if Register.S.mem reg1 arcR2.prefs then arcR2.prefs <- Register.S.remove reg1 arcR2.prefs
  end
  else begin let intfs = Register.S.singleton reg1 in
    let newarcR2 = {prefs = Register.S.empty; intfs = intfs} in
    interference_map.map <- Register.M.add reg2 newarcR2 interference_map.map
  end

let check_outs reg_out reg_def interference_map= 
  if reg_out <> reg_def then
    add_interfs reg_out reg_def interference_map


let handle_interferences live_info interference_map =
  if not (Register.S.is_empty live_info.Ertltree.defs) then
    Register.S.iter (fun reg_def -> Register.S.iter (fun reg_out -> check_outs reg_out reg_def interference_map) live_info.Ertltree.outs) live_info.Ertltree.defs



let check_outs_mov reg_friend reg_out reg_def interference_map= 
  if reg_out <> reg_def && reg_out <> reg_friend then
    add_interfs reg_out reg_def interference_map


let handle_interferences_mov reg_friend live_info interference_map = 
  if not (Register.S.is_empty live_info.Ertltree.defs) then
    Register.S.iter (fun reg_out -> check_outs_mov reg_friend reg_out (Register.S.choose live_info.Ertltree.defs) interference_map) live_info.Ertltree.outs


let iter_intfs label live_info interference_map = 
  match live_info.Ertltree.instr with
  | Ertltree.Embinop (Mmov, reg1, reg2, l ) -> if reg1 <> reg2 then handle_interferences_mov reg1 live_info interference_map 
  | _ -> handle_interferences live_info interference_map



(**


*)
let construct_interference_graph live_info_map =
  let interference_map = {map = Register.M.empty} in
  Label.M.iter (fun label live_info -> iter_pref label live_info interference_map) live_info_map;
  Label.M.iter (fun label live_info -> iter_intfs label live_info interference_map) live_info_map;
  interference_map.map 