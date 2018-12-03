require './tipos.rb'

$num = /[0-9]/ # expresion regular para un $numero
$letra = /[a-z]|[A-Z]/

class Lexico
  attr_accessor :lin
  attr_accessor :tokens
  attr_accessor :strtk
  attr_accessor :cont
  attr_accessor :cad
  attr_accessor :cad1
  attr_accessor :cad2
  attr_accessor :lengcad
  attr_accessor :pos
  attr_accessor :value
  attr_accessor :caracter
  attr_accessor :tipo

  def initialize
    @lin = 1
    @tokens = []
    @strtk = ''
    @cont  = 1
    @cad = ''
    @cad1 = ''
    @cad2 = ''
    @pos = 0
    @value = '' # guardar
    @caracter = '' # pocisionar
    @tipo = '' # identificardocker
  end

  def lexico(archivo)
    @cad = File.open(archivo, 'r').read
    @lengcad = @cad.length

    # itera el archivo
    parse while @pos < @lengcad
    # fin de archivo

    File.open('tokens.txt', 'w') do |f1|
      f1.puts @strtk
    end

    # puts @strtk
    File.open('errores.txt', 'w') do |f2|
      f2.puts @cad2
    end

    # puts @lin
    if @cad2 != ''
      puts "Errores encontrados:\n" + @cad2
      exit
    end

    return @tokens
  end

  def reservada?
    case @value
    when 'main', 'if', 'then', 'else', 'end', 'do', 'while', 'repeat', 'until',
      'read', 'write', 'float', 'integer', 'bool'
      @tipo = 'palReservada'
    when 'true', 'false'
      @tipo = 'booleano'
    else
      @tipo = 'identificador'
    end
  end

  # puts @cad
  def valpospp
    @value += @caracter
    @pos += 1
  end

  def parse
    # puts @value + ' ' + @tipo
    @value = '' # guardar
    @tipo = '' # identificar
    @caracter = @cad[@pos] # pocisionar

    if @caracter.match($letra)
      while @pos < @lengcad && (@caracter.match($letra) \
        || @caracter.match($num) || @caracter == '_')
        # puts '*'
        valpospp
        @caracter = @cad[@pos]
      end
      reservada?
    elsif @caracter.match($num)
      # ***************************<- colocar al final porque debe revisar que
      # no contenga ptro caracter diferente despues y considerar
      # el error posible
      # tipo, debe de tener un valo cuando haya cumplido con el automata
      # (al final)
      ya_hay_un_punto = false
      while @pos < @lengcad && @caracter.match($num)
        valpospp
        @caracter = @cad[@pos]
        # puts '+'
        if @caracter == '.' && @cad[@pos + 1].match($num) && ya_hay_un_punto == false
          ya_hay_un_punto = true
          valpospp
          @caracter = @cad[@pos]
          @tipo = 'real'
        end
      end
      @tipo = 'entero' if @tipo != 'real'
    elsif @caracter.bytes.to_a[0] == 10
      # puts '.--------POS' + (@pos).to_s
      @lin += 1
      @cont += 1
      @pos += 1
      return
      # puts '[?] - ' + @tipo
    else # si no es $letra y no es $numero... evalua los siguientes caracteres
      case @caracter
      when '"'
        @pos += 1
        @caracter = @cad[@pos]
        while @pos < @lengcad && (@caracter != '"')
          valpospp
          @caracter = @cad[@pos]
        end
        @pos += 1
        @tipo = 'cadena'
      when ':'
        valpospp
        @caracter = @cad[@pos]
        if @caracter == '='
          valpospp
          @tipo = 'asignacion'
        end
      when '!'
        valpospp
        @caracter = @cad[@pos]
        if @caracter == '='
          valpospp
          @tipo = 'diferente'
        end
      when '+'
        valpospp
        @caracter = @cad[@pos]
        if @caracter == '+'
          valpospp
          @tipo = 'incremento'
        else
          @tipo = 'suma'
        end
      when '-'
        valpospp
        @caracter = @cad[@pos]
        if @caracter == '-'
          valpospp
          @tipo = 'decremento'
        else
          @tipo = 'resta'
        end
      when '%'
        valpospp
        @tipo = 'modulo'
      when '/' # comentarios y division
        if @cad[@pos + 1] == '/'
          @pos += 1
          puts 'aqui hay comentario'
          while @pos < @lengcad && (@cad[@pos].bytes.to_a[0] != 10)
            # puts 'no se ha cerrado comentario'
            @pos += 1
          end
          @pos += 1
          puts 'Salio'
          @caracter = @cad[@pos]
          return
        elsif @cad[@pos + 1] == '*'
          @pos += 2
          while @pos < @lengcad && !(@cad[@pos] == '*' && @cad[@pos + 1] == '/')
            @pos += 1
            @caracter = @cad[@pos]
          end
          @pos += 2
          @caracter = @cad[@pos]
          return
        else
          @tipo = 'division'
          valpospp
        end # fin de comentarios y division
      when '<'
        valpospp
        @caracter = @cad[@pos]
        if @caracter == '='
          @tipo = 'menorIgual'
          valpospp
        else
          @tipo = 'menor'
        end
      when '>'
        valpospp
        @caracter = @cad[@pos]
        if @caracter == '='
          @tipo = 'mayorIgual'
          valpospp
        else
          @tipo = 'mayor'
        end
      when '='
        valpospp
        @caracter = @cad[@pos]
        if @caracter == '='
          valpospp
          @tipo = 'igualIgual'
        end
      when '('
        valpospp
        @tipo = 'ParIzq'
      when ')'
        valpospp
        @tipo = 'ParDer'
      when '{'
        valpospp
        @tipo = 'LlaveIzq'
      when '}'
        valpospp
        @tipo = 'LlaveDer'
      when '*'
        valpospp
        @tipo = 'multiplicacion'
      when ','
        valpospp
        @tipo = 'coma'
      when ';'
        valpospp
        @tipo = 'puntoComa'
      when ' ', '\t', '\f'
        @cont += 1
        @pos += 1
        return
      else
        @cont += 1 if @caracter.bytes.to_a[0].to_s == '9'
        @pos += 1
        return
      end
      # fin de case (switch)
    end

    if @tipo != ''
      @tokens.push(TOKEN.new(@value, @tipo, @lin))
      @strtk += ' [' + @value + ', ' + @tipo + ',' + @lin.to_s + ']' + "\n"
    else
      @cad2 += 'Error: ' + @cad[(@pos - 1)..(@pos + 3)].bytes.to_a.to_s
      @cad2 += ' :C en el caracter ' + @cad[@pos - 1] + ' con ' + @cad[@pos]
      @cad2 += ' posición: ' + @pos.to_s + ' linea ' + @lin.to_s + "\n"
      @pos += 1
    end
  end
end
