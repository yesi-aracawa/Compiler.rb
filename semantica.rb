require './tipos.rb'

$mapa = Hash.new
$loc = 0
$error_sem = ""
#de la manera en que aparece en el to_s es de la forma que debe estar para ser reconocido como tabla en el IDE
class Semantica
  Simbolo = Struct.new(:nombre, :loc, :val, :tipo_d, :lineas) do
    # def to_s
    #   "| nombre: %10s | loc: %3s | val: %5s | tipo: %8s | %60s |" % [nombre, loc, val, tipo_d, lineas]
    # end
    def to_s
       "%10s | %3s | %5s | %8s | %60s" % [nombre, loc, val, tipo_d, lineas]
    end
  end

  Nast = Struct.new(:padre, :hijos, :token, :gram, :dato, :val) do
    def to_s
      return token['val'] + " " + dato.to_s + "(" + val.to_s + ")"
    end
  end

  def init(arbol)
    #ast => token, gramatica, padre, hijos[]
    ast = copia_arbol(arbol, nil)
    #REALIZAR TABLA HASH  & PINTARLA
    #primero deseamos realizar la tabla hash para analizar a partir de ahí la semantica ya que en esta se asignan valores
    #hash = {ID: var_hash.new("",0,[],nil,"",nil)}
    
    preorden(ast, :asigna_tipo, '')
    postorden(ast, :asigna_valor, '')
    puts printa(ast, '', '')
    
    #REALIZAR SEMANTICA & ARBOL CON ATRIBUTOS
    #metodsem(ast)
    arbol_semantico = printa(ast, '', '')

    hash_table = ""
    $mapa.each_pair do |s, v|
      puts v.to_s
      hash_table = hash_table + v.to_s + "\n"
    end


    #Pasar el arbol semantico a un archivo
    File.open('semantico.txt', 'w') do |f1|
      f1.puts arbol_semantico.to_s 
   end

   #pasar tabla hash a un archivo
   File.open('hash.txt', 'w') do |f2|
     f2.puts hash_table.to_s 
   end

   #retornar errores
   File.open('erroreSem.txt', 'w') do |f3|
     f3.puts $error_sem.to_s 
   end

  end

  def asigna_tipo(este, tipo_padre) #valor
    tk_tipo = este['token']['tipo']
    tk_val = este['token']['val']
    tipos = ["integer", "float", "bool"]

    if tk_tipo == 'identificador' #si eres identificador, eres una variable
      if $mapa.has_key?(tk_val) #ya fue declarada?
        if tipos.include?(este['padre']['token']['val']) #se esta volviendo a declarar
          # TODO: error
          $error_sem = $error_sem + "Error la variable: " + este['token']['val'] + " ya había sido declarada, error en Linea: " + este['token']['lin'].to_s + "\n" 
        else#if este['padre']['token']['val'] == ':=' #si fuiste declarada y estas siendo asignada?
          este['dato'] = $mapa.fetch(tk_val, '*')['tipo_d'] #agregamos su tipo de dato
          $mapa[tk_val]['lineas'].push(este['token']['lin']) #agregamos la linea donde aparece
        #else #sino estas siendo asignada estás siendo usada?
          #este['dato'] = $mapa.fetch(tk_val, '')['tipo_d'] #agregamos su tipo de dato
          # $mapa[tk_val]['lineas'].push(este['token']['lin']) #agregamos la linea donde aparece
        end
      elsif este['padre']['token']['val'] != '' && tipos.include?(este['padre']['token']['val'])
          #si no fuiste declarada, estas siendo declarada? integer a:= a + b
          este['dato'] = este['padre']['token']['val']
          tk_aux = TOKEN.new('false', este['dato'], 0)
          $mapa.store(tk_val, Simbolo.new(tk_val, $loc, valor_inicial(tk_aux), este['dato'], [este['token']['lin']]))
          $loc += 1
      # WARNING: integer a := 1 /  integer a := a + b (no esta definido en la gramatica)
      elsif false #también estas siendo asignada? #integer a:= a + b
      elsif false #también siendo usada? integer a:= c+b
      else #si no fuiste declarada ni lo estas siendo, entonces es error de declaración
        #TODO: error
        $error_sem = $error_sem + "Error no fue declarado " + este['token']['val'] + " Linea: " + este['token']['lin'].to_s + "\n"
      end
    elsif ['true', 'false'].include?(tk_val)
      este['dato'] = 'bool'
      #este['val'] = tk_val == 'true'
    elsif tk_tipo == 'real'
      este['dato'] = 'float'
      #este['val'] = tk_val.to_f
    elsif tk_tipo == 'entero'
      este['dato'] = 'integer'
      #este['val'] = tk_val.to_i
    else
      return ['']
    end
  end
  
  def preorden(padre, func, arg) #tipo
    #analisis de tipo
    arg = send(func, padre, arg)
    #recorrido
    padre.hijos.each do |hijo|
      preorden(hijo, func, arg) # padre['token']['tipo'],padre['token']['val']
    end
  end

  def valor_inicial(token)
    case token['tipo']
    when 'palReservada', 'bool'
      if token['val'] == 'true'
        return true
      elsif token['val'] == 'false'
        return false
      end
    when 'identificador', 'bool'
      if token['val'] == 'true'
        return true
      elsif token['val'] == 'false'
        return false
      end
    when 'entero', 'integer'
      return 0
    when 'real', 'float'
      return 0.0
    end
  end

  def postorden(padre,func,arg) # asignar valores
    #recorrido
    padre.hijos.each do |hijo|
      postorden(hijo, func, arg)
    end
    #analisis
    arg = send(func,padre,arg)
  end

  def asigna_valor(este, args)
    # si nast no tiene valor
    
    if este['token']['tipo'] == 'identificador'
      if $mapa.has_key?(este['token']['val']) # existe en el mapa?
        este['val'] = $mapa.fetch(este['token']['val'])['val'] # asigna valor actual
      end
    elsif ['true', 'false'].include?(este['token']['val'])
      if este['token']['val'] == 'true'
      este['val'] = true
      else
          este['val'] = false
        end
    elsif este['token']['tipo'] == 'real'
      este['val'] = este['token']['val'].to_f
    elsif este['token']['tipo'] == 'entero'
      este['val'] = este['token']['val'].to_i
    elsif realiza_op?(este)# es un operador? hacer operacion
    
    else
      $error_sem = $error_sem + "Error de asignación de valor en: " + este['token']['val'] + " Linea: " + este['token']['lin'].to_s + "\n"
    end
  end

  def realiza_op?(este)
    if este['hijos'].length > 1
      case este['token']['val']
      when ':='
        puts este['hijos'][1]['val'].to_s + "tipo " + este['hijos'][1]['dato'].to_s + "\n"
        #este['hijos'][0]['val'] = este['hijos'][1]['val'] # asigna nuevo valor
        if tipo_compatible(este['hijos'][0], este['hijos'][1], [["float", "integer"], ["integer", "integer"], ["float", "float"]])
            if este['hijos'][0]['dato'] == "float" || este['hijos'][1]['dato'] == "float"
              este['dato'] = "float"
              este['hijos'][0]['val'] = este['hijos'][1]['val'].to_f # asigna nuevo valor
            else
              este['dato'] = "integer"
              este['hijos'][0]['val'] = este['hijos'][1]['val'].to_i# asigna nuevo valor
            end
          elsif tipo_compatible(este['hijos'][0], este['hijos'][1], [["bool", "bool"], ["bool","integer"]])  
              este['dato'] = "bool"
              este['hijos'][0]['val'] = este['hijos'][1]['val']   
             
            else
          #TODO: error
          $error_sem = $error_sem + "Error en: " + este['token']['val'] + " el tipo no corresponde en las variables. Linea: " + este['token']['lin'].to_s + "\n"
        end
        if $mapa.has_key?(este['hijos'][0]['token']['val'])
          $mapa[este['hijos'][0]['token']['val']]['val'] = este['hijos'][0]['val'] #(cambiar el valor en el mapa)
        end
      when '+', '-', '*', '/', '%'
        if (este['token']['val'] == '/' || este['token']['val'] == '%') && (este['hijos'][1]['val'].to_i.to_s == '0' || este['hijos'][1]['val'].to_f.to_s == '0.0')
          #TODO: error
          $error_sem = $error_sem + "Error en: " + este['token']['val'] + " no se puede realizar por un valor 0. Linea: " + este['token']['lin'].to_s + "\n"
          return
        end
        if este['token']['val'] == '%' && tipo_compatible(este['hijos'][0], este['hijos'][1], [["float", "integer"], ["integer", "integer"], ["float", "float"], ["integer", "float"]]) #el modulo siempre es entero
          este['dato'] = "integer"
          este['val'] = eval(este['hijos'][0]['val'].to_i.to_s + este['token']['val'] + este['hijos'][1]['val'].to_i.to_s).to_i
        end
        if tipo_compatible(este['hijos'][0], este['hijos'][1], [["float", "integer"], ["integer", "integer"], ["float", "float"]])
          if este['hijos'][0]['dato'] == "float" || este['hijos'][1]['dato'] == "float"
            este['dato'] = "float"
            este['val'] = eval(este['hijos'][0]['val'].to_f.to_s + este['token']['val'] + este['hijos'][1]['val'].to_f.to_s).to_f
          else
            este['dato'] = "integer"
            este['val'] = eval(este['hijos'][0]['val'].to_i.to_s + este['token']['val'] + este['hijos'][1]['val'].to_i.to_s).to_i
          end
        end
      when '<', '<=', '==', '!=', '>=', '>'
         #if tipo_compatible(este['hijos'][0],este['hijos'][1], [["bool", "bool"]])
          este['dato'] = 'bool'
          if este['token']['val'] == '=='
            if este['hijos'][0]['val'] == este['hijos'][1]['val']
              este['val'] = true
            else
              este['val'] = false
            end
          elsif este['token']['val'] == '!='
            if este['hijos'][0]['val'] != este['hijos'][1]['val']
              este['val'] = true
            else
              este['val'] = false
            end
          elsif este['token']['val'] == '<'
            if este['hijos'][0]['val'] < este['hijos'][1]['val']
              este['val'] = true
            else
              este['val'] = false
            end
          elsif este['token']['val'] == '<='
            if este['hijos'][0]['val'] <= este['hijos'][1]['val']
              este['val'] = true
            else
              este['val'] = false
            end
          elsif este['token']['val'] == '>'
            if este['hijos'][0]['val'] > este['hijos'][1]['val']
              este['val'] = true
            else
              este['val'] = false
            end
          elsif este['token']['val'] == '>='
            if este['hijos'][0]['val'] >= este['hijos'][1]['val']
              este['val'] = true
            else
              este['val'] = false
            end
          else
            este['val'] = eval(este['hijos'][0]['val'].to_s + este['token']['val'] + este['hijos'][1]['val'].to_s)
          end
       #end
      else # tipos no compatibles
        return false
      end
    else
      return false
    end
    return true
  end

  def tipo_compatible(nast1, nast2, array)
    if nast1 != nil && nast2 != nil && nast1['dato'] != '' && nast2['dato'] != ''
      #TODO: Reglas
      array.each do | regla |
        if nast1['dato'] == regla[0] && nast2['dato'] == regla[1]
          return true
        end
      end
    end
    return false
  end

  def copia_arbol(nodo, padre)
    este = Nast.new(padre, [], nodo['token'], nodo['gram'], nil, nil)

    nodo['hijos'].each do | hijo |
      # TODO: eliminar nodos fantasma
      if hijo['token']['val'] != ""
        este['hijos'].push(copia_arbol(hijo, este))
      end
    end

    return este
  end
  
  def printa(padre, ident, str)
    str = str + "" + ident + "" + padre.to_s + "\r\n"
    espacio = " "
    
    padre['hijos'].each do | hijo |
        str = printa(hijo, ident + espacio, str)
    end
    return str
  end
# ------------------------------------------------------------------------------

  def drow_hash()#dibuja la tabla ya llenado el mapa
  end

  #PARTE SEMANTICA
  def metodsem(padre) #esto es tentativo ya que se desea analizar la hash
    padre.hijos.each do |hijo|
      valor = hijo['token']['val']
      tipo = hijo['token']['tipo']
      if valor == "integer" || valor == "float" || valor == "bool"
        preorden(hijo,valor)#le estoy enviando valor porque el valor es el que define el tipo
      # else
      #   case valor 
      #     when "if"
      #       #si es una expresion la enviamos a postorden y si es un otro valor lo retornamos para avanzar
      #       if 
      #       end
      #     when "while"
      #     when "do"
      #     when "read"
      #     when "write"
      #     when ":="
      #   end
      # elsif tipo == "identificador" # si es identificador es una variable
      else
        return hijo #si no es ninguna, debe avanzar => main, else, {, en caso de que no lo fuera sería error sintactico, no semantico
      end
    end
  end

  def existe() # se va a encargar de realizar la busqueda en el mapa para saber si a existe la variable
     #no hace falta este metodo
     #se puede usar ... nombreDeHash.has_key?(:ID) => true si esquiste y false si no
  end

  #TABLA HASH

end
