# para un hash solo guarda lo que declaré al pincipio
# var_hash = Struct.new(:nombre,:loc,:lineas,:valor, :tipo, :decl) do
#     def to_s
#         "{ nombre: (#{''}, loc: #{0}, lineas: #{[]}, valor: #{nil}, tipo; #{''}, decl:#{nil} }"
#     end
# end
#  hash = {ID: var_hash.new("",0,[],nil,"",nil)}

#  var1 = hash = {ID: var_hash.new(:nombre =>"a",:loc => 1,:lineas[0] => 1,:valor =>4,:tipo =>"inte",:decl => true)}

#  var2 = hash = {ID: var_hash.new(:nombre =>"b",:loc =>2,:lineas[0] => 3,:valor =>"hola",:tipo =>"cad", :tipo =>false)}

#  puts hash[:ID]
class Semantica
    def init(arbol)
      ast = arbol
      #asignarle tipo y valores
      arboltipo = ""
      #arboltipo = asigna_tipo(ast,"",true,"")
      File.open('arboltipo.txt', 'w') do |f1|
        f1.puts arboltipo.to_s 
      end
      #dibujar hash y retornarla en un archivo para java
      hash_table = ""
      hash_table = printTable(ast,ast['hijos'].length,"")
      File.open('hash.txt', 'w') do |f1|
        f1.puts hash_table.to_s 
      end
      #preorden(ast)#tipo
      #postorden(ast)#valor
      #dibujar el arbol con anotaciones
      #retornar errores
      errorSem = ""
      errorSem = manejo_errores("",ast)
      File.open('erroreSem.txt', 'w') do |f1|
        f1.puts errorSem.to_s 
      end
  
    end
  
    def asigna_valor(padre)
      #como empieza por el valor final se toma ese valor
      # luego el del siguiente 
      #luego se pregunta si es un operador +/-/%...
      # case op
        #when '+'
            #valor de la variable padre A:=, será la suma de los valores A:= a + b 
            #que en caso de ser variables, ya debieron haber sido asignadas, en si se deben tomar del hash, que es
            #donde ya vamos a tener los valores
    end
  
    def asigna_tipo(padre, tipo, valor)
      #asignar tipo
      if tipo == "palReservada" || tipo = "cadena" 
        if tipo == "palReservada" && (valor == "integer" || valor == "float" || valor == "bool") 
          #padre['token']['tipo'] = tipo   
        elsif tipo == "identificador" #si eres identificador, eres una variable
          #ya fue declarada?
            #sino fuiste declarada estas siendo asignada?
            #sino estas siendo asignada estás siendo usada?
          #si no fuiste declarada, estas siendo declarada?
            #también estas siendo asignada?
             #también siendo usada? integer a:= c+b
          #si no fuiste declarada ni lo estas siendo, entonces es error de declaración
        end
      end
    end
    if $tokens[$pos]['val'] == "--" 
      este.hijos.push(Nodo.new(TOKEN.new("-", $tokens[$pos]['tipo'], $tokens[$pos]['lin']), $tokens[$pos]['tipo'], este.hijos[0], [Nodo.new($tokens[$pos-1], $tokens[$pos-1]['tipo'], este.hijos[0].hijos[0], []),Nodo.new(TOKEN.new('1', 'entero', $tokens[$pos]['lin']), 'entero', este.hijos[0].hijos[0], [])]))
      $pos = $pos + 1
  elsif $tokens[$pos]['val'] == "++"
      este.hijos.push(Nodo.new(TOKEN.new("+", $tokens[$pos]['tipo'], $tokens[$pos]['lin']), $tokens[$pos]['tipo'], este.hijos[0], [Nodo.new($tokens[$pos-1], $tokens[$pos-1]['tipo'], este.hijos[0].hijos[0], []),Nodo.new(TOKEN.new('1', 'entero', $tokens[$pos]['lin']), 'entero', este.hijos[0].hijos[0], [])]))
      $pos = $pos + 1
    def preorden(padre, func, params) #tipo
      #analisis de tipo
      send(func,padre,params)
      #recorrido
      padre.hijos.each do |hijo|
        preorden(hijo, func, padre['token']['tipo'],padre['token']['valor'])
      end
    end
  
    def postorden(padre) #valor
      #recorrido
      padre.hijos.each do |hijo|
        #si estas aquí es porque eres una expresion
       # se toman los valores que le sigen 
        preorden(hijo, asigna_valor)
      end
      #analisis de valor
      send(asigna_valor,padre)
     
    end
  
    def printTable(padre,i,has_table)
      #generar HASHTABLE
      #nombre|valor|tipo|linea
      #has_table = "hola|mundo + \n"
     
    end
     
    def manejo_errores(error,nodo)
      error = error + "Error > _ < en: " + nodo['token']['val'] + " Linea " + nodo['token']['lin']+"\n" 
      return error
    end
  
  end
#__________________________________________________________________________________________________________________
#CODIGO P
#En base al arbol sintactico 
lda carga direccion identificador
rdl lee entero, almacena a la direccion en el tope de la printTable
lod carga valor identificador
ldc carga valor constante
grt extrae 2 valores de la pila los compara e inserta resultado
fjp extrae resultado de tope de ña pila y salta a la etiqueta si es falso
sto estrae 2 valores d ela pila almacena el 1ro en la direccion del 2do
lab define la etiqueta
mpi multiplicacion entera
mpr #---
sbi resta entera
equi extrae 2 valores de pila y compara igualdad
wri escripe en la pantalla el tope de la pila y loe xtrae
stp termina evaluacion

#hace un recorrido preorden
def preorden(padre, func, params) #tipo
  #analisis de tipo
  send(func,padre,params)
  #recorrido
  padre.hijos.each do |hijo|
    preorden(hijo, func, padre['token']['tipo'],padre['token']['valor'])
  end
end

#funcion de generador de codigo
#recorrido preorden
def gen_code(#recibo el arbol)
  if(#el nodo != NULL)
    gen_code(#nodo izquierdo)
    gen_code(#nodo derecho)
    ....
  end
end

#funcion que evalua cada nodo
def  casos_etiquetas(#nodo)
  #operador
  case #tipo
    when "suma"
      codigo = codigo + "\n" + "adi"
    when "resta"
    when "multiplicacion"
    when "division"
    when "modulo"
    when "identificador"
      si esta siendo asignado lda
      codigo = tkn.val + "lda"
      si lo están asignando a otra variable lod
    when "entero" || "real"
    ldc
  end
end

va a revisar todo el arbol en preorden
arreglo de etiquetas [lda,ldc,wri,ri,lab]

#enumeraciones en ruby o hashes?
# https://stackoverflow.com/questions/75759/enums-in-ruby
