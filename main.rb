require './lexico.rb'
require './sintacticoS.rb'
#require './semantica.rb'
l = Lexico.new
s = Sintactico.new
#sem = Semantica.new

$tokens = l.lexico('lexico.txt')
$arbol, error = s.init($tokens)
#$arbol2, errorSem = sem.init($arbol)