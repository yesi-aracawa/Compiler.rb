/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package ide;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.InputStreamReader;
import java.io.LineNumberReader;
import javax.swing.JTree;
import javax.swing.tree.DefaultMutableTreeNode;
import javax.swing.tree.TreeSelectionModel;
import javax.swing.JOptionPane;

/**
 * @author engineervix
 *
 */
public class TreeFromTextFile {

    private BufferedReader in;
    private LineNumberReader ln;
    private String line;    //value of a line in the text file
    private String root;    //value to be used for the root Node of our JTree                         
    private String filename = "sintactico.txt";
    private String encoding = "UTF-8";
    private DefaultMutableTreeNode top;
    private JTree tree;

    public TreeFromTextFile() {
        getRootNode();
        top = new DefaultMutableTreeNode(root);
        createNodes(top);

        //Create a tree that allows one selection at a time.
        tree = new JTree(top);
        tree.getSelectionModel().setSelectionMode(TreeSelectionModel.SINGLE_TREE_SELECTION);
    }

//this method reads the file and prints all the lines to standard output
//for testing purposes
    public void readFile() {
        try {
            //in = new BufferedReader(new FileReader("Path\\To\\File.txt"));
            in = new BufferedReader(new FileReader("sintactico.txt"));

            while ((line = in.readLine()) != null) {
                System.out.println(line);
            }
            in.close();
        } catch (Exception e) {

            e.printStackTrace();
        }
    }

//this method reads the first line in the text file and assigns it 
//to the root variable which will be used for the root node of our JTree
    private void getRootNode() {
        try {
            //in = new BufferedReader(new FileReader("Path\\To\\File.txt"));
            in = new BufferedReader(new FileReader("sintactico.txt")); //puede llevar c: y la direccion del archivo
            ln = new LineNumberReader(in);

            if (ln.getLineNumber() == 0) {
                root = ln.readLine();
                //System.out.println(root);
            }

            in.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * this method counts the number of occurrences of a given <code>char</code>
     * in the Specified <code>String</code> source:
     * https://stackoverflow.com/questions/275944/how-do-i-count-the-number-of-occurrences-of-a-char-in-a-string
     */
    private int countOccurrences(String haystack, char needle) {
        int count = 0;
        //JOptionPane.showMessageDialog(null,"checando a "+haystack );
        for (int i = 0; i < haystack.length(); i++) {
            if (haystack.charAt(i) == ' ') {
                count++;
            }
        }
        return count;
    }

//create the Nodes
    private void createNodes(DefaultMutableTreeNode top) {

        DefaultMutableTreeNode category = null;     // Level 1 in Hierarchy
        DefaultMutableTreeNode subCategory = null;  // Level 2 in Hierarchy
        DefaultMutableTreeNode leaf = null;         // Level 3 in Hierarchy   
        DefaultMutableTreeNode leaf1 = null;
        DefaultMutableTreeNode leaf2 = null;
        DefaultMutableTreeNode leaf3 = null;
        DefaultMutableTreeNode leaf4 = null;
        DefaultMutableTreeNode leaf5 = null;
        DefaultMutableTreeNode leaf6 = null;
        DefaultMutableTreeNode leaf7 = null;
        DefaultMutableTreeNode leaf8 = null;

        try {
            //in = new BufferedReader(new FileReader("TheTextFile.txt"));
            in = new BufferedReader(new FileReader("sintactico.txt"));
            while ((line = in.readLine()) != null) {
                if (countOccurrences(line, ' ') == 1) {
                    //JOptionPane.showMessageDialog(null, "entre a 1");
                    category = new DefaultMutableTreeNode(line);
                    top.add(category);
                } else if (countOccurrences(line, ' ') == 2) {
                    //JOptionPane.showMessageDialog(null, "entre a 2");
                    subCategory = new DefaultMutableTreeNode(line);
                    category.add(subCategory);
                } else if (countOccurrences(line, ' ') == 3) {
                    //JOptionPane.showMessageDialog(null, "entre a 3");
                    leaf = new DefaultMutableTreeNode(line);
                    subCategory.add(leaf);
                } else if (countOccurrences(line, ' ') == 4) {
                    //JOptionPane.showMessageDialog(null, "entre a 3");
                    leaf1 = new DefaultMutableTreeNode(line);
                    leaf.add(leaf1);
                } else if (countOccurrences(line, ' ') == 5) {
                    //JOptionPane.showMessageDialog(null, "entre a 3");
                    leaf2 = new DefaultMutableTreeNode(line);
                    leaf1.add(leaf2);
                } else if (countOccurrences(line, ' ') == 6) {
                    //JOptionPane.showMessageDialog(null, "entre a 3");
                    leaf3 = new DefaultMutableTreeNode(line);
                    leaf2.add(leaf3);
                } else if (countOccurrences(line, ' ') == 7) {
                    //JOptionPane.showMessageDialog(null, "entre a 3");
                    leaf4 = new DefaultMutableTreeNode(line);
                    leaf3.add(leaf4);
                } else if (countOccurrences(line, ' ') == 8) {
                    //JOptionPane.showMessageDialog(null, "entre a 3");
                    leaf5 = new DefaultMutableTreeNode(line);
                    leaf4.add(leaf5);
                } else if (countOccurrences(line, ' ') == 9) {
                    //JOptionPane.showMessageDialog(null, "entre a 3");
                    leaf6 = new DefaultMutableTreeNode(line);
                    leaf5.add(leaf6);
                } else if (countOccurrences(line, ' ') == 10) {
                    //JOptionPane.showMessageDialog(null, "entre a 3");
                    leaf7 = new DefaultMutableTreeNode(line);
                    leaf6.add(leaf7);
                }
            }
            in.close();
            //JOptionPane.showMessageDialog(null,"sali de a createNodes\n");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public JTree getTree() {
        return tree;
    }
}
