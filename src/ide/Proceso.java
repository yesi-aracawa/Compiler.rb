/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ide;

import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.util.Scanner;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.swing.JOptionPane;
import javax.swing.JTextArea;

/**
 *
 * @author rockt
 */
public class Proceso extends Thread {
    public JTextArea txt;
    String resp;

    public Proceso(JTextArea txt) {
        this.txt = txt;
    }

    @Override
    public void run() {
        System.out.println("EJECUTANDO");
        ProcessBuilder builder = new ProcessBuilder("ruby", "C:\\Users\\yesi\\Projects\\Git\\compilador\\cm.rb");
        builder.redirectErrorStream(true);
        builder.redirectOutput();
        builder.redirectInput();
        
        try {
            Process process = builder.start();
            OutputStream stdin = process.getOutputStream();
            InputStream stdout = process.getInputStream();

            BufferedReader reader = new BufferedReader(new InputStreamReader(stdout));
            BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(stdin));
                        String line;

            while ((line = reader.readLine()) != null) {
                if (line.equals("read")) {
                    //String input = JOptionPane.showInputDialog("Ingrese su dato: ");
                    //writer.write(input + "\n");
                   // writer.flush();
                }else if (line.equals("exit")){
                    break;
                }else{
                     txt.append(line + "\n");
 //                    String aux = txt.getText();
   //                  txt.setText(aux + line);
                     System.out.println(line);
                }
               
            }         
            
            System.out.println("estoy fuera");
            

            
        } catch (IOException ex) {
            Logger.getLogger(Proceso.class.getName()).log(Level.SEVERE, null, ex);
        } 
    }
}
