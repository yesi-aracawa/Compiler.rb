# *********************************************************
# * Archivo: tm.c                                         *
# * La computadora TM ("Compiler Machine")                *
# * Construccidn de compiladores: principios y practica   *
# * Kenneth C. Louden                                     *
# *********************************************************
$stdout.sync = true

class Maquina
  # acceso a metodos protegidos
  attr_accessor :IADDR_SIZE
  attr_accessor :DADDR_SIZE
  attr_accessor :PC_REG
  attr_accessor :STEPRESULT
  attr_accessor :i_mem
  attr_accessor :d_mem
  attr_accessor :reg

  # definicion de metodos protegidos
  def initialize
    @IADDR_SIZE = 1024 # incremente para programas grandes
    @DADDR_SIZE = 1024 # incremente para programas grandes
    @PC_REG = 7
    @STEPRESULT = ''

    @i_mem = []
    @d_mem = []
    @d_mem.fill(0, 0..1024)
    @reg = []
    @reg.fill(0, 0..8)

    @d_mem[0] = @DADDR_SIZE - 1
  end

  # lee el codigo intermedio
  def cargaInstrucciones(ruta)
    contenido = File.open(ruta, 'r').read # abre el archivo en lectura
    # agregado para finalizar cuando ha terminado correctamente
    contenido += 'OKAY'

    # lo divide en renglones por salto de linea formando un arreglo de reglones
    renglones = contenido.split("\n")
    renglones.each do |renglon| # itera sobre el arreglo de renglones
      # puts renglon
      params = renglon.split("\t") # dividiendolo en tabulaciones
      # puts params.to_s

      # al final va a tener una palabra final,
      # asi que mientras sea diferente, avanzara
      if params[0] != 'final'
        # pregunta si es alguno de estas etiquetas
        if %w[LD LDA LDC ST JLT JLE JGE JGT JEQ JNE].include?(params[1])
          # si es asi envia al arreglo i_mem
          @i_mem.push(
          {
            'opcode': params[1],
            'r': params[2],
            'd': params[3],
            's': params[4],
            't': nil
          })
        else
          @i_mem.push(
          {
            'opcode': params[1],
            'r': params[2],
            'd': nil,
            's': params[3],
            't': params[4]
          })
        end
      end
    end
  end

  # trata el error
  def error(msg, line_no, inst_no)
    print line_no
    (print 'Instruccion' + instNo) if inst_no >= 0
    print msg
    return 0
  end

  # si el procedimiento es correcto
  def inicio
    # print @i_mem
    @STEPRESULT = 'OKAY'
    # ejecuta la funcion
    @STEPRESULT = ejecutarPaso() while @STEPRESULT == 'OKAY'
  end

  def ejecutarPaso
    pc = @reg[@PC_REG]
    @reg[@PC_REG] = pc + 1

    current_line = @i_mem[pc]

    r = current_line[:r]
    s = current_line[:s]
    if current_line.has_key?(:d) # si contiene d
      m = if current_line[:d].class != Float
            current_line[:d].to_i + @reg[s.to_i]
          else
            Float(current_line[:d]) + @reg[s.to_i]
          end
    else
      t = current_line[:t]
    end

    if current_line[:opcode] == 'HALT'
      print current_line[:opcode] + ' ' + r.to_s + ' ' + s.to_s + ' ' + t.to_s + "\n"
      return 'HALT'
    elsif current_line[:opcode] == 'ADD'
      @reg[r.to_i] = @reg[s.to_i] + @reg[t.to_i]
    elsif current_line[:opcode] == 'SUB'
      @reg[r.to_i] = @reg[s.to_i] - @reg[t.to_i]
    elsif current_line[:opcode] == 'MUL'
      @reg[r.to_i] = @reg[s.to_i] * @reg[t.to_i]
      # print 'a'
    elsif current_line[:opcode] == 'DIV'
      if @reg[t.to_i].zero?
        return 'ZERODIVIDE'
      else
        @reg[r.to_i] = @reg[s.to_i] / @reg[t.to_i]
      end
    elsif current_line[:opcode] == 'LD'
      @reg[r.to_i] = @d_mem[m.to_i]
    elsif current_line[:opcode] == 'ST'
      @d_mem[m.to_i] = @reg[r.to_i]
    elsif current_line[:opcode] == 'LDA'
      @reg[r.to_i] = m.to_i
    elsif current_line[:opcode] == 'LDC'
      if eval(current_line[:d]).class == Float
        @reg[r.to_i] = current_line[:d].to_f
      else
        @reg[r.to_i] = current_line[:d].to_i
      end
    elsif current_line[:opcode] == 'JLT'
      if @reg[r.to_i] < 0
        @reg[@PC_REG] = m.to_i
      end
    elsif current_line[:opcode] == 'JLE'
      if @reg[r.to_i] <= 0
        @reg[@PC_REG] = m.to_i
      end
    elsif current_line[:opcode] == 'JGT'
      if @reg[r.to_i] > 0
        @reg[@PC_REG] = m.to_i
      end
    elsif current_line[:opcode] == 'JGE'
      if @reg[r.to_i] >= 0
        @reg[@PC_REG.to_i] = m.to_i
      end
    elsif current_line[:opcode] == 'JEQ'
      if @reg[r.to_i].zero?
        @reg[@PC_REG] = m.to_i
      end
    elsif current_line[:opcode] == 'JNE'
      if @reg[r.to_i] != 0
        @reg[@PC_REG] = m.to_i
      end
    elsif current_line[:opcode] == 'IN'
      print "read\n"
      # excepcion
      begin
        dato = gets # a la espera de la escritura
        print "read>>: #{dato}\n"
        # tipo = @hash.get()
        # si es de tipo float
        if dato.class == Float
          @reg[(current_line[:r]).to_i] = dato.to_f
        else
          @reg[(current_line[:r]).to_i] = dato.to_i
        end
      rescue StandardError => e
        # print e
        return 'INVALID VALUE'
      end
    elsif current_line[:opcode] == 'OUT'
      b = current_line[:r].to_i
      # @reg[@PC_REG] = m.to_i
      puts 'write<<: ' + (@reg[b]).to_s + "\n"# envia la salida
    end

    return 'OKAY'
  end
end

maquina = Maquina.new
maquina.cargaInstrucciones('code_interm.txt')
maquina.inicio
print "exit\n"
