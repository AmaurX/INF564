open X86_64
open Register

exception Error of string

let visited = Hashtbl.create 17
type instr = Code of X86_64.text | Label of Label.t
let code = ref []
let emit l i = code := Code i :: Label l :: !code
let emit_wl i = code := Code i :: !code
let labels = Hashtbl.create 17
let need_label l = Hashtbl.add labels l ()

let register (r : Register.t) = match (r :> string) with
  | "%rax" -> X86_64.rax
  | "%rbx" -> X86_64.rbx
  | "%rcx" -> X86_64.rcx
  | "%rdx" -> X86_64.rdx
  | "%rdi" -> X86_64.rdi
  | "%rsi" -> X86_64.rsi
  | "%rbp" -> X86_64.rbp
  | "%rsp" -> X86_64.rsp
  | "%r8" -> X86_64.r8
  | "%r9" -> X86_64.r9
  | "%r10" -> X86_64.r10
  | "%r11" -> X86_64.r11
  | "%r12" -> X86_64.r12
  | "%r13" -> X86_64.r13
  | "%r14" -> X86_64.r14
  | "%r15" -> X86_64.r15
  | _ -> raise (Error ("cannot translate register"))

let operand = function
  | Ltltree.Reg (r) -> X86_64.reg (register r)
  | Ltltree.Spilled (i) -> X86_64.ind ~ofs:i X86_64.rsp




let treat_unop unop op = ()

let treat_binop binop op1 op2 = ()



let rec lin g l =
  if not (Hashtbl.mem visited l) then begin
    Hashtbl.add visited l ();
    instru g l (Label.M.find l g)
  end else begin
    need_label l;
    emit_wl (jmp (l :> string))
  end

and instru g l = function
  | Ltltree.Econst (n, op, lb) ->
      emit l (movq (imm32 n) (operand op)); lin g lb
  | Ltltree.Egoto (lb) -> lin g lb
  | Ltltree.Eload (op1 ,n , op2, lb) -> 
      emit l (movq (X86_64.ind ~ofs:n (register op1)) (reg (register op2))); lin g lb
  | Ltltree.Estore (op1, op2, n, lb) ->
      emit l (movq (reg (register op1)) (X86_64.ind ~ofs:n (register op2))); lin g lb
  | Ltltree.Ereturn -> emit l ret
  | Ltltree.Emunop (unop, op, lb) -> treat_unop unop op; lin g lb
  | Ltltree.Embinop (binop, op1, op2, lb) -> treat_binop binop op1 op2; lin g lb 
  | Ltltree.Epush (op, lb) -> emit l (pushq (operand(op))); lin g lb
  | Ltltree.Epop (op, lb) -> emit l (popq (register(op))); lin g lb

  (* 
  
  (** les mêmes que dans ERTL, mais avec operand à la place de register *)
  | Emubranch of mubranch * operand * label * label
  | Embbranch of mbbranch * operand * operand * label * label
  (** légèrement modifiée *)
  | Ecall of ident * label
  (** nouveau *) *)
  | _ ->  raise (Error "lin : instr not supported") 

let rec linearize = function
  | f::funlist -> emit_wl (label f.Ltltree.fun_name); lin f.Ltltree.fun_body f.Ltltree.fun_entry; linearize funlist
  | [] -> ()

let program p = 
  linearize p.Ltltree.funs; 
  let filter_instr asm1 instr =
    match instr with 
    | Code (cd) -> (++)  cd asm1
    | Label (lb) -> let (str_lb : string) = Label.to_string lb in if Hashtbl.mem labels lb then (++)  (label str_lb) asm1 else asm1
  in
  let text1 = List.fold_left filter_instr nop !code in
  {text = (++) (globl "main") text1; data = nop}