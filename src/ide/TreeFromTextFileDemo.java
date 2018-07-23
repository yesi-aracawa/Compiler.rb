package ide;


import java.awt.BorderLayout;
import java.awt.Container;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTree;


public class TreeFromTextFileDemo {

private TreeFromTextFile tr = new TreeFromTextFile();
/*
public static void main(String[] args) {
    JFrame frame = new JFrame("Demo | Creating JTree From File.txt");
    frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    Container content = frame.getContentPane();

    JTree t = tr.getTree();

    content.add(new JScrollPane(t), BorderLayout.CENTER);
    frame.setSize(275, 300);
    frame.setLocationByPlatform(true);
    frame.setVisible(true);

    }*/

   /* public void crearArbol(){
        JFrame frame = new JFrame("Demo | Creating JTree From File.txt");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        Container content = frame.getContentPane();
        JTree t = tr.getTree();
        expande(t,0,t.getRowCount());
        content.add(new JScrollPane(t), BorderLayout.CENTER);
        frame.setSize(275, 300);
        frame.setLocationByPlatform(true);
        frame.setVisible(true);
    }*/
    public JPanel crearArbol(){
        JPanel panel = new JPanel();
        JTree t = tr.getTree();
        expande(t,0,t.getRowCount());
        panel.add(new JScrollPane(t), BorderLayout.CENTER);
        
        panel.setVisible(true);
        return panel;
    }
    
    public void expande(JTree arbol,int inicio,int fin){
    for (int i = inicio; i < fin; i++) {
        arbol.expandRow(i);
    }
    if (arbol.getRowCount()!=fin){
        expande(arbol,fin,arbol.getRowCount());
    }
}
}