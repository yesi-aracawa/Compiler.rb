Nodo = Struct.new(:val,:tipo,:padre,:hijos) #nodo estructura

$tokens = []
$leng = 0
$pos = 0
$arbol = ""
$banpos = 0

def init(tokensArgs)
    $pos = 0
    $leng = tokensArgs.length
    $tokens = tokensArgs

    padre = Nodo.new('','', nil, [])
    padre = principal(padre, "programa")
    parbol(padre, "", true)
    #puts $arbol

    File.open('sintactico.txt', 'w') do |f1|
        f1.puts $arbol.to_s 
    end
    File.open('erroresS.txt', 'w') do |f2|
        f2.puts $errores.to_s 
    end
    return padre
end

def validar(val)
    if $pos >= $leng
        puts "Se encontro fin del archivo en lugar de '" + val + "'"
        exit()
    elsif $tokens[$pos].val != val
        puts "Error: '" + $tokens[$pos].tipo + ":" + $tokens[$pos].val + "' se esperaba '" + val + "'"
        #puts $tokens[($pos)..($pos+3)].to_s
        #exit()
        $banpos = 1
    end
    $pos = $pos + 1
end

def principal(padre, gram)
    este = Nodo.new(gram,'', padre, [])
    case gram
    when "programa"
        validar("main")
        validar("{")
        #LD
        while $tokens[$pos].val == "float" || $tokens[$pos].val == "integer" || $tokens[$pos].val == "bool"
            este.hijos.push(principal(este, "tipo"))
        end
        #termina LD
        #LS
        while $pos < $leng && $tokens[$pos].val != "}"
            este.hijos.push(principal(este, "sentencia"))
        end
        #termina LS
        validar("}")
        if $pos >= $leng
            puts "Se cerraron todas las llaves, a partir del token " + $tokens[$pos].to_s + " ya no se ejecuto"
        end
    when "tipo"
        este.val = $tokens[$pos].val
        $pos = $pos + 1
        #**LV
        while $tokens[$pos].tipo == "identificador"
            este.hijos.push(Nodo.new($tokens[$pos].val, $tokens[$pos].tipo, este, []))
            $pos = $pos + 1
            if $tokens[$pos].val != ";"
                validar(",")
            end
        end
        #******terminaLV
        validar(";")       
    when "sentencia"
        if $tokens[$pos].tipo == "identificador"
            este.val="asignacion"
            este.hijos.push(Nodo.new($tokens[$pos].val, $tokens[$pos].tipo, este, []))
            $pos = $pos + 1
            if $tokens[$pos].val == "--" 
                este.hijos.push(Nodo.new("-", $tokens[$pos].tipo, este, [Nodo.new($tokens[$pos-1].val, $tokens[$pos].tipo, este.hijos[0], []),Nodo.new("1", $tokens[$pos].tipo, este.hijos[0], [])]))
                $pos = $pos + 1
            elsif $tokens[$pos].val == "++"
                este.hijos.push(Nodo.new("+", $tokens[$pos].tipo, este, [Nodo.new($tokens[$pos-1].val, $tokens[$pos].tipo, este.hijos[0], []),Nodo.new("1", $tokens[$pos].tipo, este.hijos[0], [])]))
                $pos = $pos + 1
            else
                este.val = "asignacion" 
                validar(":=")
                este.hijos.push(principal(este,"exp"))
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
                este.hijos.push(principal(este, "bloque"))
                if $tokens[$pos].val == "else" #PUEDE SER "ELSE" Y AUN ASI ENTRA :S
                    $pos = $pos + 1
                    este.hijos.push(principal(este, "bloque"))
                end
            when "while"
                validar("(")
                este.hijos.push(principal(este, "exp"))
                validar(")")
                este.hijos.push(principal(este, "bloque"))
            when "do"
                este.hijos.push(principal(este, "bloque"))
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
                puts "error en despues de bloque"
                #$pos = $pos + 1
              end
            when "read"
                este.hijos.push(Nodo.new( $tokens[$pos].val, $tokens[$pos].tipo, este, []))
                $pos = $pos + 1
                validar(";")
            when "write"
                if $tokens[$pos].tipo != "cadena"
                    puts "Error: '" + $tokens[$pos].tipo + "," + $tokens[$pos].val + "' se esperaba una cadena"
                    $pos = $pos + 1
                else
                    este.hijos.push(Nodo.new($tokens[$pos].val, $tokens[$pos].tipo,este, []))
                    $pos = $pos + 1
                    while  $tokens[$pos].val == ","
                        $pos = $pos + 1
                        este.hijos.push(principal(este, "exp"))
                    end 
                    validar(";")
                end
            else
                puts "." + $tokens[($pos-1)..($pos+1)].to_s
                while (este.tipo == gram || este.hijos.length == 0) && $pos < $leng
                    este = principal(este.padre, $tokens[$pos].val)
                    return este 
                   # $pos = $pos + 1
                end
                #puts "Error: '" + $tokens[$pos-1].tipo + "," + $tokens[$pos-1].val + "' se esperaba una sentencia"
            end
        end
    when "bloque"
        validar("{")
        #LS
        while $pos < $leng && $tokens[$pos].val != "}"
         este.hijos.push(principal(este, "sentencia"))
        end
        #termina LS
        validar("}")
        if $tokens[$pos].val == ";"
            puts "error en bloque"
            $pos = $pos + 1
        end
    when "exp"
        r = $pos
        este.hijos=[]
        este.hijos.push(principal(este, "exps"))
        if $tokens[$pos].val == "<" || $tokens[$pos].val == ">" || $tokens[$pos].val == "<=" || $tokens[$pos].val == ">=" || $tokens[$pos].val == "==" || $tokens[$pos].val == "!="
            este.hijos.push(principal(este, "rel"))
            este.hijos.push(principal(este, "exps"))

            # aux = este.hijos[1]
            # este.hijos[1] = este.hijos[0]
            # este.hijos[0] = aux
            # aux = este.hijos[2]
            # este.hijos[2] = este.hijos[1]
            # este.hijos[1] = aux
        end
        fin = $pos - 1
        este = inorden(este.padre,$tokens[r..fin],"exp")
    when "exps"
        #__________________________________EXPS______________________________________________________________________________________#
        este.hijos.push(principal(este,"term"))
        if $tokens[$pos].val == "+" || $tokens[$pos].val == "-" #empieza while de exps
            este.hijos.push(principal(este, "opsum"))
            este.hijos.push(principal(este, "exps"))

            # aux = este.hijos[1]
            # este.hijos[1] = este.hijos[0]
            # este.hijos[0] = aux
            # aux = este.hijos[1]
            # este.hijos[1] = este.hijos[0].hijos[0]
            # este.hijos[0].hijos[0] = aux
        end#termina while de exps
        #___________termina EXPS_________________________________________________________________________________________________
    when "term"
        #*******************empieza term**********************************************
        este.hijos.push(principal(este, "fact"))
        if $tokens[$pos].val == "*" || $tokens[$pos].val == "/" || $tokens[$pos].val == "%"
            este.hijos.push(principal(este, "opmul"))
            este.hijos.push(principal(este, "term"))
                
            # aux = este.hijos[1]
            # este.hijos[1] = este.hijos[0]
            # este.hijos[0] = aux
            # aux = este.hijos[1]
            # este.hijos[1] = este.hijos[0].hijos[0]
            # este.hijos[0].hijos[0] = aux
        end
        #***************acaba TERM*******************************************************************
    when "fact"
        ##empieza fact
        if $tokens[$pos].val == "("
            $pos = $pos + 1
            este.hijos.push(principal(este, "exp"))
            validar(")")
        elsif $tokens[$pos].tipo == "identificador" || $tokens[$pos].tipo == "entero" || $tokens[$pos].tipo == "real" || $tokens[$pos].val == "true" or $tokens[$pos].val == "false"
            este.val = $tokens[$pos].val
            $pos = $pos + 1
        else
            puts"Error: '" + $tokens[$pos].to_s + "' no es un valor valido"
            $pos = $pos + 1
        end
        ##termina Fact
    when "rel", "opsum", "opmul"
            este.val = $tokens[$pos].val
            $pos = $pos + 1
    else
        puts "Error: '" + $tokens[$pos].to_s + "' no es un valor valido"
       # este.tipo = ""
    end
    # if $banpos == 1
    #         puts este.val.to_s + "  " + este.tipo.to_s + "\n"
    #         $banpos = 0
    # end
    return este
end

def parbol(padre, ident, esUltimo)
    espacio = ""
    $arbol = $arbol + ident
    if esUltimo
        if padre.val != "" 
            puts "" + ident + "" + padre.val
            $arbol = $arbol + ""
            espacio = " "
        end
    else
        if padre.val != ""
            puts "" + ident + "" + padre.val
            $arbol = $arbol + ""
            espacio = " "
        end
    end
    if padre.val != ""
        $arbol = $arbol +  "" + padre.val + "\n"
    end
    len = padre.hijos.length
    i = 0
    while i < len-1
        parbol(padre.hijos[i], ident + espacio, false)
        i = i + 1
    end 
    if len > 0
        parbol(padre.hijos[len-1], ident + espacio, true)
    end
end

def ast(padre)
    i=0
    hijos = padre.hijos
    while i < padre.hijos.length
        if hijos[i].val == ""
            padre.hijos[i] = ast(padre.hijos[i])
        end
        i = i + 1
    end
    return padre
end

def inorden(padre, rango, gram)
    paren=0
    este=Nodo.new("", "", padre, [])
    rLen=rango.length
    i=rango.length-1
    bandera=false
    case gram
    when "exp"
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
         ##empieza fact
        if rango[0].val == "(" && rango[rango.length-1].val == ")"
            este.hijos.push(inorden(este, rango[1..(rango.length-2)], "exp"))
        elsif rango[0].tipo == "identificador" || rango[0].tipo == "entero" || rango[0].tipo == "real" || rango[0].val == "true" or rango[0].val == "false"
            este.val = rango[0].val
        else
            puts"Error: '" + rango[0].to_s + "' no es un valor valido"
        end
        ##termina Fact
    end
    return este
end