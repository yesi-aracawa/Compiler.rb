require './lexico.rb'
require './sintacticoS.rb'
require './semantica.rb'
require './cm.rb'
require './CGEN.rb'
l = Lexico.new
s = Sintactico.new
sem = Semantica.new
cm = Cm.new

$tokens = l.lexico('lexico.txt')
$arbol, error = s.init($tokens)
sem.init($arbol)

#$arbol2, errorSem = sem.init($arbol)
