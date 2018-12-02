import os
import sys
import Semantic2
import HaAsh
import codeGen

class TreeNode:

    def __init__(self):
        self.child = [None, None, None]
        self.sibling = None
        self.line = None
        self.nodekind = None
        self.kind = None
        self.attr = None
        self.type = None
        self.value = None

class Syntactic:

    def __init__(self):
        self.line = None
        self.token = None
        self.type = None
        ##self.argv = sys.argv[1]
        ##print(self.argv)
        self.file = open('Revisio_sintac.txt', 'r')
        ##self.textLine = ""
        ##self.aux = self.argv.split("\\")
        ##self.a = 0
        ##self.aux2 = ""
        ##while self.a < (len(self.aux) - 1):
        ##    self.aux2 += self.aux[self.a] + "\\"
        ##    self.a += 1
        ##self.argv = self.aux2
        self.archivo_errores = open('ErrorSyntactico.txt', 'w')

    def newStmtNode(self,kind):
        t = TreeNode()
        t.nodekind = "sentencia"
        t.kind = kind
        t.line = self.line
        return t

    def newExpNode(self,kind):
        t = TreeNode()
        t.nodekind = "expresion"
        t.kind = kind
        t.line = self.line
        t.type = "Void"
        return t

    def newDecNode(self,kind):
        t = TreeNode()
        t.nodekind = "declaracion"
        t.kind = kind
        t.line = self.line
        return t

    def programa(self):
        print("S-Programa")
        self.token = self.getToken()
        t = TreeNode()
        t.attr = self.token
        self.match("main",1)
        self.match("{",1)
        t.child[0] = self.lista_declaracion()
        t.child[1] = self.lista_sentencias()
        if self.token == "ENDFILE":
            self.syntaxError("Unexpected token", "}")
            print("Unexpected token " + self.token + " en la linea " + self.line + " se esperaba }")
        self.match("}",1)
        if self.token != "ENDFILE":
            self.syntaxError("Unexpected token", "ENDFILE")
        self.file.close()
        self.archivo_errores.close()
        print("E-Programa")
        return t

    def match(self,expected,case):
        if self.token != "ENDFILE":
            if case == 1:
                if self.token == expected:
                    self.token = self.getToken()
                else:
                    print("Unexpected token " + self.token + " en la linea " + self.line + " se esperaba " + expected)
                    #Imprimir errores en documento nuevo
                    self.syntaxError("Unexpected token",expected)
            else:
                if self.type == expected:
                    self.token = self.getToken()
                else:
                    print("Unexpected token " + self.token + " en la linea " + self.line + " se esperaba " + expected)
                    # Imprimir errores en documento nuevo
                    self.syntaxError("Unexpected token",expected)

    def lista_declaracion(self):
        print("S-LDecla")
        t = self.declaracion()
        p = t
        while self.token == "int" or self.token == "real" or self.token == "boolean":
            q = self.declaracion()
            if q != None:
                if t == None:
                    t = p = q
                else:
                    p.sibling = q
                    p = q
        print("E-LDecla")
        return t

    def declaracion(self):
        print("S-Decla")
        t = None
        if self.token == "int" or self.token == "real" or self.token == "boolean":
            t = self.newDecNode(self.token)
            self.match(self.token,1)
            if t != None:
                t.child[0] = self.lista_variables()
            self.match(";",1)
        print("E-LDecla")
        return t

    def lista_variables(self):
        print("S-LVaria")
        t = self.newExpNode(self.type)
        if self.type == "id":
            t.attr = self.token
        self.token = self.getToken()
        p = t
        while self.token == ",":
            self.match(",",1)
            q = self.newExpNode("id")
            if q != None:
                if t == None:
                    t = p = q
                else:
                    if self.type == "id":
                        q.attr = self.token
                    p.sibling = q
                    p = q
                self.token = self.getToken()
        print("E-LVaria")
        return t

    def lista_sentencias(self):
        print("S-LSent")
        t = self.sentencia()
        p = t
        while self.token == "if" or self.token == "while" or self.token == "do" or self.token == "repeat" or self.type == "id" or self.token == "cin" or self.token == "cout" or self.token == "{":
            q = self.sentencia()
            if q != None:
                if t == None:
                    t = p = q
                else:
                    p.sibling = q
                    p = q
        print("E-LSent")
        return t


    def sentencia(self):
        print("S-Sent")
        t = None
        if self.token == "if":
            t = self.seleccion()
        elif self.token == "while":
            t = self.iteracion()
        elif self.token == "do" or self.token == "repeat":
            t = self.repeticion()
        elif self.type == "id":
            t = self.asignacion()
        elif self.token == "cin":
            t = self.sent_cin()
        elif self.token == "cout":
            t = self.sent_cout()
        elif self.token == "{":
            t = self.bloque()
        print("E-Sent")
        return t

    def seleccion(self):
        print("S-Selec")
        t = self.newStmtNode("if")
        self.match("if",1)
        self.match("(",1)
        if t != None:
            t.child[0] = self.expresion()
        self.match(")",1)
        self.match("then",1)
        if t != None:
            t.child[1] = self.bloque()
        if self.token == "else":
            self.match("else",1)
            if t != None:
                t.child[2] = self.bloque()
        print("E-Selec")
        return t

    def iteracion(self):
        print("S-Itera")
        t = self.newStmtNode("while")
        self.match(self.token,1)
        if self.token == "(":
            self.match("(",1)
        if t != None:
            t.child[0] = self.expresion()
        self.match(")", 1)
        if t != None:
            t.child[1] = self.bloque()
        print("E-Itera")
        return t

    def repeticion(self):
        print("S-Repet")
        t = self.newStmtNode(self.token)
        self.match(self.token,1)
        if t != None:
            t.child[0] = self.bloque()
        self.match("until",1)
        self.match("(",1)
        if t != None:
            t.child[1] = self.expresion()
        self.match(")",1)
        self.match(";",1)
        print("E-Repet")
        return t

    def sent_cin(self):
        print("S-Cin")
        t = self.newStmtNode("cin")
        self.match("cin",1)
        if self.type == "id" and t != None:
            t.attr = self.token
        self.match("id",2)
        self.match(";",1)
        print("E-Cin")
        return t

    def sent_cout(self):
        print("S-Cout")
        t = self.newStmtNode("cout")
        self.match("cout",1)
        if t != None:
            t.child[0] = self.expresion()
        self.match(";",1)
        print("E-Cout")
        return t

    def bloque(self):
        print("S-Bloq")
        t = self.newStmtNode("bloque")
        self.match("{",1)
        if t != None:
            t.child[0] = self.lista_sentencias()
        self.match("}",1)
        print("E-Bloq")
        return t

    def asignacion(self):
        print("S-Asign")
        t = self.newStmtNode("asignacion")
        if self.type == "id":
            t.attr = self.token
        self.match("id",2)
        if self.token == "++":
            q = self.newExpNode("op")
            q.attr = "+"
            r = self.newExpNode("id")
            r.attr = t.attr
            s = self.newExpNode("integer")
            s.attr = "1"
            q.child[0] = r
            q.child[1] = s
            t.child[0] = q
            self.match("++",1)
        elif self.token == "--":
            q = self.newExpNode("op")
            q.attr = "-"
            r = self.newExpNode("id")
            r.attr = t.attr
            s = self.newExpNode("integer")
            s.attr = "1"
            q.child[0] = r
            q.child[1] = s
            t.child[0] = q
            self.match("--",1)
        elif self.token == ":=":
            self.match(":=",1)
            t.child[0] = self.expresion()
        else:
            self.syntaxError("Unexpected token","un Asignador")
            if self.type == "integer" or self.type == "float" or self.type == "boolean" or self.type == "id" or self.token == "(" or self.token == "+" or self.token == "-":
                while self.token != ";":
                    self.token = self.getToken()
        self.match(";",1)
        print("E-Asign")
        return t

    def expresion(self):
        print("S-Expre")
        t = self.expresion_simple()
        if self.token == "<=" or self.token == "<" or self.token == ">=" or self.token == ">" or self.token == "==" or self.token == "!=":
            p = self.newExpNode("op")
            if p != None:
                p.child[0] = t
                p.attr = self.token
                t = p
            self.match(self.token,1)
            if t != None:
                t.child[1] = self.expresion_simple()
        elif self.token != ";" and self.token != ")" and self.token != "}" and self.token != "ENDFILE":
            self.syntaxError("Unexpected token","una Expresion")
            self.token = self.getToken()
        print("E-Expre")
        return t

    def expresion_simple(self):
        print("S-ExpreSim")
        t = self.termino()
        while self.token == "+" or self.token == "-":
            p = self.newExpNode("op")
            if p != None:
                p.child[0] = t
                p.attr = self.token
                t = p
                self.match(self.token,1)
                t.child[1] = self.termino()
        print("E-ExpreSim")
        return t

    def termino(self):
        print("S-Termino")
        t = self.factor()
        while self.token == "*" or self.token == "/":
            p = self.newExpNode("op")
            if p != None:
                p.child[0] = t
                p.attr = self.token
                t = p
                self.match(self.token,1)
                t.child[1] = self.factor()
        print("E-Termino")
        return t

    def factor(self):
        print("S-Factor")
        t = None
        print(self.token)
        print(self.type)
        if self.token == "(":
            self.match("(",1)
            t = self.expresion()
            self.match(")",1)
            print(self.token)
        elif self.type == "float" or self.type == "integer":
            t = self.newExpNode(self.type)
            if t != None:
                t.attr = self.token
            self.token = self.getToken()
        elif self.type == "id":
            t = self.newExpNode("id")
            if t != None:
                t.attr = self.token
            self.token = self.getToken()
        else:
            self.syntaxError("Unexpected token", "un Factor")
            self.token = self.getToken()
        print("E-Factor")
        return t

    def getToken(self):
        linea = self.file.readline()
        datos = linea.split("\t")
        self.type = datos[1]
        self.line = datos[2]
        return datos[0]

    def syntaxError(self,error,esperado):
        self.archivo_errores.write("Error: " + error + ": " + self.token + " en linea " + self.line + ". Se esperaba: " + esperado + "\n")

def print_arbol(arbol,tabs):
    while  arbol != None:
        espacios(tabs)
        if arbol.attr == "main":
            file.write("Programa: \n")
        elif arbol.nodekind == "sentencia":
            if arbol.kind == "if":
                file.write("if: \n")
            elif arbol.kind == "do":
                file.write("do: \n")
            elif arbol.kind == "repeat":
                file.write("repeat: \n")
            elif arbol.kind == "asignacion":
                file.write("asignacion: " + str(arbol.attr) + "\n")
            elif arbol.kind == "cin":
                file.write("escritura: " + str(arbol.attr) + "\n")
            elif arbol.kind == "cout":
                file.write("lectura:\n")
            elif arbol.kind == "bloque":
                file.write("bloque: \n")
            elif arbol.kind == "while":
                file.write("while: \n")
            elif arbol.kind == "break":
                file.write("break: \n")
            else:
                file.write("Sentencia desconocida\n")
        elif arbol.nodekind == "expresion":
            if arbol.kind == "op":
                file.write("operador: " + str(arbol.attr) + "\n")
            elif arbol.kind == "float" or arbol.kind == "integer":
                file.write("constante: " + str(arbol.attr) + "\n")
            elif arbol.kind == "id":
                file.write("id: " + str(arbol.attr) + "\n")
            else:
                file.write("Expresion desconocida\n")
        elif arbol.nodekind == "declaracion":
            if arbol.kind == "int":
                file.write("var int: \n")
            elif arbol.kind == "real":
                file.write("var real: \n")
            elif arbol.kind == "boolean":
                file.write("var boolean: \n")
            else:
                file.write("Declaracion desconocida\n")
        else:
            file.write("Token desconocido\n")

        for i in range(3):
            print_arbol(arbol.child[i],tabs+1)
        arbol = arbol.sibling

def print_semantico(arbol,tabs):
    while  arbol != None:
        espacios(tabs)
        if arbol.attr == "main":
            file.write("Programa: \n")
        elif arbol.nodekind == "sentencia":
            if arbol.kind == "if":
                file.write("if:" + arbol.child[0].value + "\n")
            elif arbol.kind == "do":
                file.write("do:" + arbol.child[0].value + " \n")
            elif arbol.kind == "repeat":
                file.write("repeat:" + arbol.child[1].value + "\n")
            elif arbol.kind == "asignacion":
                file.write("asignacion: " + str(arbol.attr) + "\n")
            elif arbol.kind == "cin":
                file.write("escritura: " + str(arbol.attr) + "\n")
            elif arbol.kind == "cout":
                file.write("lectura:\n")
            elif arbol.kind == "bloque":
                file.write("bloque: \n")
            elif arbol.kind == "while":
                file.write("while:" + arbol.child[0].value + "\n")
            elif arbol.kind == "break":
                file.write("break: \n")
            else:
                file.write("Sentencia desconocida\n")
        elif arbol.nodekind == "expresion":
            if arbol.kind == "op":
                file.write("operador: " + str(arbol.attr) + " " + str(arbol.type) + " " + str(arbol.value) + "\n")
            elif arbol.kind == "float" or arbol.kind == "integer":
                file.write("constante: " + str(arbol.attr) + " " + str(arbol.type) + " " + str(arbol.value) + "\n")
            elif arbol.kind == "id":
                file.write("id: " + str(arbol.attr) + " " + str(arbol.type) + " " + str(arbol.value) + "\n")
            else:
                file.write("Expresion desconocida\n")
        elif arbol.nodekind == "declaracion":
            if arbol.kind == "int":
                file.write("var int: \n")
            elif arbol.kind == "real":
                file.write("var real: \n")
            elif arbol.kind == "boolean":
                file.write("var boolean: \n")
            else:
                file.write("Declaracion desconocida\n")
        else:
            file.write("Token desconocido\n")

        for i in range(3):
            print_semantico(arbol.child[i],tabs+1)
        arbol = arbol.sibling


def espacios(tabs):
    for i in range(tabs):
        file.write(" ")



file = open('ArbolSyntactico.txt', 'w')
x = Syntactic()
y = x.programa()
print_arbol(y,0)
file.close()
Semantic2.pre(y,Semantic2.declaracion)
Semantic2.post(y,Semantic2.exptype)
print "value <--------------------------------------"
Semantic2.post(y, Semantic2.expvalue)
HaAsh.guardar(HaAsh.lista)
HaAsh.regresa_Val("x")

file = open('ArbolSemantico.txt', 'w')
print_semantico(y,0)
file.close()

codeGen.codeGen(y.child[1])

print "acabo"
