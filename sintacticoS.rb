require './tipos.rb'
require './lexico.rb'

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
        
        padre = Nodo.new(nil, '', nil, [])
        padre = principal(padre, "programa")
        $arbol = printa(padre, "", "")
        
        File.open('sintactico.txt', 'w') do |f1|
            f1.puts $arbol.to_s 
        end
        File.open('erroresS.txt', 'w') do |f2|
            f2.puts $error.to_s 
        end
        return padre, $error
    end
    
    def EOF()
        return $pos >= $leng-1
    end

    def validar(val)
        if EOF()
            #puts "Se encontro fin del archivo en lugar de '" + val + "'"
            #exit()
        elsif $tokens[$pos]['val'] != val
            $error = $error + "Error: '" + $tokens[$pos].to_s + "' se esperaba '" + val + "'" + "linea" +$tokens[$pos]['lin'].to_s  + "\n"
            #puts "Error: '" + $tokens[$pos].to_s + "' se esperaba '" + val + "'"
        end
        $pos = $pos + 1
    end
    
    def principal(padre, gram)
        este = Nodo.new(TOKEN.new(gram, '', $tokens[$pos]['lin']), gram, padre, [])
        case gram
        when "programa"
            validar("main")
            validar("{")
            principal(este, "ld")#no regresa a ld si ya entró  a ls por lo tanto no muestra en el arbol las declaraciones que estan entre las sentencias*******************************************
            principal(este, "ls")
            validar("}")
        when "ld"
            while !EOF() && ["float", "integer", "bool"].include?($tokens[$pos]['val'])
                padre['hijos'].push(principal(padre, "declaracion"))
            end
        when "declaracion"
            este.token = $tokens[$pos]
            $pos = $pos + 1
            principal(este, "lv")
            validar(";")
        when "lv"
            while !EOF() && $tokens[$pos]['tipo'] == "identificador"
                padre['hijos'].push(Nodo.new($tokens[$pos], $tokens[$pos]['tipo'], padre, []))
                $pos = $pos + 1
                if $tokens[$pos]['val'] != ";"
                    validar(",")
                end
            end
        when "ls"
            while !EOF() && !(["}", ";"].include?($tokens[$pos]['val']))
                padre['hijos'].push(principal(padre, "sentencia"))
            end
        when "sentencia"
            # TODO
            if $tokens[$pos]['tipo'] == "identificador"
                este.token = TOKEN.new(":=", "", $tokens[$pos]['lin'])
                este.hijos.push(Nodo.new($tokens[$pos], $tokens[$pos]['tipo'], este, []))
                $pos = $pos + 1
                if $tokens[$pos]['val'] == "--" 
                    este.hijos.push(Nodo.new(TOKEN.new("-", $tokens[$pos]['tipo'], $tokens[$pos]['lin']), $tokens[$pos]['tipo'], este.hijos[0], [Nodo.new($tokens[$pos-1], $tokens[$pos-1]['tipo'], este.hijos[0].hijos[0], []),Nodo.new(TOKEN.new('1', 'entero', $tokens[$pos]['lin']), 'entero', este.hijos[0].hijos[0], [])]))
                    $pos = $pos + 1
                elsif $tokens[$pos]['val'] == "++"
                    este.hijos.push(Nodo.new(TOKEN.new("+", $tokens[$pos]['tipo'], $tokens[$pos]['lin']), $tokens[$pos]['tipo'], este.hijos[0], [Nodo.new($tokens[$pos-1], $tokens[$pos-1]['tipo'], este.hijos[0].hijos[0], []),Nodo.new(TOKEN.new('1', 'entero', $tokens[$pos]['lin']), 'entero', este.hijos[0].hijos[0], [])]))
                    $pos = $pos + 1
                elsif $tokens[$pos]['val'] == ":="
                    $pos = $pos + 1
                    este.hijos.push(principal(este,"exp"))
                else
                    este = Nodo.new("","",este.padre,[])
                    while !EOF() && $tokens[$pos]['val'] != ";"
                        $pos = $pos + 1
                    end
                end
                validar(";")
            else
                este.token = $tokens[$pos]
                $pos = $pos + 1
                case $tokens[$pos-1]['val']
                when "if"
                    validar("(")
                    este.hijos.push(principal(este, "exp"))
                    validar(")")
                    validar("then")
                    este.hijos.push(principal(este, "{"))
                    validar("else")
                    este.hijos.push(principal(este, "{"))
                when "while"
                    validar("(")
                    este.hijos.push(principal(este, "exp"))
                    validar(")")
                    este.hijos.push(principal(este, "{"))
                when "do"
                    este.hijos.push(principal(este, "{"))
                    #$error = $error + "Error: en pos: " + $pos.to_s + " tam " + $leng.to_s + " rango " + $tokens[$pos]['val'] + " " + $tokens[($pos-2)..($pos+2)].to_s  + " linea " +$tokens[$pos]['lin'].to_s  + "\n"
                   # puts "ºººººº" + $pos.to_s + " " + $leng.to_s + " " + $tokens[$pos]['val'] + " " + $tokens[($pos-2)..($pos+2)].to_s
                    validar("until")
                    validar("(")
                    este.hijos.push(principal(este, "exp"))
                    validar(")")
                    validar(";")
                when "read"
                    este.hijos.push(Nodo.new( $tokens[$pos], $tokens[$pos]['tipo'], este, []))
                    $pos = $pos + 1
                    validar(";")
                when "write"
                    if $tokens[$pos]['tipo'] != "cadena"
                        $error = $error + "Error: '" + $tokens[$pos].to_s + "' se esperaba una cadena '" + " en " + "linea" +$tokens[$pos]['lin'].to_s  + "\n"
                        #puts "Error: '" + $tokens[$pos].to_s + "' se esperaba una cadena"
                        este = Nodo.new(nil,"",este.padre,[])
                        while !EOF() && $tokens[$pos]['val'] != ";"
                            $pos = $pos + 1
                        end
                        $pos = $pos + 1
                    else
                        este.hijos.push(Nodo.new($tokens[$pos], $tokens[$pos]['tipo'],este, []))
                        $pos = $pos + 1
                        if $tokens[$pos]['val'] == ","
                            while !EOF() && $tokens[$pos]['val'] == ","
                                $pos = $pos + 1
                                este.hijos.push(principal(este, "exp"))
                            end
                        elsif  $tokens[$pos]['val'] != ";"
                            $error = $error + "Error: '" + $tokens[$pos].to_s + "' se esperaba un ';' " + "  en " + "linea" +$tokens[$pos]['lin'].to_s  + "\n"
                           # puts "Error: '" + $tokens[$pos].to_s + "' se esperaba ;"
                            este = Nodo.new("","",este.padre,[])
                            while !EOF() && $tokens[$pos]['val'] != ";"
                                $pos = $pos + 1
                            end
                            $pos = $pos + 1
                        end
                    end
                    validar(";")
                else
                    este = Nodo.new("","",este.padre,[])
                    while !EOF() && $tokens[$pos]['val'] != ";"
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
            while !EOF() && $tokens[$pos]['val'] != ';'
                if $tokens[$pos]['val']=="("
                    paren = paren+1
                elsif $tokens[$pos]['val']==")"
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
            este.token = $tokens[$pos]
            $pos = $pos + 1
        else
            $error = $error + "Error: Valor no valido  :C :C en '" + "linea" +$tokens[$pos]['lin'].to_s  + "\n"
        end
        return este
    end

    def inorden(padre, rango, gram)
        este = Nodo.new(TOKEN.new('', '', $tokens[$pos]['lin']), '', padre, [])
        if rango.length < 1
            return este
        end
        paren = 0
        bandera = false
        i = rango.length-1
        
        arr_aux1_aux2 = []
        case gram
        when "exp"
            arr_aux1_aux2 = ['val', 'exps', 'exps', [">", ">=", "<", "<=", "==", "!="]]
        when "exps"
            arr_aux1_aux2 = ['val', 'exps', 'term', ["+", "-"]]
        when "term"
            arr_aux1_aux2 = ['val', 'term', 'fact', ["*", "/", "%"]]
        when "fact"
            arr_aux1_aux2 = ['tipo', 'exps', '',    ["bool", "real", "entero", "identificador"]]
        end
    
        while i>=0 
            if rango[i]['val'] == ')'
                paren = paren + 1
            elsif rango[i]['val'] == '('
                paren = paren - 1
            elsif arr_aux1_aux2[3].include?(rango[i][arr_aux1_aux2[0]])
                if paren == 0
                    bandera = true
                    break
                end
            end
            i = i-1
        end
    
        if gram != 'fact'
            if bandera
                este.hijos.push(inorden(este, rango[0..(i-1)], arr_aux1_aux2[1]))
                este.token = rango[i]
                este.hijos.push(inorden(este, rango[(i+1)..(rango.length-1)], arr_aux1_aux2[2]))
            else
                este = inorden(este, rango, arr_aux1_aux2[2])
            end
        else
            if rango[0]['val'] == '(' && rango[rango.length-1]['val'] == ')'
                este = inorden(este, rango[1..(rango.length-2)], arr_aux1_aux2[1])
            else
                este.token = rango[0]
            end
        end
        return este
    end

    def printa(padre, ident, str)
        str = str + "" + ident + "" + padre['token']['val'].to_s + "\r\n"
        espacio = " "
        
        padre['hijos'].each do | hijo |
            str = printa(hijo, ident + espacio, str)
        end
        return str
      end
end