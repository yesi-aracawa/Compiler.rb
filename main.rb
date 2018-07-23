require './lexico.rb'
require './sintacticoS.rb'
#require './test.rb'
l = Lexico.new
s = Sintactico.new

$tokens = l.lexico('lexico.txt')

$arbol, error = s.init($tokens)