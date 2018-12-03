# /*********************************************************/
# /* Archivo: cgen.c                                       */
# /* La implementacion del generador de codigo             */
# /* para el compilador TINY                               */
# /* (genera codigo para la maquina CM)                    */
# /* Construccion de compiladores: principios y practica   */
# /* Kenneth C. Louden                                     */
# /*********************************************************/
require './semantica'
$stdout.sync = true

# tmpOffset es el desplazamiento de memoria para elementos temporales
#  se decrementa cada vez que un elemento temporal es
#  almacenado, y se incrementa cuando se carga de nuevo
class Codegen
  attr_accessor :tmp_offset
  attr_accessor :flag
  attr_accessor :emitloc
  attr_accessor :highemitloc
  attr_accessor :ac
  attr_accessor :ac1
  attr_accessor :gp
  attr_accessor :mp
  attr_accessor :pc
  attr_accessor :code

  def initialize
    @tmp_offset = 0 # desplazamiento de memoria
    @flag = false # tracecode
    @emitloc = 0 # localidad para emision de la instruccion actual
    @highemitloc = 0 # localidad mas alta emitida hasta ahora
    @ac = 0 # acumuladores
    @ac1 = 1 # segundo acumulador
    @gp = 5 # puntero global
    @mp = 6 # puntero de memoria
    @pc = 7 # contador de programa
    @code = ''
  end

  # inicializa la generacion del codigo, recibe arbol sintactico
  def code_gen(nodo)
    emit_comment('Complete Compilation to CM Code')
    emit_comment("File:code_interm.tm\n")
    emit_comment('Standard prelude:')
    emit_RM('LD', @mp, 0, @ac, 'load maxaddress from location 0')
    emit_RM('ST', @ac, 0, @ac, 'clear location 0')
    emit_comment('End of standard prelude.')
    nodo.hijos.each do |hijo|
      if hijo.gram == 'sentencia'
        postorden(:gen_stmt, hijo)
      elsif hijo.gram == 'declaracion'
        postorden(:gen_stmt, hijo)
      end
    end
    emit_comment('End of execution.')
    emit_RO('HALT', 0, 0, 0, '')
    escribir
  end

  # escribe sobre el archivo de generacion de codigo intermedio
  def escribir
    @code += "\n"
    File.open('code_interm.txt', 'w') do |f2|
      f2.puts @code.to_s
    end
  end

  # Genarador de codigo recursivo interno
  def postorden(func, nodo)
    return if nodo.nil?
    return if nodo['token'].nil?
    
    case nodo.token['val']
    when 'if' # distingue entre las clases de sentencia
      emit_comment('-> if')
      postorden(:gen_exp, nodo['hijos'][0]) # realiza llamadas recursivas a c_gen
      # saved_loc1 = emit_skip(1)
      emit_comment('if: jump to else belongs here')

      postorden(:gen_stmt, nodo['hijos'][1])
      postorden(:gen_stmt, nodo['hijos'][2]) unless nodo['hijos'][2].nil?
      return
      # saved_loc2 = emit_skip(1)
      # emit_comment('if: jump to end belongs here')
      # current_loc = emit_skip(0)
      # emit_backup(saved_loc1)
      # emit_RM_Abs('JEQ', @ac, current_loc, 'if: jmp to else')
      # emit_restore

      # postorden(:gen_stmt, nodo['hijos'][2])
      # current_loc = emit_skip(0)
      # emit_backup(saved_loc2)
      # emit_RM_Abs('LDA', @pc, current_loc, 'jmp to end')
      # emit_restore
      # emit_comment('<- if')
    when 'do'
      #emit_comment('-> do')
      #saved_loc1 = emit_skip(0)
      #emit_comment('do: jump after body comes back here')
      postorden(:gen_stmt, nodo['hijos'][0])
      postorden(:gen_exp, nodo['hijos'][1])
      #emit_RM_Abs('JEQ', @ac, saved_loc1, 'do: jmp back to body')
      #emit_comment('<- do')
      return
    when 'while'
      # loc1 = emit_skip(0)
      postorden(:gen_exp, nodo['hijos'][0])
      postorden(:gen_stmt, nodo['hijos'][1])
      return
    end

     # loc2 = emit_skip(1)
     # postorden(:gen_stmt, nodo['hijos'][1])
     #  current_loc = emit_skip(0)
      # emit_backup(loc2)
      # emit_RM_Abs('JEQ', @ac, (current_loc + 1), '')
      # if fBreak:
      #    emit_backup(b)
      #    emit_RM_Abs('LDA', @pc, (current_loc + 1))
      #    fBreak = False
      send(func, nodo) unless nodo.nil?
    end
     # emit_restore
      #emit_RM_Abs('LDA', @pc, loc1, '')
      def gen_stmt(nodo)
        case nodo.token['val']
    when 'read'
        # LDA
      emit_RO('IN', @ac, 0, 0, 'read integer value')
      # TODO: print HaAsh.st_lookup(nodo.attr), 'hellow', nodo.attr
      # TODO: loc = HaAsh.st_lookup(nodo.attr)
      emit_RM('ST', @ac, 0, @gp, 'read: store value')
    when 'write'
      nodo.hijos.each do |hijo|
        postorden(:gen_exp, hijo)
      end
      emit_RO('OUT', @ac, 0, 0, 'write ac')
      # when 'bloque'
      #   c_gen(nodo['hijos'][0])
    else
      if nodo.token.val == ':='
        emit_comment('-> assign')
        emit_RM_Abs('LDA', @pc, 0, '')
        postorden(:gen_exp, nodo['hijos'][1])
        emit_RM('ST', @ac, 0, @gp, 'store value')
        # TODO: loc = HaAsh.st_lookup(nodo.attr)
        # TODO: emit_RM('ST', @ac, loc, @gp, 'assign: store value')
      elsif nodo.token['val'] == '{'
        nodo.hijos.each do |hijo|
          postorden(:gen_stmt, hijo)
        end
      end
        # print nodo.token['val']
      end
    end

  # genera un codigo para un nodo de expresion
  def gen_exp(nodo)
   
      case nodo.token.val
      when '+'
        postorden(:gen_exp, nodo['hijos'][0])
        postorden(:gen_exp, nodo['hijos'][1])
        emit_RO('ADD', @ac, @ac1, @ac, 'op +')
      when '++'
        postorden(:gen_exp, nodo['hijos'][0])
      when '-'
        postorden(:gen_exp, nodo['hijos'][0])
        postorden(:gen_exp, nodo['hijos'][1])
        emit_RO('SUB', @ac, @ac1, @ac, 'op -')
      when '--'
        postorden(:gen_exp, nodo['hijos'][0])
      when '*'
        postorden(:gen_exp, nodo['hijos'][0])
        postorden(:gen_exp, nodo['hijos'][1])
        emit_RO('MUL', @ac, @ac1, @ac, 'op *')
      when '/'
        postorden(:gen_exp, nodo['hijos'][0])
        postorden(:gen_exp, nodo['hijos'][1])
        emit_RO('DIV', @ac, @ac1, @ac, 'op /')
      when '%'
        postorden(:gen_exp, nodo['hijos'][0])
        postorden(:gen_exp, nodo['hijos'][1])
        emit_RO('MOD', @ac, @ac1, @ac, 'op %')
      when '<'
        postorden(:gen_exp, nodo['hijos'][0])
        postorden(:gen_exp, nodo['hijos'][1])
        emit_RO('SUB', @ac, @ac1, @ac, 'op <')
        emit_RM('JLT', @ac, 2, @pc, 'br if true')
        emit_RM('LDC', @ac, 0, @ac, 'false case')
        emit_RM('LDA', @pc, 1, @pc, 'unconditional jmp')
        emit_RM('LDC', @ac, 1, @ac, 'true case')
      when '<='
        postorden(:gen_exp, nodo['hijos'][0])
        postorden(:gen_exp, nodo['hijos'][1])
        emit_RO('SUB', @ac, @ac1, @ac, 'op <=')
        emit_RM('JLE', @ac, 2, @pc, 'br if true')
        emit_RM('LDC', @ac, 0, @ac, 'false case')
        emit_RM('LDA', @pc, 1, @pc, 'unconditional jmp')
        emit_RM('LDC', @ac, 1, @ac, 'true case')
      when '>'
        postorden(:gen_exp, nodo['hijos'][0])
        postorden(:gen_exp, nodo['hijos'][1])
        emit_RO('SUB', @ac, @ac1, @ac, 'op >')
        emit_RM('JGT', @ac, 2, @pc, 'br if true')
        emit_RM('LDC', @ac, 0, @ac, 'false case')
        emit_RM('LDA', @pc, 1, @pc, 'unconditional jmp')
        emit_RM('LDC', @ac, 1, @ac, 'true case')
      when '>='
        postorden(:gen_exp, nodo['hijos'][0])
        postorden(:gen_exp, nodo['hijos'][1])
        emit_RO('SUB', @ac, @ac1, @ac, 'op >=')
        emit_RM('JGE', @ac, 2, @pc, 'br if true')
        emit_RM('LDC', @ac, 0, @ac, 'false case')
        emit_RM('LDA', @pc, 1, @pc, 'unconditional jmp')
        emit_RM('LDC', @ac, 1, @ac, 'true case')
      when '=='
        postorden(:gen_exp, nodo['hijos'][0])
        postorden(:gen_exp, nodo['hijos'][1])
        emit_RO('SUB', @ac, @ac1, @ac, 'op ==')
        emit_RM('JEQ', @ac, 2, @pc, 'br if true')
        emit_RM('LDC', @ac, 0, @ac, 'false case')
        emit_RM('LDA', @pc, 1, @pc, 'unconditional jmp')
        emit_RM('LDC', @ac, 1, @ac, 'true case')
      when '!='
        postorden(:gen_exp, nodo['hijos'][0])
        postorden(:gen_exp, nodo['hijos'][1])
        emit_RO('SUB', @ac, @ac1, @ac, 'op !=')
        emit_RM('JNE', @ac, 2, @pc, 'br if true')
        emit_RM('LDC', @ac, 0, @ac, 'false case')
        emit_RM('LDA', @pc, 1, @pc, 'unconditional jmp')
        emit_RM('LDC', @ac, 1, @ac, 'true case')
      else
        case nodo.token.tipo
        when 'identificador'
          # emit_comment('-> Ident')
          emit_RM('LOD', @ac, 0, 0, 'load Id')
        when 'cadena'
          # TODO: jkj
          # emit_comment('-> Const')
          # genera el codigo para cargar constante
          emit_RM('LDC', @ac, 0, 0, 'load const')
          # emit_comment('<- Const')
        when 'booleano'
          # emit_comment('-> Const')
          emit_RM('LDC', @ac, nodo.token.val, 0, 'load const')
          # emit_comment('<- Const')
        when 'real', 'entero'
          # emit_comment('<- Const')
          # genera el codigo para cargar constante
          emit_RM('LDC', @ac, nodo.token.val, 0, 'load const')
          # emit_comment('<- Const')
        else
        puts 'Error: ' + nodo.token
        exit
        # emit_comment('BUG: Unknown operator')
      end
       # emit_comment('BUG: Unknown operator')
      # emit_comment('<- Op') if @flag
    end
  end

  # /* El procedimiento emit_RM emite una instruccion TM
  #  * de registro-a-memoria
  #  * op = el opcode
  #  * r = registro objetivo
  #  * s = el registro base
  #  * t = registro
  #  * d = el desplazamiento
  #  * c = un comentario para imprimirse si TraceCode es TRUE
  #  */
   # imprime la cadena que se le envia
   def emit_comment(cadena)
    puts cadena if @flag
   end

  def emit_RO(op, r, s, t, c)
    m = @emitloc.to_s + "\t"
    m += op.to_s + "\t" + r.to_s + "\t" + s.to_s + "\t" + t.to_s + "\n"
    puts m
    @code += m

    # print emitloc,op,r,s,t
    @emitloc += 1
    emit_comment(c) # un comentario para ser impreso si "TraceCode"->flag es TRUE

    @highemitloc = @emitloc if @highemitloc < @emitloc
  end

  # insercion y extraccion de esta pila,  emite una instruccion CM
  def emit_RM(op, r, d, s, c)
    m = @emitloc.to_s + "\t"
    m += op.to_s + "\t" + r.to_s + "\t" + d.to_s + "\t" + s.to_s + "\n"
    puts m
    @code += m
    # print emitloc, op, r, d, s
    @emitloc += 1

    @highemitloc = @emitloc if @highemitloc < @emitloc
  end

  def emit_RM_Abs(op, r, a, c)
    m = @emitloc.to_s + "\t" + op.to_s + "\t" + r.to_s + "\t"
    m += (a - (@emitloc + 1)).to_s + "\t" + @pc.to_s + "\n"
    puts m
    @code += m
    # print emitloc,op,r,(a-(emitloc+1)),pc
    @emitloc += 1
    emit_comment(c)

    # print ("\n")
    @highemitloc = @emitloc if @highemitloc < @emitloc
  end

  # saltar la sentencia siguiente y grabar su ubicacion para ajuste posterior
  def emit_skip(howmany)
    i = @emitloc
    @emitloc += howmany
    @highemitloc = @emitloc if @highemitloc < @emitloc
    return i
  end

  # respalda a loc = una localidad previamente saltada
  def emit_backup(loc)
    emit_comment('BUG in emit_backup') if loc > @highemitloc
    @emitloc = loc
  end

  # restablece la posicidn del codigo actual a la mas alta posicion
  # no emitida previamente
  def emit_restore
    @emitloc = @highemitloc
  end
end
