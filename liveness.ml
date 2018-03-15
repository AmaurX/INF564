open Ertltree
open Format
(***  ***)

type remaining_label_m = {mutable set : Label.set;}
(**
  Map where all pseudo-registers lifespans are stored
  *)
  let live_info_map = ref Label.M.empty
let livenessHashtbl = Hashtbl.create 32

let create_live_info mylabel myinstr = 
  let successeurs = Ertltree.succ myinstr in
  let defs, uses = Ertltree.def_use myinstr in
  let my_live_info = {
    instr = myinstr;
    succ = successeurs;    (* successeurs *)
    pred = Label.S.empty;       (* prédécesseurs *)
    defs = Register.set_of_list defs;    (* définitions *)
    uses = Register.set_of_list uses;    (* utilisations *)
    ins = Register.S.empty;    (* variables vivantes en entrée *)
    outs = Register.S.empty;    (* variables vivantes en sortie *)
  } in
  Hashtbl.add livenessHashtbl mylabel my_live_info

let update_pred mylabel my_live_info =

  let add_one_succ onesucc_lb = 
    if Hashtbl.mem livenessHashtbl onesucc_lb then let one_succ = Hashtbl.find livenessHashtbl onesucc_lb in
    one_succ.pred <- Label.S.add mylabel one_succ.pred
    else  fprintf std_formatter "%a isn't in livenessHatbl @\n"  Label.print onesucc_lb;

  in

  if my_live_info.succ <> [] then List.iter add_one_succ my_live_info.succ


let compute_outs live_info = 
  let add_ins_of_succ label =
    let this_succ = Hashtbl.find livenessHashtbl label in
    live_info.outs <- Register.S.union live_info.outs this_succ.ins 
  in
  List.iter add_ins_of_succ live_info.succ

let compute_ins live_info = 
  let diff = Register.S.diff live_info.outs live_info.defs in 
  live_info.ins <- Register.S.union live_info.uses diff

  
let kildall livenesstbl = 

  let remaining_labels = {set = Label.S.empty} in
  let fillSet label info = remaining_labels.set <- Label.S.add label remaining_labels.set
  in  
  Hashtbl.iter fillSet livenessHashtbl;
  while (not (Label.S.is_empty remaining_labels.set))
  do 
    let mylabel = Label.S.min_elt remaining_labels.set in
    remaining_labels.set <- Label.S.remove mylabel remaining_labels.set;
    let my_live_info = Hashtbl.find livenessHashtbl mylabel in
    let old_ins = my_live_info.ins in
    compute_outs (my_live_info);
    compute_ins (my_live_info);
    (* Maybe put my_live_info back into the hashtable i dont know... *)
    if not (Register.S.equal old_ins my_live_info.ins) 
    then remaining_labels.set <- Label.S.union my_live_info.pred remaining_labels.set;
  done



let fill_the_map label my_live_info = 
  live_info_map := Label.M.add label my_live_info !live_info_map 


let liveness instrMap = 
  (* Hashtbl.clear livenessHashtbl; *)
  Label.M.iter create_live_info instrMap;

  Hashtbl.iter update_pred livenessHashtbl;

  kildall livenessHashtbl;

  Hashtbl.iter fill_the_map livenessHashtbl;

  !live_info_map
