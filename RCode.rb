# /********************************************************/
# /*Archivo: code.c                                       */
# /* Implementacion de utilidades de emision de codigo TM */
# /* para el compilador TINY                              */
# /* Construccion de compiladores: principios y practica  */
# /* Kenneth C. Louden                                    */
# /********************************************************/

#include "globals.h"
#include "code.h"

# /* Numero de localidad TM para la emisi�n de la instrucci�n actual*/
emitLoc = 0 

# Localidad TM mas alta emitida hasta ahora
#    Para su uso en conjunto con emitSkip,
#    emitBackup y emitRestore
highEmitLoc = 0

# /* El procedimiento emitComment imprime una l�nea de comentario
#  * con comentario c en el archivo de c�digo
#  */
def emitComment( char * c )
 if (TraceCode) fprintf(code,"* %s\n",c)end

# /* El procedimiento emitRO emite una
#  * instruccion TM solo de registro
#  * op = el opcode
#  * r = registro objetivo
#  * s = ler. registro fuente
#  * t = 2do. registro fuente
#  * c = un comentario para ser impreso si TraceCode es TRUE
#  */
def emitRO( char *op, int r, int s, int t, char *c)
 fprintf(code,"%3d:  %5s  %d,%d,%d ",emitLoc++,op,r,s,t)
  if (TraceCode) fprintf(code,"\t%s",c) 
  fprintf(code,"\n") 
  if (highEmitLoc < emitLoc) highEmitLoc = emitLoc 
 end # emitRO 

#  El procedimiento emitRM emite una instrucci�n TM
#  * de registro-a-memoria
#  * op = el opcode
#  * r = registro objetivo
#  * d = el desplazamiento
#  * s = el registro base
#  * c = un comentario para imprimirse si TraceCode es TRUE
#  */
def emitRM( char * op, int r, int d, int s, char *c)
 fprintf(code,"%3d:  %5s  %d,%d(%d) ",emitLoc++,op,r,d,s)
  if (TraceCode) fprintf(code,"\t%s",c) 
  fprintf(code,"\n") 
  if (highEmitLoc < emitLoc)  highEmitLoc = emitLoc 
end # emitRM */

# /* La funci�n emitSkip salta las localidades de c�digo "howMany"
#  * para reajuste posterior. Tambi�n
#  * devuelve la posici�n del c�digo actual
#  */
int emitSkip( int howMany)
  int i = emitLoc
   emitLoc += howMany 
   if (highEmitLoc < emitLoc)  highEmitLoc = emitLoc 
   return i
end # emitSkip */

#  El procedimiento emitBackup respalda a
#  * loc = una localidad previamente saltada
#  
def emitBackup( int loc)
 if (loc > highEmitLoc) emitComment("BUG in emitBackup")
  emitLoc = loc 
end # emitBackup */

# El procedimiento emitRestore restablece la posicidn
#  * del c�digo actual a la m�s alta
#  * posici�n no emitida previamente
#  */
def emitRestore
 emitLoc = highEmitLocend
end
# /* El procedimiento emitRM_Abs convierte una referencia absoluta
#  * en una referencia relativa al pc cuando se emite una
#  * instrucci�n TM de registro a memoria
#  * op = el opcode (c�digo operacional)
#  * r = registro objetivo
#  * a = la localidad absoluta en memoria
#  * c = un comentario para imprimirse si TraceCode es TRUE
#  */
def emitRM_Abs( char *op, int r, int a, char * c)
 fprintf(code,"%3d:  %5s  %d,%d(%d) ",
               emitLoc,op,r,a-(emitLoc+1),pc)
  ++emitLoc 
  if (TraceCode) fprintf(code,"\t%s",c) 
  fprintf(code,"\n") 
  if (highEmitLoc < emitLoc) highEmitLoc = emitLoc 
end # emitRM_Abs */
