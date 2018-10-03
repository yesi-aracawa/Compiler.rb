class Semantica
    def init(arbol)
       #asignarle tipo y valores
       ast = arbol
       preorden(ast)
       #crear la tabla de simbolos

       #dibujar el arbol
 

    end

    def preorden(padre) #tipo
        #analisis

        aux = Nodo.new("", "", padre, [])

        #recorrido
        padre.hijos.each do |hijo|
            preorden(hijo)
        end
        
    end

    def postorden(padre) #valor
        #recorrido
        aux = Nodo.new("", "", padre, [])
    end

end