# /*********************************************************/
# /* Archivo: cgen.c                                       */
# /* La implementacion del generador de c�digo             */
# /* para el compilador TINY                               */
# /* (genera codigo para la maquina CM)                    */
# /* Construccion de compiladores: principios y practica   */
# /* Kenneth C. Louden                                     */
# /*********************************************************/
require './semantica'
# tmpOffset es el desplazamiento de memoria para elementos temporales
#  se decrementa cada vez que un elemento temporal es
#  almacenado, y se incrementa cuando se carga de nuevo
class Codegen 

  @tmpOffset = 0 # desplazamiento de memoria
  @flag = true #tracecode
  @emitloc = 0 # localidad para emision de la instruccion actual
  @highemitloc = 0 # localidad mas alta emitida hasta ahora
  @ac = 0 # acumuladores
  @ac1 = 1 # segundo acumulador
  @gp = 5 # puntero global
  @mp = 6 # puntero de memoria
  @pc = 7 # contador de programa


  def codeGen(tree) # inicializa la generacion del codigo, recibe arbol sintactico
    clean_code_interm
    s = "File:code_interm.tm\n"
    emitComment("Complete Compilation to CM Code")
    emitComment(s)
    emitComment("Standard prelude:")
    emitRM("LD",@mp,0,@ac,"load maxaddress from location 0")
    emitRM("ST",@ac,0,@ac,"clear location 0")
    emitComment("End of standard prelude.")
    cGen(tree)
    emitComment("End of execution.")
    emitRO("HALT",0,0,0,"")
  end

  def clean_code_interm # limpia el archivo donde se genera el codigo intermedio
    File.open('code_interm.txt', 'w') do |f1|
      f1.puts ""
    end
  end

  def escribir(code) # escribe sobre el archivo de generacion de codigo intermedio
    code = code + "\n"
    File.open('code_interm.txt', 'w') do |f2|
      f2.puts code.to_s 
    end
  end

  def cGen(tree) # Genarador de codigo recursivo interno 
    if  tree != nil # recorre el arbol en postorden
      if tree.nodekind == "sentencia" #y evalua si es un nodo de sentencia o de expresion
        genStmt(tree)
      elsif tree.nodekind == "expresion"
        genExp(tree)
      end
      cGen(tree.sibling) # acceso al hermano ['']
    end
  end

  def genStmt(tree) # genera codigo para un nodo de sentencia
    p1 = 0 #inicializacion de variables requeridas para los traspasos de nodo
    p2 = 0
    p3 = 0
    savedloc1 = 0 # y de locacion
    savedloc2 = 0
    currentloc = 0
    loc = 0

    if tree.kind == "if" #distingue entre las clases de sentencia
      emitComment("-> if")
      p1 = tree.child[0]
      p2 = tree.child[1]
      p3 = tree.child[2]
  
      cGen(p1) # realiza llamadas recursivas a cGen
      savedLoc1 = emitSkip(1)
      emitComment("if: jump to else belongs here")

      cGen(p2)
      savedLoc2 = emitSkip(1)
      emitComment("if: jump to end belongs here")
      currentLoc = emitSkip(0)
      emitBackup(savedLoc1)
      emitRM_Abs("JEQ", @ac, currentLoc, "if: jmp to else")
      emitRestore()
  
      cGen(p3)
      currentLoc = emitSkip(0)
      emitBackup(savedLoc2)
      emitRM_Abs("LDA", @pc, currentLoc, "jmp to end")
      emitRestore()
      emitComment("<- if")
    elsif tree.kind == "repeat"
      emitComment("-> repeat")
      p1 = tree.child[0]
      p2 = tree.child[1]
      savedLoc1 = emitSkip(0)
      emitComment("repeat: jump after body comes back here")
      cGen(p1)
      cGen(p2)
      emitRM_Abs("JEQ", @ac, savedLoc1, "repeat: jmp back to body")
      emitComment("<- repeat")
    elsif tree.kind == "while"
      loc1 = emitSkip(0)
      cGen(tree.child[0])
      loc2 = emitSkip(1)
      cGen(tree.child[1])
      currentLoc = emitSkip(0)
      emitBackup(loc2)
      emitRM_Abs('JEQ', @ac, (currentLoc+ 1))
      #if fBreak:
      #    emitBackup(b)
      #    emitRM_Abs('LDA', @pc, (currentLoc + 1))
      #    fBreak = False
      emitRestore()
      emitRM_Abs('LDA', @pc, loc1)
    elsif tree.kind == "asignacion"
      emitComment("-> assign")
      cGen(tree.child[0])
      loc = HaAsh.st_lookup(tree.attr)
      emitRM("ST",@ac,loc,@gp,"assign: store value")
      emitComment("<- assign")
    elsif tree.kind == "cin"
      emitRO("IN",@ac,0,0,"read integer value")
      print HaAsh.st_lookup(tree.attr), "hellow", tree.attr
      loc = HaAsh.st_lookup(tree.attr)
      emitRM("ST",@ac,loc,@gp,"read: store value")
    elsif tree.kind == "cout"
      cGen(tree.child[0])
      emitRO("OUT",@ac,0,0,"write ac")
    elsif tree.kind == "do"
      emitComment("-> do")
      p1 = tree.child[0]
      p2 = tree.child[1]
      savedLoc1 = emitSkip(0)
      emitComment("do: jump after body comes back here")
      cGen(p1)
      cGen(p2)
      emitRM_Abs("JEQ", @ac, savedLoc1, "do: jmp back to body")
      emitComment("<- do")
    elsif tree.kind == "bloque"
      cGen(tree.child[0])
    end
  end

  def genExp(tree) # genera un codigo para un nodo de expresion
    loc = 0
    p1 = 0
    p2 = 0

    if tree.kind == "real" or tree.kind == "integer"
      emitComment("-> Const")
      emitRM("LDC",@ac,tree.attr,0,"load const") # genera el codigo para cargar constante
      emitComment("<- Const")
    elsif   tree.kind == "id"
      emitComment("-> Id")
      loc = HaAsh.st_lookup(tree.attr)
      emitRM("LD",@ac,loc,@gp,"load id0 value")
      emitComment("<- Id")
    elsif   tree.kind == "op"
      emitComment("-> Op")
      p1 = tree.child[0]
      p2 = tree.child[1]
      cGen(p1) # argumento izquierdo
      emitRM("ST",@ac,@tmpOffset,@mp,"op: push left") # insertar operando izquierdo
      @tmpOffset = @tmpOffset - 1
      cGen(p2) # operando derecho
      @tmpOffset = @tmpOffset + 1
      emitRM("LD",@ac1,@tmpOffset,@mp,"op: load left") # cargar operando izquierdo

      if tree.attr == "+"
        emitRO("ADD",@ac,@ac1,@ac,"op +")
      elsif tree.attr == "-"
        emitRO("SUB",@ac,@ac1,@ac,"op -")
      elsif tree.attr == "*"
        emitRO("MUL",@ac,@ac1,@ac,"op *")
      elsif tree.attr == "/"
        emitRO("DIV",@ac,@ac1,@ac,"op /")
      elsif tree.attr == "<"
        emitRO("SUB", @ac, @ac1, @ac, "op <")
        emitRM("JLT", @ac, 2, @pc, "br if true")
        emitRM("LDC", @ac, 0, @ac, "false case")
        emitRM("LDA", @pc, 1, @pc, "unconditional jmp")
        emitRM("LDC", @ac, 1, @ac, "true case")
      elsif tree.attr == "<="
        emitRO("SUB", @ac, @ac1, @ac, "op <=")
        emitRM("JLE", @ac, 2, @pc, "br if true")
        emitRM("LDC", @ac, 0, @ac, "false case")
        emitRM("LDA", @pc, 1, @pc, "unconditional jmp")
        emitRM("LDC", @ac, 1, @ac, "true case")
      elsif tree.attr == '>'
        emitRO('SUB', @ac, @ac1, @ac, "op >")
        emitRM('JGT', @ac, 2, @pc, "br if true")
        emitRM('LDC', @ac, 0, @ac, "false case")
        emitRM('LDA', @pc, 1, @pc, "unconditional jmp")
        emitRM('LDC', @ac, 1, @ac, "true case")
      elsif tree.attr == '>='
        emitRO('SUB', @ac, @ac1, @ac, "op >=")
        emitRM('JGE', @ac, 2, @pc, "br if true")
        emitRM('LDC', @ac, 0, @ac, "false case")
        emitRM('LDA', @pc, 1, @pc, "unconditional jmp")
        emitRM('LDC', @ac, 1, @ac, "true case")
      elsif tree.attr == "=="
        emitRO("SUB", @ac, @ac1, @ac, "op ==")
        emitRM("JEQ", @ac, 2, @pc, "br if true")
        emitRM("LDC", @ac, 0, @ac, "false case")
        emitRM("LDA", @pc, 1, @pc, "unconditional jmp")
        emitRM("LDC", @ac, 1, @ac, "true case")
      elsif tree.attr == "!="
        emitRO("SUB", @ac, @ac1, @ac, "op !=")
        emitRM("JNE", @ac, 2, @pc, "br if true")
        emitRM("LDC", @ac, 0, @ac, "false case")
        emitRM("LDA", @pc, 1, @pc, "unconditional jmp")
        emitRM("LDC", @ac, 1, @ac, "true case")
      else
        emitComment("BUG: Unknown operator")
      end

      if @flag  
        emitComment("<- Op")
      end
    end
  end
  # /* El procedimiento emitRM emite una instruccion TM
  #  * de registro-a-memoria
  #  * op = el opcode
  #  * r = registro objetivo
  #  * d = el desplazamiento
  #  * s = el registro base
  #  * c = un comentario para imprimirse si TraceCode es TRUE
  #  */
  def emitComment(cadena) #imprime la cadena que se le envia
    if @flag
      puts cadena
    end
  end

  def emitRO(op, r, s, t, c)
    m = @emitloc.to_s + "\t" + op.to_s + "\t" + r.to_s + "\t" + s.to_s + "\t" + t.to_s
    print m
    escribir(m)
    #print emitloc,op,r,s,t
    @emitloc = @emitloc + 1
    emitComment(c) #un comentario para ser impreso si "TraceCode" ->flag es TRUE

    if @highemitloc < @emitloc
      @highemitloc = @emitloc
    end
  end

  def emitRM(op, r, d, s, c) # inserción y extracción de esta pila,  emite una instrucción CM 
    m = @emitloc.to_s + "\t" + op.to_s + "\t" + r.to_s + "\t" + d.to_s + "\t" + s.to_s
    print m
    escribir(m)
    #print emitloc, op, r, d, s
    @emitloc = @emitloc + 1
    emitComment(c)
    #print("\n")

    if @highemitloc < @emitloc 
      @highemitloc = @emitloc
    end
  end

  def emitSkip(howmany) #saltar la sentencia siguiente y grabar su ubicación para ajuste posterior
    i = @emitloc
    @emitloc = @emitloc + howmany

    if @highemitloc < @emitloc 
      @highemitloc = @emitloc
    end

    return i
  end
    
  def emitBackup(loc) # respalda a loc = una localidad previamente saltada 
    if loc > @highemitloc 
      emitComment("BUG in emitBackup")
    end

    @emitloc = loc
  end
    
  def emitRestore # restablece la posicidn del código actual a la más alta posición no emitida previamente 
    @emitloc = @highemitloc
  end
    
  def emitRM_Abs(op, r, a, c)
    m = @emitloc.to_s + "\t" + op.to_s + "\t" + r.to_s + "\t" + (a-(@emitloc+1)).to_i.to_s + "\t" + @pc.to_s
    print m
    escribir(m)
    #print emitloc,op,r,(a-(emitloc+1)),pc
    @emitloc = @emitloc + 1

    emitComment(c)

    #print ("\n")
    if @highemitloc < @emitloc
      @highemitloc = @emitloc
    end
  end
end
