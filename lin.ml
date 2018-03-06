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

let rec lin g l =
  if not (Hashtbl.mem visited l) then begin
    Hashtbl.add visited l ();
    instr g l (Label.M.find l g)
  end else begin
    need_label l;
    emit_wl (jmp (l :> string))
  end

and instr g l = function
  | Ltltree.Econst (n, r, l1) ->
      emit l (movq (imm32 n) (operand r)); lin g l1
  | _ ->  raise (Error "lin : instr not supported")

let program p = ()