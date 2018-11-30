# /*********************************************************/
# /* Archivo: cgen.c                                       */
# /* La implementacion del generador de c�digo             */
# /* para el compilador TINY                               */
# /* (genera codigo para la maquina CM)                    */
# /* Construccion de compiladores: principios y practica   */
# /* Kenneth C. Louden                                     */
# /*********************************************************/

require './RCode.rb'
require './semantica'
# tmpOffset es el desplazamiento de memoria para elementos temporales
#  se decrementa cada vez que un elemento temporal es
#  almacenado, y se incrementa cuando se carga de nuevo
$tmpOffset = 0
$flag = true
$emitloc = 0
$highemitloc = 0
$tmpoffset = 0
$ac = 0
$ac1 = 1
$gp = 5
$mp = 6
$pc = 7 


def codeGen(t):
      clean_code_interm
      s = "File:code_interm.tm\n"
      emitComment("Complete Compilation to CM Code")
      emitComment(s)
      emitComment("Standard prelude:")
      emitRM("LD",$mp,0,$ac,"load maxaddress from location 0")
      emitRM("ST",$ac,0,$ac,"clear location 0")
      emitComment("End of standard prelude.")
      cGen(t)
      emitComment("End of execution.")
      emitRO("HALT",0,0,0,"")
end

def clean_code_interm
      File.open('code_interm.txt', 'w') do |f1|
            f1.puts ""
      end
end

def escribir(code)
      code = code + "\n"
      File.open('code_interm.txt', 'w') do |f2|
            f2.puts code.to_s 
      end
end

def cGen(t):
      if  t != None:
          if t.nodekind == "sentencia":
              genStmt(t)
          elsif t.nodekind == "expresion":
              genExp(t)
          cGen(t.sibling)
          end
      end
end
def genStmt(t):
      p1 = 0
      p2 = 0
      p3 = 0
      savedloc1 = 0
      savedloc2 = 0
      currentloc = 0
      loc = 0
      if t.kind == "if"
          emitComment("-> if")
          p1 = t.child[0]
          p2 = t.child[1]
          p3 = t.child[2]
  
          cGen(p1)
          savedLoc1 = emitSkip(1)
          emitComment("if: jump to else belongs here")
  
          cGen(p2)
          savedLoc2 = emitSkip(1)
          emitComment("if: jump to end belongs here")
          currentLoc = emitSkip(0)
          emitBackup(savedLoc1)
          emitRM_Abs("JEQ", $ac, currentLoc, "if: jmp to else")
          emitRestore()
  
          cGen(p3)
          currentLoc = emitSkip(0)
          emitBackup(savedLoc2)
          emitRM_Abs("LDA", $pc, currentLoc, "jmp to end")
          emitRestore()
          emitComment("<- if")
  
      elsif t.kind == "repeat"
          emitComment("-> repeat")
          p1 = t.child[0]
          p2 = t.child[1]
          savedLoc1 = emitSkip(0)
          emitComment("repeat: jump after body comes back here")
          cGen(p1)
  
          cGen(p2)
          emitRM_Abs("JEQ", $ac, savedLoc1, "repeat: jmp back to body")
          emitComment("<- repeat")
  
      elsif t.kind == "while"
          loc1 = emitSkip(0)
  
          cGen(t.child[0])
          loc2 = emitSkip(1)
  
          cGen(t.child[1])
          currentLoc = emitSkip(0)
          emitBackup(loc2)
          emitRM_Abs('JEQ', $ac, (currentLoc+ 1))
          #if fBreak:
          #    emitBackup(b)
          #    emitRM_Abs('LDA', $pc, (currentLoc + 1))
          #    fBreak = False
          emitRestore()
          emitRM_Abs('LDA', $pc, loc1)
  
      elsif t.kind == "asignacion"
          emitComment("-> assign")
          cGen(t.child[0])
          loc = HaAsh.st_lookup(t.attr)
          emitRM("ST",$ac,loc,$gp,"assign: store value")
          emitComment("<- assign")
  
      elsif t.kind == "cin"
          emitRO("IN",$ac,0,0,"read integer value")
          print HaAsh.st_lookup(t.attr), "hellow", t.attr
          loc = HaAsh.st_lookup(t.attr)
          emitRM("ST",$ac,loc,$gp,"read: store value")
  
      elsif t.kind == "cout"
          cGen(t.child[0])
          emitRO("OUT",$ac,0,0,"write ac")
  
      elsif t.kind == "do"
          emitComment("-> do")
          p1 = t.child[0]
          p2 = t.child[1]
          savedLoc1 = emitSkip(0)
          emitComment("do: jump after body comes back here")
          cGen(p1)
  
          cGen(p2)
          emitRM_Abs("JEQ", $ac, savedLoc1, "do: jmp back to body")
          emitComment("<- do")
  
      elsif t.kind == "bloque"
          cGen(t.child[0])
      end
end

def genExp(t)
      loc = 0
      p1 = 0
      p2 = 0
      if t.kind == "real" or t.kind == "integer":
            emitComment("-> Const")
            emitRM("LDC",$ac,t.attr,0,"load const")
            emitComment("<- Const")
      elsif   t.kind == "id":
            emitComment("-> Id")
            loc = HaAsh.st_lookup(t.attr)
            emitRM("LD",$ac,loc,$gp,"load id0 value")
            emitComment("<- Id")
      elsif   t.kind == "op":
              emitComment("-> Op")
            p1 = t.child[0]
            p2 = t.child[1]
          cGen(p1)
          emitRM("ST",$ac,$tmpoffset,$mp,"op: push left")
          $tmpoffset = $tmpoffset - 1
          cGen(p2)
          $tmpoffset = $tmpoffset + 1
          emitRM("LD",$ac1,$tmpoffset,$mp,"op: load left")
          if t.attr == "+":
              emitRO("ADD",$ac,$ac1,$ac,"op +")
          elsif t.attr == "-":
              emitRO("SUB",$ac,$ac1,$ac,"op -")
          elsif t.attr == "*":
              emitRO("MUL",$ac,$ac1,$ac,"op *")
          elsif t.attr == "/":
              emitRO("DIV",$ac,$ac1,$ac,"op /")
          elsif t.attr == "<":
              emitRO("SUB", $ac, $ac1, $ac, "op <")
              emitRM("JLT", $ac, 2, $pc, "br if true")
              emitRM("LDC", $ac, 0, $ac, "false case")
              emitRM("LDA", $pc, 1, $pc, "unconditional jmp")
              emitRM("LDC", $ac, 1, $ac, "true case")
          elsif t.attr == "<=":
              emitRO("SUB", $ac, $ac1, $ac, "op <=")
              emitRM("JLE", $ac, 2, $pc, "br if true")
              emitRM("LDC", $ac, 0, $ac, "false case")
              emitRM("LDA", $pc, 1, $pc, "unconditional jmp")
              emitRM("LDC", $ac, 1, $ac, "true case")
          elsif t.attr == '>':
              emitRO('SUB', $ac, $ac1, $ac, "op >")
              emitRM('JGT', $ac, 2, $pc, "br if true")
              emitRM('LDC', $ac, 0, $ac, "false case")
              emitRM('LDA', $pc, 1, $pc, "unconditional jmp")
              emitRM('LDC', $ac, 1, $ac, "true case")
          elsif t.attr == '>=':
              emitRO('SUB', $ac, $ac1, $ac, "op >=")
              emitRM('JGE', $ac, 2, $pc, "br if true")
              emitRM('LDC', $ac, 0, $ac, "false case")
              emitRM('LDA', $pc, 1, $pc, "unconditional jmp")
              emitRM('LDC', $ac, 1, $ac, "true case")
          elsif t.attr == "==":
              emitRO("SUB", $ac, $ac1, $ac, "op ==")
              emitRM("JEQ", $ac, 2, $pc, "br if true")
              emitRM("LDC", $ac, 0, $ac, "false case")
              emitRM("LDA", $pc, 1, $pc, "unconditional jmp")
              emitRM("LDC", $ac, 1, $ac, "true case")
          elsif t.attr == "!=":
              emitRO("SUB", $ac, $ac1, $ac, "op !=")
              emitRM("JNE", $ac, 2, $pc, "br if true")
              emitRM("LDC", $ac, 0, $ac, "false case")
              emitRM("LDA", $pc, 1, $pc, "unconditional jmp")
              emitRM("LDC", $ac, 1, $ac, "true case")
          else
              emitComment("BUG: Unknown operator")
          end
          if $flag  
            emitComment("<- Op")
          end
      end
end
# /* El procedimiento emitRM emite una instrucci�n TM
#  * de registro-a-memoria
#  * op = el opcode
#  * r = registro objetivo
#  * d = el desplazamiento
#  * s = el registro base
#  * c = un comentario para imprimirse si TraceCode es TRUE
#  */
def emitComment(cadena) #imprime la cadena que se le envia
      if $flag
            puts cadena
      end
end


def emitRO(op, r, s, t, c):
      m = $emitloc.to_s + "\t" + op.to_s + "\t" + r.to_s + "\t" + s.to_s + "\t" + t.to_s
      print m
      escribir(m)
      #print emitloc,op,r,s,t
      $emitloc = $emitloc + 1
      emitComment(c) #un comentario para ser impreso si "TraceCode" ->flag es TRUE
      if $highemitloc < $emitloc
            $highemitloc = $emitloc
      end
end
def emitRM(op, r, d, s, c) # inserción y extracción de esta pila,  emite una instrucción CM 
      m = $emitloc.to_s + "\t" + op.to_s + "\t" + r.to_s + "\t" + d.to_s + "\t" + s.to_s
      print m
      escribir(m)
      #print emitloc, op, r, d, s
      $emitloc = $emitloc + 1
      emitComment(c)
      #print("\n")
      if $highemitloc < $emitloc 
            $highemitloc = $emitloc
      end
end
def emitSkip(howmany) #saltar la sentencia siguiente y grabar su ubicación para ajuste posterior
      i = $emitloc
      $emitloc = $emitloc + howmany
      if $highemitloc < $emitloc 
            $highemitloc = $emitloc
      end
      return i
end
  
def emitBackup(loc) # respalda a loc = una localidad previamente saltada 
      if loc > $highemitloc 
            emitComment("BUG in emitBackup")
      end
      $emitloc = loc
end
  
def emitRestore() # restablece la posicidn del código actual a la más alta posición no emitida previamente 
      $emitloc = $highemitloc
end
  
def emitRM_Abs(op, r, a, c)
      m = $emitloc.to_s + "\t" + op.to_s + "\t" + r.to_s + "\t" + (a-($emitloc+1)).to_i.to_s + "\t" + $pc.to_s
      print m
      escribir(m)
      #print emitloc,op,r,(a-(emitloc+1)),pc
      $emitloc = $emitloc + 1
      if $flag == true 
            print(c)
      end
      #print ("\n")
      if $highemitloc < $emitloc
            $$highemitloc = $emitloc
      end
end
  