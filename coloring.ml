
open Ltltree

type todo_set_m = {mutable set : Register.set}

let find_best_coloring_preference_four todo potential_colors_map interference_map =
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
      (* As we return false, the two other arguments won't be used*)
      (false, Register.fresh(), Register.fresh())
    end


let find_best_coloring_preference_three todo potential_colors_map interference_map = 
  let is_of_preference_three register potential_colors = 
    if Register.S.is_empty potential_colors then begin false end 
    else
      begin
        let arcs_of_reg = Register.M.find register interference_map in
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
      let arcs_of_reg = Register.M.find register_to_color interference_map in
      let preference_inter_potential = Register.S.inter arcs_of_reg.prefs potential_colors in
      (true, register_to_color, Register.S.choose preference_inter_potential)
    end
  else
    begin
      find_best_coloring_preference_four todo potential_colors_map interference_map
    end


let find_best_coloring_preference_two todo potential_colors_map interference_map = 
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
      find_best_coloring_preference_three todo potential_colors_map interference_map
    end


let find_best_coloring_preference_one todo potential_colors_map interference_map =
  let filter_to_do register potential_colors = 
    if Register.S.mem register todo then true else false
  in
  let potential_colors_map_todo = Register.M.filter filter_to_do potential_colors_map in

  let is_of_preference_one register potential_colors = 
    if Register.S.is_empty potential_colors || (Register.S.cardinal potential_colors) > 1 then begin false end
    else 
      begin
        let only_potential_color = Register.S.choose potential_colors in
        let arcs_of_reg = Register.M.find register interference_map in
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
      find_best_coloring_preference_two todo potential_colors_map_todo interference_map
    end


let remove_color potential_colors_map colored_register chosen_color interference_map = 

  let arcs_from_register = Register.M.find colored_register interference_map in
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

let change_pref interference_map register_to_color new_color = 
  let iter register arcs =
    if Register.S.mem register_to_color arcs.prefs then 
      arcs.prefs <- Register.S.add new_color (Register.S.remove register_to_color arcs.prefs) 
  in
  Register.M.iter iter interference_map; interference_map

let rec color_one interference_map todo potential_colors_map color_map number_of_spill =
  if not (Register.S.is_empty todo) then 
    begin
      let (coloring_is_possible, register_to_color , new_color) = find_best_coloring_preference_one todo potential_colors_map interference_map in
      if coloring_is_possible then
        begin
          (* fprintf std_formatter "Hello @\n"; *)
          (* fprintf std_formatter "Lets color %a with color %a @\n" Register.print register_to_color Register.print new_color; *)
          let new_color_map = Register.M.add register_to_color (Ltltree.Reg new_color) color_map in
          let new_interference_graph = change_pref interference_map register_to_color new_color in
          let new_todo = Register.S.remove register_to_color todo in
          (* let new_potential_colors_map_1 = Register.M.remove register_to_color potential_colors_map in *)
          let new_potential_colors_map = remove_color potential_colors_map register_to_color new_color new_interference_graph in
          color_one new_interference_graph new_todo new_potential_colors_map new_color_map number_of_spill
        end
      else 
        begin
          (* fprintf std_formatter "Coucou @\n"; *)
          let register_to_spill = Register.S.choose todo in
          let new_color_map = Register.M.add register_to_spill (Ltltree.Spilled (- 8 - number_of_spill * 8)) color_map in
          let new_todo = Register.S.remove register_to_spill todo in
          color_one interference_map new_todo potential_colors_map new_color_map (number_of_spill + 1)
        end
    end
  else
    begin
      (color_map, number_of_spill)
    end



(**


*)
let color interference_map = 
  let todo = {set = Register.S.empty} in
  let fill_todo register arcs =
    if not (Register.S.mem register Register.allocatable) then
      todo.set <- Register.S.add register todo.set
  in
  Register.M.iter fill_todo interference_map;
  let potential_colors_map = {reg_map= Register.M.empty} 
  in
  let fill_potential_colors_map register arcs = 
    let potential_colors = Register.S.diff Register.allocatable arcs.intfs
    in potential_colors_map.reg_map <- Register.M.add register potential_colors potential_colors_map.reg_map 
  in
  Register.M.iter fill_potential_colors_map interference_map;
  let empty_color_map = Register.M.empty in
  let zero = 0 in
  color_one interference_map todo.set potential_colors_map.reg_map empty_color_map zero

