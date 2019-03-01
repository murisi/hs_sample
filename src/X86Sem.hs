module X86Sem where

import Ast
import AstContext (getOperandAst)

import           Hapstone.Capstone
import           Hapstone.Internal.Capstone as Capstone
import           Hapstone.Internal.X86      as X86
import           Util
import           AstContext

--ll, ml, hl

add_s :: CsInsn -> [AstNodeType]
add_s inst =
  let op1 = getOperandAst $ get_first_opr_value inst
      op2 = getOperandAst $ get_second_opr_value inst
  in [
      store_node (get_first_opr_value inst) (BvaddNode op1 op2),
      SetFlag Adjust (AssertNode "Adjust flag unimplemented"),
      SetFlag Parity (AssertNode "Parity flag unimplemented"),
      SetFlag Sign (AssertNode "Sign flag unimplemented"),
      SetFlag Zero (AssertNode "Zero flag unimplemented"),
      SetFlag Carry (AssertNode "Carry flag unimplemented"),
      SetFlag Overflow (AssertNode "Overflow flag unimplemented")
    ]

sub_s :: CsInsn -> [AstNodeType]
sub_s inst =
  let op1 = getOperandAst $ get_first_opr_value inst
      op2 = getOperandAst $ get_second_opr_value inst
  in [
      store_node (get_first_opr_value inst) (BvsubNode op1 op2),
      SetFlag Adjust (AssertNode "Adjust flag unimplemented"),
      SetFlag Parity (AssertNode "Parity flag unimplemented"),
      SetFlag Sign (AssertNode "Sign flag unimplemented"),
      SetFlag Zero (AssertNode "Zero flag unimplemented"),
      SetFlag Carry (AssertNode "Carry flag unimplemented"),
      SetFlag Overflow (AssertNode "Overflow flag unimplemented")
    ]

xor_s :: CsInsn -> [AstNodeType]
xor_s inst =
  let op1 = getOperandAst $ get_first_opr_value inst
      op2 = getOperandAst $ get_second_opr_value inst
  in [
      store_node (get_first_opr_value inst) (BvxorNode op1 op2),
      SetFlag Adjust (AssertNode "Adjust flag unimplemented"),
      SetFlag Parity (AssertNode "Parity flag unimplemented"),
      SetFlag Sign (AssertNode "Sign flag unimplemented"),
      SetFlag Zero (AssertNode "Zero flag unimplemented"),
      SetFlag Carry (AssertNode "Carry flag unimplemented"),
      SetFlag Overflow (AssertNode "Overflow flag unimplemented")
    ]

push ::  CsInsn -> [AstNodeType]
push inst =
  let op1 = getOperandAst $ get_first_opr_value inst
  in [
      SetReg stack_register (BvsubNode (GetReg stack_register) (BvNode 4 32)),
      Store (GetReg stack_register) op1
    ]

pop ::  CsInsn -> [AstNodeType]
pop inst =
  --whenever the operation is a store reg or store mem depends on op1
  let
    read_exp = Read (BvaddNode (GetReg stack_register) (BvNode 4 32))
    pop_op = case (get_first_opr_value inst) of
              (Reg reg) -> (SetReg stack_register read_exp)
              (Mem mem) -> Store (getLeaAst mem) read_exp
              (Imm _) -> AssertNode "pop with imm, wtf"
  in
   [
      SetReg stack_register (BvaddNode (GetReg stack_register) (BvNode 4 32)),
      pop_op
    ]

mov ::  CsInsn -> [AstNodeType]
mov inst =
  let op1 = get_first_opr_value inst
  in case op1 of
    (Imm value) -> [BvNode value 32]
    (Reg reg) -> [GetReg (X86Reg reg)]
    (Mem mem) ->  [AssertNode "pop with imm, wtf"]


--isolate x86 32 bit specific stuff so its easier to refactor later
stack_register :: Register
stack_register = (X86Reg X86RegEsp)

store_node :: CsX86OpValue -> AstNodeType -> AstNodeType
store_node operand store_what =
            case operand of
              (Reg reg) -> (SetReg stack_register store_what)
              (Mem mem) -> Store (getLeaAst mem) store_what
              (Imm _) -> AssertNode "store to imm, wtf"
