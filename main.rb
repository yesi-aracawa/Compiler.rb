require './lexico.rb'
require './sintacticoS.rb'
require './semantica.rb'
# require './CM.rb'
require './CGEN.rb'

$stdout.sync = true

l = Lexico.new
s = Sintactico.new
sem = Semantica.new
codeint = Codegen.new
#maquina = Maquina.new

tokens = l.lexico('lexico.txt')
arbol, error = s.init(tokens)
sem.init(arbol)
codeint.code_gen(arbol)
# maquina.cargaInstrucciones('code_interm.txt')
# maquina.inicio
# $arbol2, errorSem = sem.init($arbol)

