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
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import javax.swing.JTextArea;

/**
 *
 * @author rockt
 */
public class Proceso extends Thread {

    public JTextArea txt;
    public String salida = "";
    BufferedWriter w;
    BufferedReader r;
    String resp;

    public Proceso(JTextArea txt) {
        this.txt = txt;
        txt.addKeyListener(new KeyListener() {
            @Override
            public void keyTyped(KeyEvent e) {
            }

            @Override
            public void keyPressed(KeyEvent e) {
                salida += Character.toString(e.getKeyChar());
                //System.out.println(salida);
                if (e.getKeyChar() == KeyEvent.VK_ENTER) {
                    try {
                        w.write(salida);
                        w.flush();
                        salida = "";
                    } catch (IOException ex) {
                        System.out.println("Ocurrio excepcion");
                        System.err.println(ex.getMessage());
                    }
                }
            }

            @Override
            public void keyReleased(KeyEvent e) {
            }
        });
    }

    @Override
    public void run() {
        try {
            ProcessBuilder builder = new ProcessBuilder("python", "-u", "maquina.py");
            Process p = builder.start();

            r = new BufferedReader(new InputStreamReader(p.getInputStream()));
            w = new BufferedWriter(new OutputStreamWriter(p.getOutputStream()));
            
            resp = r.readLine();
            while (resp != null) {
                if ("CIN>>".equals(resp)) {
                    txt.append(resp + "\n");
                    resp = r.readLine();
                } else {
                    txt.append(resp + "\n");
                    resp = r.readLine();
                }
            }
            
        } catch (IOException ex) {
            System.err.println(ex.getMessage());
        } catch (Throwable ex) {
            System.err.println(ex.getMessage());
        }
    }
}
