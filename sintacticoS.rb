Nodo = Struct.new(:val,:tipo,:padre,:hijos) do #nodo estructura
    def to_s
        "{ val: #{val}, tipo: #{tipo}, padre: #{padre.to_s}, hijos: #{hijos}"
    end
end

#primer commit prueba
$tokens = []
$leng = 0
$pos = 0
$arbol = ""
$error = ""

class Sintactico
    def init(tokensArgs)
        $pos = 0
        $leng = tokensArgs.length
        $tokens = tokensArgs
        
        padre = Nodo.new('','', nil, [])
        padre = principal(padre, "programa")
        $arbol = printa(padre, "", true, "")
        #puts $arbol
        
        File.open('sintactico.txt', 'w') do |f1|
            f1.puts $arbol.to_s 
        end
        File.open('erroresS.txt', 'w') do |f2|
            f2.puts $error.to_s 
        end
        return padre, $error
    end
    
    def validar(val)
        if $pos >= $leng
            #puts "Se encontro fin del archivo en lugar de '" + val + "'"
            #exit()
        elsif $tokens[$pos].val != val
            $error = $error + "Error: '" + $tokens[$pos].to_s + "' se esperaba '" + val + "'" + "linea" +$tokens[$pos].lin.to_s  + "\n"
            #puts "Error: '" + $tokens[$pos].to_s + "' se esperaba '" + val + "'"
        end
        $pos = $pos + 1
    end
    
    def principal(padre, gram)
        este = Nodo.new(gram,'', padre, [])
        case gram
        when "programa"
            validar("main")
            validar("{")
            principal(este, "ld")
            principal(este, "ls")
            validar("}")
            if $pos >= $leng
                #puts "Se cerraron todas las llaves, a partir del token " + $tokens[$pos].to_s + " ya no se ejecuto"
            end
        when "ld"
            while $pos < $leng-1 && ($tokens[$pos].val == "float" || $tokens[$pos].val == "integer" || $tokens[$pos].val == "bool")
                padre.hijos.push(principal(padre, "tipo"))
            end
        when "tipo"
            este.val = $tokens[$pos].val
            $pos = $pos + 1
            #**LV
            while $pos < $leng-1 && $tokens[$pos].tipo == "identificador"
                este.hijos.push(Nodo.new($tokens[$pos].val, $tokens[$pos].tipo, este, []))
                $pos = $pos + 1
                if $tokens[$pos].val != ";"
                    validar(",")
                end
            end
            #******terminaLV
            validar(";")       
        when "ls"
            while $pos < $leng - 1 && $tokens[$pos].val != "}" && $tokens[$pos].val != ";"
                padre.hijos.push(principal(padre, "sentencia"))
            end
        when "sentencia"
            if $tokens[$pos].tipo == "identificador"
                este.val=":="
                este.hijos.push(Nodo.new($tokens[$pos].val, $tokens[$pos].tipo, este, []))
                $pos = $pos + 1
                if $tokens[$pos].val == "--" 
                    este.hijos[0].hijos.push(Nodo.new("-", $tokens[$pos].tipo, este.hijos[0], [Nodo.new($tokens[$pos-1].val, $tokens[$pos-1].tipo, este.hijos[0].hijos[0], []),Nodo.new("1","entero", este.hijos[0].hijos[0], [])]))
                    $pos = $pos + 1
                elsif $tokens[$pos].val == "++"
                    este.hijos[0].hijos.push(Nodo.new("+", $tokens[$pos].tipo, este.hijos[0], [Nodo.new($tokens[$pos-1].val, $tokens[$pos-1].tipo, este.hijos[0].hijos[0], []),Nodo.new("1","entero", este.hijos[0].hijos[0], [])]))
                    $pos = $pos + 1
                elsif $tokens[$pos].val == ":="
                    $pos = $pos + 1
                    este.hijos.push(principal(este,"exp"))
                else
                    este = Nodo.new("","",este.padre,[])
                    while $pos < $leng -1 && $tokens[$pos].val != ";"
                        $pos = $pos + 1
                    end
                end
                validar(";")
            else
                este.val = $tokens[$pos].val
                $pos = $pos + 1
                case $tokens[$pos-1].val
                when "if"
                    validar("(")
                    este.hijos.push(principal(este, "exp"))
                    validar(")")
                    validar("then")
                    este.hijos.push(principal(este, "{"))
                    if $tokens[$pos].val == "else"
                        if $tokens[$pos+1].val == "{" #PUEDE SER "ELSE" Y AUN ASI ENTRA :S
                            $pos = $pos + 1
                            este.hijos.push(principal(este, "{"))
                        else
                            puts "error se esperaba { "
                            $pos = $pos + 1
                            while $tokens[$pos].tipo != "palReservada"
                                $pos = $pos + 1
                            end
                        end
                    end
                when "while"
                    validar("(")
                    este.hijos.push(principal(este, "exp"))
                    validar(")")
                    este.hijos.push(principal(este, "{"))
                when "do"
                    este.hijos.push(principal(este, "{"))
                    puts "ºººººº" + $pos.to_s + " " + $leng.to_s + " " + $tokens[$pos].val + " " + $tokens[($pos-2)..($pos+2)].to_s
                    if  $tokens[$pos].val == "until"
                        $pos = $pos + 1
                        if  $tokens[$pos].val == "("
                            $pos = $pos + 1
                            este.hijos.push(principal(este, "exp"))
                            if  $tokens[$pos].val == ")"
                                $pos = $pos + 1
                                if $tokens[$pos].val == ";"
                                    $pos = $pos + 1
                                else
                                    puts "error en ; o )"
                                end
                            else
                                puts "error despues de ("
                            end
                        else
                            puts "error despues de until"
                        end
                    else
                        puts "error en despues de {"
                    end
                when "read"
                    este.hijos.push(Nodo.new( $tokens[$pos].val, $tokens[$pos].tipo, este, []))
                    $pos = $pos + 1
                    validar(";")
                when "write"
                    if $tokens[$pos].tipo != "cadena"
                        puts "Error: '" + $tokens[$pos].to_s + "' se esperaba una cadena"
                        este = Nodo.new("","",este.padre,[])
                        while $pos < $leng-1 && $tokens[$pos].val != ";"
                            $pos = $pos + 1
                        end
                        $pos = $pos + 1
                    else
                        este.hijos.push(Nodo.new($tokens[$pos].val, $tokens[$pos].tipo,este, []))
                        $pos = $pos + 1
                        if $tokens[$pos].val == ","
                            while  $tokens[$pos].val == ","
                                $pos = $pos + 1
                                este.hijos.push(principal(este, "exp"))
                            end
                        elsif  $tokens[$pos].val != ";"
                            puts "Error: '" + $tokens[$pos].to_s + "' se esperaba ;"
                            este = Nodo.new("","",este.padre,[])
                            while $pos < $leng && $tokens[$pos].val != ";"
                                $pos = $pos + 1
                            end
                            $pos = $pos + 1
                        end
                    end
                    validar(";")
                else
                    este = Nodo.new("","",este.padre,[])
                    while $pos < $leng -1 && $tokens[$pos].val != ";"
                        $pos = $pos + 1
                    end
                    $pos = $pos + 1
                end
            end
        when "{"
            validar("{")
            principal(este, "ls")
            validar("}")
        when "exp"
            r = $pos
            paren = 0
            while $pos < $leng-1 && $tokens[$pos].val != ';'
                if $tokens[$pos].val=="("
                    paren = paren+1
                elsif $tokens[$pos].val==")"
                    paren = paren-1
                    if paren == -1
                        break
                    end
                end
                $pos = $pos + 1
            end

            fin = $pos - 1
            este = inorden(este.padre,$tokens[r..fin],"exp")
        when "rel", "opsum", "opmul"
            este.val = $tokens[$pos].val
            $pos = $pos + 1
        else
            puts "Error: '" + $tokens[$pos].to_s + "' no es un valor valido"
        end
        return este
    end
    
    def printa(padre, ident, esUltimo, str)
        espacio = ""
        len = padre.hijos.length
        if padre.val != "" 
            if esUltimo
                str = str + "" + ident + "" + padre.val + "\n"
                espacio = " "
            else
                str = str + "" + ident + "" + padre.val + "\n"
                espacio = " "
            end
        end
        i = 0
        while i < len-1
            str = printa(padre.hijos[i], ident + espacio, false, str)
            i = i + 1
        end 
        if len > 0
            str = printa(padre.hijos[len-1], ident + espacio, true, str)
        end
        return str
    end
    
    def inorden(padre, rango, gram)
        paren=0
        este=Nodo.new("", "", padre, [])
        if rango.length < 1
            return este
        end
        i=rango.length-1
        bandera=false
        case gram
        when "exp"
            #puts "----->" + rango.to_s
            while i>=0 
                if rango[i].val==")"
                    paren = paren + 1
                elsif rango[i].val=="("
                    paren = paren-1
                elsif rango[i].val == ">"||rango[i].val == ">="||rango[i].val == "<"||rango[i].val == "<="||rango[i].val == "=="||rango[i].val == "!="
                    if paren == 0
                        bandera = true
                        break
                    end
                end
                i = i-1
            end
            if bandera
                este.hijos=[]
                este.hijos.push(inorden(este, rango[0..(i-1)], "exps"))
                este.val=rango[i].val
                este.hijos.push(inorden(este, rango[(i+1)..(rango.length-1)], "exps"))
            else
                este=inorden(este, rango, "exps")
            end
        when "exps"
            while i>=0
                if rango[i].val==")"
                    paren = paren + 1
                elsif rango[i].val=="("
                    paren = paren-1
                elsif rango[i].val == "+"||rango[i].val == "-"
                    if paren == 0
                        bandera = true
                        break
                    end
                end
                i = i-1
            end
            if bandera
                este.hijos.push(inorden(este, rango[0..(i-1)], "exps"))
                este.val=rango[i].val
                este.hijos.push(inorden(este, rango[(i+1)..(rango.length-1)], "term"))
            else
                este=inorden(este, rango, "term")
            end
        when "term"
            while i>=0 
                if rango[i].val==")"
                    paren = paren + 1
                elsif rango[i].val=="("
                    paren = paren-1
                elsif rango[i].val == "*"||rango[i].val == "/"||rango[i].val == "%"
                    if paren == 0
                        bandera = true
                        break
                    end
                end
                i = i-1
            end
            if bandera
                este.hijos.push(inorden(este, rango[0..(i-1)], "term"))
                este.val=rango[i].val
                este.hijos.push(inorden(este, rango[(i+1)..(rango.length-1)], "fact"))
            else
                este=inorden(este, rango, "fact")
            end
        when "fact"
            cont = 0
            if rango[0].val == "(" && rango[rango.length-1].val == ")"
                este.hijos.push(inorden(este, rango[1..(rango.length-2)], "exps"))    
            elsif rango[0].tipo == "identificador" || rango[0].tipo == "entero" || rango[0].tipo == "real" || rango[0].val == "true" or rango[0].val == "false"
                este.val = rango[0].val
            else
                puts"Error: '" + rango[0].to_s + "' no es un valor valido"
            end
        end
        return este
    end
end