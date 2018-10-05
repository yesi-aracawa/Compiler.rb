TOKEN = Struct.new(:val,:tipo,:lin) do #token a mostrar con sus propiedades
    def to_s
      col_val = "\e[1m\e[32m"
      col_tip = "\e[1;36m"
      col_lin = "\e[1m\e[31m"
      "TOKEN: {#{col_val}val:'#{val}'\e[0m, #{col_tip}tipo:#{tipo}\e[0m, #{col_lin}lin:#{lin}\e[0m}"
    end
    def inspect
      to_s
    end
end

class Lexico
  
  def lexico(archivo)
    $lin = 1
    $num=/[0-9]/#expresion regular para un $numero
    $CaracterNoNum = /\D/
    $CaracterNoletraONum = /\W/
    $caractEspacios =/\s/ #carácter de espacio; es lo mismo que [ \t\n\r\f]
    $letra = /[a-z]|[A-Z]/
    ident=/^([a-z]|[A-Z])([a-z]|[A-Z]|[0-9]|_)*/ #expresion regular para saber si es identificador
    tokens = []
    $strtk = ""
    $lib = ""
    def reservada
      case $value
      when 'main', 'if', 'then', 'else', 'end', 'do','while','repeat', 'until', 'read', 'write', 'float', 'integer', 'bool'
        $tipo = "palReservada"
      else
        $tipo = "identificador"
      end
    end
    
    $cad = ""
    
    
    
    $cad2 = ""
    $cont  = 1
    $cad = File.open(archivo,'r').read
    #puts $cad.bytes.to_a
    $pos = 0
    $lengcad = $cad.length
    $value = "" #guardar
    $caracter = ''#pocisionar
    $tipo = ""#identificardocker
    $save = true
    #puts $cad
    def valpospp
      $value = $value + $caracter
      $pos =$pos + 1
    end
    
    while $pos < $lengcad 
      # puts $value + " " + $tipo
      $value = "" #guardar
      $tipo = ""#identificar
      $caracter = $cad[$pos]#pocisionar
      $err=0
      #puts $lengcad
      # puts $pos.to_s + " " + $caracter
      #puts $caracter.bytes.to_a.to_s + " " + $caracter
      
      if $caracter.match($letra)  
        while $pos < $lengcad && ($caracter.match($letra) ||  $caracter.match($num) || $caracter == '_')
          # puts '*'
          valpospp
          $caracter = $cad[$pos]
        end
        reservada
      elsif $caracter.match($num)
        # ****************************<- colocar al final porque debe revisar que no contenga ptro caracter diferente despues y considerar el error posible
        #tipo, debe de tener un valo cuando haya cumplido con el automata (al final)
        ya_hay_un_punto = false
        while $pos < $lengcad && $caracter.match($num)  
          valpospp
          $caracter = $cad[$pos]
          #puts '+'
          if $caracter == '.' && $cad[$pos+1].match($num) && ya_hay_un_punto == false
            ya_hay_un_punto = true
            valpospp
            $caracter = $cad[$pos]
            $tipo ="real"
          end
        end
        
        if $tipo != "real"
          $tipo = "entero" 
        end
      elsif $caracter.bytes.to_a[0] == 10
        # puts ".--------POS" + ($pos).to_s
        $lin = $lin +  1
        $cont = $cont + 1
        $pos = $pos + 1
        next
        # puts '[?] - ' + $tipo
      else # si no es $letra y no es $numero ... evalua los siguientes $caracteres
        case $caracter
        when  '"'
          $pos = $pos +1
          $caracter = $cad[$pos]
          while $pos < $lengcad && ($caracter != '"')
            valpospp
            $caracter = $cad[$pos]
          end
          $pos = $pos +1
          $tipo = "cadena"
        when ':'
          valpospp
          $caracter = $cad[$pos]
          if $caracter == '='
            valpospp
            $tipo = "asignacion"
          end
        when '!'
          valpospp
          $caracter = $cad[$pos]
          if $caracter == '='
            valpospp
            $tipo = "diferente"
          end
        when '+'
          valpospp
          $caracter = $cad[$pos]
          if $caracter == '+'
            valpospp 
            $tipo = "incremento"
          else
            $tipo = "suma"
          end
        when '-'
          valpospp
          $caracter = $cad[$pos]
          if $caracter == '-'
            valpospp 
            $tipo = "decremento"
          else
            $tipo = "resta"
          end
        when '%'
          valpospp
          $tipo = "modulo"
        when '/' #comentarios y division
          if $cad[$pos+1] == '/' 
            $pos = $pos + 1
            puts "aqui hay comentario"
            while $pos < $lengcad && !($cad[$pos].bytes.to_a[0] == 10)
              #puts "no se ha cerrado comentario"
              $pos = $pos +1
            end
            $pos = $pos +1
            puts "Salio"
            $caracter = $cad[$pos]
            next
          elsif $cad[$pos+1] == '*'
            $pos = $pos +2
            while $pos < $lengcad && !($cad[$pos] == '*' && $cad[$pos+1] == '/')
              $pos = $pos +1
              $caracter = $cad[$pos]
            end
            $pos = $pos +2
            $caracter = $cad[$pos]
            next
          else
            $tipo = "division"          
            valpospp
          end # fin de comentarios y division
        when '<'
          valpospp
          $caracter = $cad[$pos]
          if $caracter == '='
            $tipo = "menorIgual"
            valpospp
          else
            $tipo = "menor"
          end
        when '>'
          valpospp
          $caracter = $cad[$pos]
          if $caracter == '='
            $tipo = "mayorIgual"
            valpospp
          else
            $tipo = "mayor"
          end
        when '='
          valpospp
          $caracter = $cad[$pos]
          if $caracter == '='
            valpospp
            $tipo = "igualIgual"
          end
        when '('
          valpospp
          $tipo = "ParIzq"
        when ')'
          valpospp
          $tipo = "ParDer"
        when '{'
          valpospp
          $tipo = "LlaveIzq"
        when '}'
          valpospp 
          $tipo = "LlaveDer"
        when '*'
          valpospp
          $tipo = "multiplicacion"
        when ','
          valpospp
          $tipo = "coma"
        when ';'
          valpospp
          $tipo = "puntoComa"
        when ' ','\t','\f'
          $cont = $cont + 1
          $pos = $pos + 1
          next
          puts "###################################"
        else
          if $caracter.bytes.to_a[0].to_s == "9"
            $cont = $cont + 1
            $pos = $pos + 1
            
            next
          else
            $pos = $pos + 1
            next
          end
        end# fin de case (switch)  
      end
      if $tipo != ""
        tokens.push(TOKEN.new($value,$tipo,$lin))
        $strtk = $strtk + " [" + $value + ", " + $tipo + "," + $lin.to_s + "]"+ "\n"
      else
        $cad2 = $cad2 + "Error: " + $cad[($pos-1)..($pos+3)].bytes.to_a.to_s + " :C en el caracter " + $cad[$pos-1] + " con " + $cad[$pos] + " posición: " + $pos.to_s + " linea " + $lin.to_s + "\n"
        $pos = $pos + 1
      end
    end
    #fin de archivo
    File.open('tokens.txt', 'w') do |f1|
      f1.puts $strtk
    end
    #puts $strtk
    File.open('errores.txt', 'w') do |f2|
      f2.puts $cad2
    end
    
    #puts $lin
    if $cad2 != ""
      puts "Errores encontrados:\n" + $cad2
      exit
    end 
    return tokens
  end
  
end