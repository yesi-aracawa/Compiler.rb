/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ide;
import java.io.*;

/**
 *
 * @author Darci
 */
public class GestionA {
    FileInputStream entrada;
    FileOutputStream salida;
    File archivo;
    
    public GestionA(){
        
    }
    
    /*Abrir un archivo de texto*/
    public String AbrirATexto(File archivo){
        String contenido="";
        try {
            entrada = new FileInputStream(archivo);
            int ascci;
            while((ascci = entrada.read())!= -1){
                char carcater = (char)ascci;
                contenido += carcater;
            }
        } catch (Exception e) {
        }
        return contenido;
    }
    
    /*Guardar archivo de texto*/
    public String GuardarATexto(File archivo, String contenido){
        String respuesta=null;
        try {
            salida = new FileOutputStream(archivo);
            byte[] bytesTxt = contenido.getBytes();
            salida.write(bytesTxt);
            respuesta = "Se guardo con exito el archivo";
        } catch (Exception e) {
        }
        return respuesta;
    }
    
    
}
