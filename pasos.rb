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