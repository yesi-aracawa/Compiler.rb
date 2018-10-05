class Semantica
  def init(arbol)
    ast = arbol
    #asignarle tipo y valores
    arboltipo = ""
    #arboltipo = asigna_tipo(ast,"",true,"")
    File.open('arboltipo.txt', 'w') do |f1|
      f1.puts arboltipo.to_s 
    end
    #preorden(ast)
    #postorden(ast)
    #crear la tabla de simbolos
    #voy a ocupar enviar desde el sintactico la linea, además de el tipo
    #verifica_valor(ast)
    #dibujar el arbol
    #dibujar hash y retornarla en un archivo para java
    hash_table = ""
    hash_table = printTable(ast,ast['hijos'].length,"")
    File.open('hash.txt', 'w') do |f1|
      f1.puts hash_table.to_s 
    end
  end

  def asigna_valor(padre)
    puts padre.token.val
  end

  def asigna_tipo(padre, tipo)
    #asignar tipo
    padre['token']['tipo'] = tipo   
  end

  def preorden(padre, func, params) #tipo
    #analisis
    send(func,padre,params)
    #recorrido
    padre.hijos.each do |hijo|
      preorden(hijo, func, padre['token']['tipo'])
    end
  end

  def postorden(padre) #valor
    #recorrido
    padre.hijos.each do |hijo|
      preorden(hijo, asigna_valor)
    end
    #analisis
    send(asigna_valor,padre)
   
  end

  def printTable(padre,i,has_table)
    #generar HASHTABLE
    #nombre|valor|tipo|linea
    #has_table = "hola|mundo + \n"
   
  end

end