require './tipos.rb'

$mapa = Hash.new
$loc = 0
$error_sem = ""
#de la manera en que aparece en el to_s es de la forma que debe estar para ser reconocido como tabla en el IDE
class Semantica
  Simbolo = Struct.new(:nombre, :loc, :val, :tipo_d, :lineas) do
    def to_s
      "| nombre: %10s | loc: %3s | val: %5s | tipo: %8s | %60s |" % [nombre, loc, val, tipo_d, lineas]
    end
  end

  Nast = Struct.new(:padre, :hijos, :token, :gram, :dato, :val) do
    def to_s
      if val != nil && dato != nil
        return token['val'] + " " + dato + "(" + val.to_s + ")"
      else 
        return token['val'] + " ()"
      end
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
    
    #REALIZAR SEMANTICA & ARBOL CON ATRIBUTOS
    #metodsem(ast)
    puts printa(ast, '', '')


    $mapa.each_pair do |s, v|
      puts v.to_s
    end

    #retornar errores
    File.open('erroreSem.txt', 'w') do |f1|
      f1.puts $error_sem.to_s 
    end
  end

  def asigna_tipo(este, tipo_padre) #valor
    tk_tipo = este['token']['tipo']
    tk_val = este['token']['val']
    tipos = ["integer", "float", "bool"]

    if este['token']['val'] == 'y'
      print "\n"
    end

    if tk_tipo == "palReservada" && tipos.include?(tk_val) # || tk_tipo == "cadena"
      return tk_val
    elsif tk_tipo == "identificador" #si eres identificador, eres una variable
      if $mapa.has_key?(tk_val) #ya fue declarada?
        if tipos.include?(tipo_padre) #se esta volviendo a declarar
          # TODO: error
          $error_sem = $error_sem + "Error > n < " + este['token']['val'] + " ya había sido declarada, error en Linea " + este['token']['lin'].to_s + "\n"
        elsif este['padre']['token']['val'] == ':=' #si fuiste declarada y estas siendo asignada?
          este['dato'] = $mapa.fetch(tk_val, '')['tipo_d'] #agregamos su tipo de dato
          $mapa[tk_val]['lineas'].push(este['token']['lin']) #agregamos la linea donde aparece
        else #sino estas siendo asignada estás siendo usada?
          este['dato'] = $mapa.fetch(tk_val, '')['tipo_d'] #agregamos su tipo de dato
          $mapa[tk_val]['lineas'].push(este['token']['lin']) #agregamos la linea donde aparece
        end
      # WARNING: integer a := 1 /  integer a := a + b (no esta definido en la gramatica)
      elsif tipos.include?(tipo_padre) #si no fuiste declarada, estas siendo declarada? integer a:= a + b
        $mapa.store(tk_val, Simbolo.new(tk_val, $loc, val_in(tipo_padre), tipo_padre, [este['token']['lin']]))
        este['dato'] = tipo_padre
        este['val'] = val_in(tipo_padre)
        $loc += 1
      elsif false #también estas siendo asignada? #integer a:= a + b
      elsif false #también siendo usada? integer a:= c+b
      else #si no fuiste declarada ni lo estas siendo, entonces es error de declaración
        #TODO: error
        $error_sem = $error_sem + "Error no fue declarado " + este['token']['val'] + " Linea: " + este['token']['lin'].to_s + "\n"
      end
    elsif ['true', 'false'].include?(tk_val)
      este['dato'] = 'bool'
      este['val'] = tk_val == 'true' # truco para signarle su dato booleano
    elsif tk_tipo == 'real'
      este['dato'] = 'float'
      este['val'] = tk_val.to_f
    elsif tk_tipo == 'entero'
      este['dato'] = 'integer'
      este['val'] = tk_val.to_i
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

  def val_in(tipo_dato)
    case tipo_dato
    when "integer"
      return 0
    when "float"
      return 0.0
    when "bool"
      return false
    end
  end

  def postorden(padre,func,arg) # asignar valores
    #recorrido
    padre.hijos.each do |hijo|
      preorden(hijo, func, arg)
    end
    #analisis
    arg = send(func,padre,arg)
  end

  def asigna_valor(este, args)
    # si nast no tiene valor

    if este['token']['tipo'] == 'identificador'
      if $mapa.has_key?(este['token']['val']) # existe en el mapa?
        este['val'] = $mapa[este['token']['val']]['val'] # asigna valor actual
      end
    elsif realiza_op?(este)# es un operador? hacer operacion
    end
  end

  def realiza_op?(este)
    if tipo_compatible(este['hijos'][0], este['hijos'][1]) # comprueba tipo
      case este['token']['val']
      when ':='
        este['hijos'][0]['val'] = este['hijos'][1]['val'] # asigna nuevo valor
        if $mapa.has_key?(este['hijos'][0]['token']['val'])
          $mapa[este['hijos'][0]['token']['val']]['val'] = este['hijos'][0]['val'] #(cambiar el valor en el mapa)
        end
      when '+'
        # print este['hijos'][0]['dato'], " + ", este['hijos'][1]['dato'], " - "
        # print este['hijos'][0]['val'].class, " + ", este['hijos'][1]['val'].class, " - "
        # print este['hijos'][0]['val'], " + ", este['hijos'][1]['val'], "\n"
        este['hijos'].each do |hijo|
          print hijo['val'], " "
        end
        print "\n"
        # este['val'] = este['hijos'][0]['val'] + este['hijos'][1]['val']
      when '-'
      when '*'
      when '/'

      when '%'
      when '<'
      when '<='
      when '=='
      when '!='
      when '>='
      when '>'
      else
        return false
      end
      return true
    else # tipos no compatibles
      return false
    end
  end

  def tipo_compatible(nast1, nast2)
    if nast1 != nil && nast2 != nil
      if nast1['dato'] != '' && nast2['dato'] != ''
        # print nast1['dato'], " ", nast2['dato'], "\n"
        
        #TODO: Reglas

        return nast1['dato'] == nast2['dato']
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