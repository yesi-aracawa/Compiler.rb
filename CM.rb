# *********************************************************
# * Archivo: tm.c                                         *
# * La computadora TM ("Compiler Machine")                *
# * Construccidn de compiladores: principios y practica   *
# * Kenneth C. Louden                                     *
# *********************************************************
$stdout.sync = true

class Maquina #acceso a metodos protegidos
  attr_accessor :IADDR_SIZE
  attr_accessor :DADDR_SIZE
  attr_accessor :PC_REG
  attr_accessor :STEPRESULT
  attr_accessor :iMem
  attr_accessor :dMem
  attr_accessor :reg

  # definicion de metodos protegidos
  def initialize
    @IADDR_SIZE = 1024 # incremente para programas grandes
    @DADDR_SIZE = 1024 # incremente para programas grandes
    @PC_REG = 7
    @STEPRESULT = ''

    @iMem = []
    @dMem = []
    @dMem.fill(0, 0..1024)
    @reg = []
    @reg.fill(0, 0..8)

    @dMem[0] = @DADDR_SIZE - 1
  end

  def cargaInstrucciones(ruta) # lee el codigo intermedio
    contenido = File.open(ruta, 'r').read #abre el archivo en lectura
    contenido += "OKAY" # agregado para finalizar cuando ha terminado correctamente

    renglones = contenido.split("\n") #lo divide en renglones por salto de linea formando un arreglo de reglones
    renglones.each do |renglon| #itera sobre el arreglo de renglones
      # puts renglon
      params = renglon.split("\t") #dividiendolo en tabulaciones
      # puts params.to_s
      if params[0] != "final" #al final va a tener una palabra final, así que mientras sea diferente, avanzará
        if ['LD','LDA','LDC','ST','JLT','JLE','JGE','JGT','JEQ','JNE'].include?(params[1]) #pregunta si es alguno de estas etiquetas
          # si es así envía al arreglo iMem 
          @iMem.push({
              'opcode': params[1],
              'r': params[2],
              'd': params[3],
              's': params[4],
              't': nil
          })
        else
            @iMem.push({
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

  def error (msg, lineNo, instNo) # tarata el error
    print lineNo
    if instNo >= 0
      print 'Instruccion' + instNo
    end
    print msg
    return 0
  end

  def inicio # si el procedimiento es correcto
    #print @iMem
    @STEPRESULT = 'OKAY'
    while @STEPRESULT == 'OKAY' do
      @STEPRESULT = ejecutarPaso() # ejecuta la funcion
    end
  end

  def ejecutarPaso
    pc = @reg[@PC_REG]
    @reg[@PC_REG] = pc + 1

    instActual = @iMem[pc]

    if instActual.has_key?(:d) # si contiene d
      r = instActual[:r]
      s = instActual[:s]
      if instActual[:d].class != Float
        m = (instActual[:d]).to_i + @reg[s.to_i]
      else
        m = Float(instActual[:d]) + @reg[s.to_i]
      end
    else
      r = instActual[:r]
      s = instActual[:s]
      t = instActual[:t]
    end

    if instActual[:opcode] == 'HALT'
      print instActual[:opcode] + ' ' + r.to_s + ' ' + s.to_s + ' ' + t.to_s
      return 'HALT'
    elsif instActual[:opcode] == 'ADD'
      @reg[r.to_i] = @reg[s.to_i] + @reg[t.to_i]
    elsif instActual[:opcode] == 'SUB'
      @reg[r.to_i] = @reg[s.to_i] - @reg[t.to_i]
    elsif instActual[:opcode] == 'MUL'
      @reg[r.to_i] = @reg[s.to_i] * @reg[t.to_i]
      #print 'a'
    elsif instActual[:opcode] == 'DIV'
      if @reg[t.to_i] == 0
        return 'ZERODIVIDE'
      else
        @reg[r.to_i] = @reg[s.to_i] / @reg[t.to_i]
      end
    elsif instActual[:opcode] == 'LD'
      @reg[r.to_i] = @dMem[m.to_i]
    elsif instActual[:opcode] == 'ST'
      @dMem[m.to_i] = @reg[r.to_i]
    elsif instActual[:opcode] == 'LDA'
      @reg[r.to_i] = m.to_i
    elsif instActual[:opcode] == 'LDC'
      if (eval(instActual[:d])).class == Float
        @reg[r.to_i] = Float(instActual[:d])
      else
        @reg[r.to_i] = (instActual[:d]).to_i
      end
    elsif instActual[:opcode] == 'JLT'
      if @reg[r.to_i] < 0
        @reg[@PC_REG] = m.to_i
      end
    elsif instActual[:opcode] == 'JLE'
      if @reg[r.to_i] <= 0
        @reg[@PC_REG] = m.to_i
      end
    elsif instActual[:opcode] == 'JGT'
      if @reg[r.to_i] > 0
        @reg[@PC_REG] = m.to_i
      end
    elsif instActual[:opcode] == 'JGE'
      if @reg[r.to_i] >= 0
        @reg[(@PC_REG).to_i] = m.to_i
      end
    elsif instActual[:opcode] == 'JEQ'
      if @reg[r.to_i] == 0
        @reg[@PC_REG] = m.to_i
      end
    elsif instActual[:opcode] == 'JNE'
      if @reg[r.to_i] != 0
        @reg[@PC_REG] = m.to_i
      end
    elsif instActual[:opcode] == 'IN'
      print 'CIN>>'
      begin #excepcion
        dato = gets #a la espera de la escritura
        #tipo = @hash.get()
        if dato.class == Float # si es de tipo float
          @reg[(instActual[:r]).to_i] = dato.to_f
        else
          @reg[(instActual[:r]).to_i] = dato.to_i
        end
      rescue StandardError => e
        #print e
        return 'INVALID VALUE'
      end
    elsif instActual[:opcode] == 'OUT'
      b = (instActual[:r]).to_i
      # @reg[@PC_REG] = m.to_i
      puts 'OUT>> ' + (@reg[b]).to_s # envia la salida
    end

    return 'OKAY'
  end
end
maquina = Maquina.new
maquina.cargaInstrucciones('code_interm.txt')
maquina.inicio
