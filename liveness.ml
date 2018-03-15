open Ertltree
open Format

type remaining_label_m = {mutable set : Label.set;}

(**
  Map where all label live_infos are stored at the end only
  Doesn't participate in the algorithm
*)
let live_info_map = ref Label.M.empty

(**
  Hashtable where all label live_infos are stored and modified during the running of the algorithm
*)
let livenessHashtbl = Hashtbl.create 32


(**
  Creates a first version on a live_info for every label, 
  and puts it into livenessHashtbl

  @param mylabel The label of the instruction to analyze
  @param myinstr The corresponding instruction
*)
let create_live_info mylabel myinstr = 
  let successeurs = Ertltree.succ myinstr in
  let defs, uses = Ertltree.def_use myinstr in
  let my_live_info = {
    instr = myinstr;
    succ = successeurs;    
    pred = Label.S.empty;       (* Will be updated iterativly by update_pred *)
    defs = Register.set_of_list defs;    
    uses = Register.set_of_list uses;    
    ins = Register.S.empty;    (* Will be updated by the Kildall algorithm *)
    outs = Register.S.empty;    (* Will be updated by the Kildall algorithm *)
  } in
  Hashtbl.add livenessHashtbl mylabel my_live_info


(**
  Takes a label and live_info, and update all its successors with it as a predecessor

  @param mylabel the label of the live_info
  @param my_live_info the live info to use
*)  
let update_pred mylabel my_live_info =
  let add_one_succ onesucc_lb = 
    if Hashtbl.mem livenessHashtbl onesucc_lb then let one_succ = Hashtbl.find livenessHashtbl onesucc_lb in
    one_succ.pred <- Label.S.add mylabel one_succ.pred
    else  fprintf std_formatter "%a isn't in livenessHatbl @\n"  Label.print onesucc_lb;

  in
  if my_live_info.succ <> [] then List.iter add_one_succ my_live_info.succ


(**
  For a live_info, add to its "outs" all the "ins" of its successors

  @param live_info the live_info to update
*)  
let compute_outs live_info = 
  let add_ins_of_succ label =
    let this_succ = Hashtbl.find livenessHashtbl label in
    live_info.outs <- Register.S.union live_info.outs this_succ.ins 
  in
  List.iter add_ins_of_succ live_info.succ



(**
  For a live_info, computes its "ins" as the union of its "uses" with the diff of its "outs" and "defs"

  @param live_info the live_info to update
*)  
let compute_ins live_info = 
  let diff = Register.S.diff live_info.outs live_info.defs in 
  live_info.ins <- Register.S.union live_info.uses diff

(**
  Executes the kildall algorithm
*)
let kildall () = 
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


(**
  Fills a map from a hashtbl to get a good return type
*)
let fill_the_map label my_live_info = 
  live_info_map := Label.M.add label my_live_info !live_info_map 


(**
  Main function that fills the hashtbl and performs the kildall algorithm

  @param instrMap The instrMap from Ertl
  @return the map containing all the updated live_infos of each label
*)  
let liveness instrMap = 
  (* Hashtbl.clear livenessHashtbl; *)
  Label.M.iter create_live_info instrMap;

  Hashtbl.iter update_pred livenessHashtbl;

  kildall ();

  Hashtbl.iter fill_the_map livenessHashtbl;

  !live_info_map
