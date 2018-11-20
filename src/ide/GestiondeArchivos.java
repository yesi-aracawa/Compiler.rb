/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ide;

import java.io.*;
import java.util.Random;
import javax.swing.JTextPane;
import sun.util.logging.PlatformLogger;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import javax.swing.JTextArea;
import javax.swing.text.Utilities;

/**
 *
 * @author Yesica
 */
public class GestiondeArchivos {

    FileInputStream entrada;
    FileOutputStream salida;
    File archivo;

    public GestiondeArchivos() {
    }

    //abrir archivo
    public String AbrirArchivo(File archivo) {
        String contenido = "";
        try {
            entrada = new FileInputStream(archivo);
            int ancci;
            while ((ancci = entrada.read()) != -1) {
                char caracter = (char) ancci;
                contenido += caracter;
            }
        } catch (Exception e) {

        }

        return contenido;
    }

    //guardar un archivo
    public String GuardarArchivoComo(File archivo, String contenido) {
        String respuesta = null;
        try {
            salida = new FileOutputStream(archivo);
            byte[] bytesTxt = contenido.getBytes();
            salida.write(bytesTxt);
            respuesta = "Archivo guardado Con Exito";
        } catch (Exception e) {
        }
        return respuesta;
    }

    void guardar(File archivo, JTextPane PaneldeCodigo) {
        try {
            FileWriter permite_escrito = new FileWriter(archivo.getPath());
            String texto = PaneldeCodigo.getText();
            PrintWriter imprime = new PrintWriter(permite_escrito);
            imprime.print(texto);

            permite_escrito.close();
        } catch (Exception ex) {

        }
    }
    
   /* public String numeracion(JTextPane PaneldeCodigo) {
        String cad = "";
        String reng = PaneldeCodigo.getText();
        //int aux=1;
        String[] div = reng.split("\n");
        cad = cad + 1 + "\n";
        for (int i = 1; i < div.length; i++) {
            cad = cad + (i + 1) + "\n";
            // aux = i+1;
        }
        // cad = cad + (aux+1) + "\n";
        return cad;
    }*/

    void limpiar(JTextPane PaneldeCodigo) {
        PaneldeCodigo.setText("");
    }

    void cerrar()
    {
        try
        {
            //entrada.close();
            salida.close();
            //archivo.
        }
        catch(Exception ex)
        {
            
        }
        
    }
    
}
