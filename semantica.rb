var_hash = Struct.new(:nombre,:loc,:lineas,:valor, :tipo, :decl)  #propiedades de una variable para la tabla hash estructura

class Semantica
  def init(arbol)
    ast = arbol
    #ast => token, gramatica, padre, hijos[]
    hash = {ID: var_hash.new("",0,[],nil,"",nil)}
    #REALIZAR TABLA HASH  & PINTARLA
    #primero deseamos realizar la tabla hash para analizar a partir de ahí la semantica
    #ya que en esta se asignan valores
    #REALIZAR SEMANTICA & ARBOL CON ATRIBUTOS
    metodsem(ast)

  end
  #TABLA HASH
  def analiza_hash(padre)
    #recorrer el arbol e ir llenando la tabla con su nombre, valor, tipo , localidad y lineas
    padre.hijos.each do |hijo|
      valor = hijo['token']['valor']
      if valor == "integer" || valor == "float" || valor == "bool"
        
      end
    end
  end

  def drow_hash()#dibuja la tabla ya llenado el mapa
  end

  #PARTE SEMANTICA
  def metodsem(padre) #esto es tentativo ya que se desea analizar la hash
    padre.hijos.each do |hijo|
      valor = hijo['token']['valor']
      tipo = hijo['token']['tipo']
      if valor == "integer" || valor == "float" || valor == "bool"
        preorden(hijo,valor)#le estoy enviando valor porque el valor es el que define el tipo
      else
        case valor 
          when "if"
            #si es una expresion la enviamos a postorden y si es un otro valor lo retornamos para avanzar
            if 
            end
          when "while"
          when "do"
          when "read"
          when "write"
          when ":="
      elsif tipo == "identificador" # si es identificador es una variable
      else
        return hijo #si no es ninguna, debe avanzar => main, else, {, en caso de que no lo fuera sería error sintactico, no semantico
      end
    end
  end

  def valida_tipo(padre,tipo)
  #si el id del hash tiene 
  end

  def preorden(padre,valida_tipo,tipo) #asignar tipos
    #analisis
    send(valida_tipo,padre,tipo)
    #recorrido
    padre.hijos.each do |hijo|
      preorden(hijo, valida_tipo, tipo)
    end
  end

  def postorden(padre,tipo,valor) # asignar valores
    #recorrido
    padre.hijos.each do |hijo|
      preorden(hijo, func, padre['token']['tipo'],padre['token']['valor'])
    end
    #analisis
    send(raiz,padre,tipo,valor)
  end

  def drow_ast() #dibuja el arbol
  end
  def existe() # se va a encargar de realizar la busqueda en el mapa para saber si a existe la variable
     #no hace falta este metodo
     #se puede usar ... nombreDeHash.has_key?(:ID) => true si esquiste y false si no
  end

  #TABLA HASH
  
end