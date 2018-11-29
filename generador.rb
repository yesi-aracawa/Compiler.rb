# /*********************************************************/
# /* Archivo: cgen.c                                       */
# /* La implementacion del generador de c�digo             */
# /* para el compilador TINY                               */
# /* (genera codigo para la maquina CM)                    */
# /* Construccion de compiladores: principios y practica   */
# /* Kenneth C. Louden                                     */
# /*********************************************************/
require './RCode.rb'

# tmpOffset es el desplazamiento de memoria para elementos temporales
#  se decrementa cada vez que un elemento temporal es
#  almacenado, y se incrementa cuando se carga de nuevo
$tmpOffset = 0

# El procedimiento genStmt genera codigo para un nodo de sentencia 
def genStmt( TreeNode * tree)
 TreeNode * p1, * p2, * p3
  int savedLoc1,savedLoc2,currentLoc
  int loc
  case (tree->kind.stmt) 

  when IfK :
         if (TraceCode) emitComment("-> if") 
         p1 = tree->child[0] 
         p2 = tree->child[1] 
         p3 = tree->child[2] 
         # genera codigo para expresion de prueba 
         gcodet(p1)
         savedLoc1 = emitSkip(1) 
         emitComment("if: jump to else belongs here")
         # recursividad en la parte then 
         gcodet(p2)
         savedLoc2 = emitSkip(1) 
         emitComment("if: jump to end belongs here")
         currentLoc = emitSkip(0) 
         emitBackup(savedLoc1) 
         emitRM_Abs("JEQ",ac,currentLoc,"if: jmp to else")
         emitRestore() 
         # recursividad en la parte else 
         gcodet(p3)
         currentLoc = emitSkip(0) 
         emitBackup(savedLoc2) 
         emitRM_Abs("LDA",pc,currentLoc,"jmp to end") 
         emitRestore() 
         if (TraceCode)  emitComment("<- if") 
         break # if_k 

         when RepeatK:
         if (TraceCode) emitComment("-> repeat") 
         p1 = tree->child[0] 
         p2 = tree->child[1] 
         savedLoc1 = emitSkip(0)
         emitComment("repeat: jump after body comes back here")
         # genera codigo para el cuerpo 
         gcodet(p1)
         # genera codigo para prueba 
         gcodet(p2)
         emitRM_Abs("JEQ",ac,savedLoc1,"repeat: jmp back to body")
         if (TraceCode)  emitComment("<- repeat") 
         break # repeat 

         when AssignK:
         if (TraceCode) emitComment("-> assign") 
         # genera codigo para rhs 
         gcodet(tree->child[0])
         # ahora almacena valor 
         loc = st_lookup(tree->attr.name)
         emitRM("ST",ac,loc,gp,"assign: store value")
         if (TraceCode)  emitComment("<- assign") 
         break # de assign_k 

         when ReadK:
         emitRO("IN",ac,0,0,"read integer value")
         loc = st_lookup(tree->attr.name)
         emitRM("ST",ac,loc,gp,"read: store value")
         break
         when WriteK:
         # genera codigo para la expresion a escribir 
         gcodet(tree->child[0])
         # ahora la extrae 
         emitRO("OUT",ac,0,0,"write ac")
         break
         else
         break
    end
end # de genStmt 
# El procedimiento genExp genera codigo en un nodo de expresion 
def genExp( TreeNode * tree)
 int loc
  TreeNode * p1, * p2
  case (tree->kind.exp) 

  when ConstK :
      if (TraceCode) emitComment("-> Const") 
      # genera codigo para cargar constante entera utilizand LDC 
      emitRM("LDC",ac,tree->attr.val,0,"load const")
      if (TraceCode)  emitComment("<- Const") 
      break # de ConstK 
    
      when IdK :
      if (TraceCode) emitComment("-> Id") 
      loc = st_lookup(tree->attr.name)
      emitRM("LD",ac,loc,gp,"load id value")
      if (TraceCode)  emitComment("<- Id") 
      break # de IdK 

      when OpK :
         if (TraceCode) emitComment("-> Op") 
         p1 = tree->child[0]
         p2 = tree->child[1]
         # genera codigo para ac = argumento izquierdo 
         gcodet(p1)
         # genera codigo para insertar operando izquierdo 
         emitRM("ST",ac,tmpOffset--,mp,"op: push left")
         # genera codigo para ac = operando derecho 
         gcodet(p2)
         # ahora carga el operando izquierdo 
         emitRM("LD",ac1,++tmpOffset,mp,"op: load left")
         case (tree->attr.op) 
          when PLUS :
                emitRO("ADD",ac,ac1,ac,"op +")
                break
          when MINUS :
                emitRO("SUB",ac,ac1,ac,"op -")
                break
          when TIMES :
                emitRO("MUL",ac,ac1,ac,"op *")
                break
          when OVER :
                emitRO("DIV",ac,ac1,ac,"op /")
                break
          when LT :
                emitRO("SUB",ac,ac1,ac,"op <") 
                emitRM("JLT",ac,2,pc,"br if true") 
                emitRM("LDC",ac,0,ac,"false case") 
                emitRM("LDA",pc,1,pc,"unconditional jmp") 
                emitRM("LDC",ac,1,ac,"true case") 
                break
          when EQ :
                emitRO("SUB",ac,ac1,ac,"op ==") 
                emitRM("JEQ",ac,2,pc,"br if true")
                emitRM("LDC",ac,0,ac,"false case") 
                emitRM("LDA",pc,1,pc,"unconditional jmp") 
                emitRM("LDC",ac,1,ac,"true case") 
                break
              default:
                emitComment("BUG: Unknown operator")
                break
          end # de case op 
         if (TraceCode)  emitComment("<- Op")  end
         break # de OpK 

         else
      break
  end
end # de genExp

# El procedimiento gcodet genera codigo recursivamente mediante
# el recorrido del arbol
def gcodet(TreeNode * tree)
  if (tree != NULL) # si el nodo es diferente de nulo
    case (tree->nodekind)  #pregunta por si tipo
      when StmtK:
            genStmt(tree) #genera un codigo para un nodo de sentencia
            break
      when ExpK:
            genExp(tree) #genera codigo en un nodo de expresion
            break
      else
            break
    end
      generatree->sibling) # es recursiva
  end
end
# **********************************************
#  la funcion principal del generador de codigo 
# **********************************************
#  El procedimiento initGen genera codigo hacia un
#  * archivo de codigo por recorrido del arbol sintactico. El
#  * segundo parametro (codefile) es el nombre de archivo
#  * que contiene de codigo, y se utiliza para imprimir el
#  * nombre de archivo como un comentario en el archivo de codigo
#  

def initGen(TreeNode * syntaxTree, char * codefile)
  char * s = malloc(strlen(codefile)+7)
   strcpy(s,"File: ")
   strcat(s,codefile)
   emitComment("TINY Compilation to TM Code")
   emitComment(s)
  # genera preludio eatandar 
   emitComment("Standard prelude:")
   emitRM("LD",mp,0,ac,"load maxaddress from location 0")
   emitRM("ST",ac,0,ac,"clear location 0")
   emitComment("End of standard prelude.")
  #  genera codigo para el programa TINY 
   gcodet(syntaxTree)
  # final 
   emitComment("End of execution.")
   emitRO("HALT",0,0,0,"")
end
