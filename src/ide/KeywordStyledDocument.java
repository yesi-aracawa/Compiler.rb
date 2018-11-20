/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ide;

import java.awt.Color;
import java.util.ArrayList;
import java.util.List;
import javax.swing.text.AttributeSet;
import javax.swing.text.BadLocationException;
import javax.swing.text.DefaultStyledDocument;
import javax.swing.text.Style;
import javax.swing.text.StyleConstants;
import javax.swing.text.StyleContext;

/**
 *
 * @author Ezequiel
 */
public class KeywordStyledDocument extends DefaultStyledDocument {

    private static final long serialVersionUID = 1L;
    private Style _defaultStyle;
    private Style _cwStyle;
    private Style _cwStyleN;
    private Style _cwStyleC;
    private Style _cwStyleM;
    private Style _cwStyleNegritas;
    private Style _cwStyleCadena;

    public KeywordStyledDocument() {
        System.out.println("entre");
        StyleContext styleContext = new StyleContext();
        Style defaultStyle = styleContext.getStyle(StyleContext.DEFAULT_STYLE);

        Style cwStyle = styleContext.addStyle("ConstantWidth", null);
        StyleConstants.setForeground(cwStyle, Color.BLUE);
        StyleConstants.setBold(cwStyle, true);
        _defaultStyle = defaultStyle;
        _cwStyle = cwStyle;

        Style cwStyleN = styleContext.addStyle("ConstantWidth", null);
        StyleConstants.setForeground(cwStyleN, Color.RED);
        StyleConstants.setBold(cwStyleN, true);
        _cwStyleN = cwStyleN;

        Style cwStyleC = styleContext.addStyle("ConstantWidth", null);
        StyleConstants.setForeground(cwStyleC, Color.GREEN);
        StyleConstants.setBold(cwStyleC, true);
        _cwStyleC = cwStyleC;

        Style cwStyleM = styleContext.addStyle("ConstantWidth", null);
        StyleConstants.setForeground(cwStyleM, Color.ORANGE);
        StyleConstants.setBold(cwStyleM, true);
        _cwStyleM = cwStyleM;
        
         Style cwStyleCadena = styleContext.addStyle("ConstantWidth", null);
        StyleConstants.setForeground(cwStyleCadena, Color.PINK);
        StyleConstants.setBold(cwStyleCadena, true);
        _cwStyleCadena = cwStyleCadena;

        Style cwStyleNegritas = styleContext.addStyle("ConstantWidth", null);
        StyleConstants.setForeground(cwStyleNegritas, Color.BLACK);
        StyleConstants.setBold(cwStyleNegritas, true);
        _cwStyleNegritas = cwStyleNegritas;
    }

    public void insertString(int offset, String str, AttributeSet a) throws BadLocationException {
        super.insertString(offset, str, a);
        refreshDocument();
    }

    public void remove(int offs, int len) throws BadLocationException {
        super.remove(offs, len);
        refreshDocument();
    }

    private synchronized void refreshDocument() throws BadLocationException {
        String text = getText(0, getLength());
        final List<HiliteWord> list = processWords(text);
        final List<HiliteWord> list2 = processWords2(text);
        final List<HiliteWord> list3 = processWords3(text);

        int i, j;

        setCharacterAttributes(0, text.length(), _defaultStyle, true);
        for (HiliteWord word : list) {
            int p0 = word._position;
            setCharacterAttributes(p0, word._word.length(), _cwStyle, true);
        }

        for (HiliteWord word : list2) {
            int p0 = word._position;
            setCharacterAttributes(p0, word._word.length(), _cwStyleN, true);
        }

        for (HiliteWord word : list3) {
            int p0 = word._position;
            setCharacterAttributes(p0, word._word.length(), _cwStyleNegritas, true);
        }

        for (i = 0; i < text.length() - 1; i++) {
             if (text.charAt(i) == '"') {
                j = i;
                do {
                    j++;
                } while (j < text.length() && text.charAt(j) != '"'); j++;
                setCharacterAttributes(i, j - i, _cwStyleCadena, true);
                i = j;
            } else if (text.charAt(i) == '/' && text.charAt(i + 1) == '/') {
                j = i;
                do {
                    j++;
                } while (j < text.length() && text.charAt(j) != '\n');
                setCharacterAttributes(i, j - i, _cwStyleC, true);
                i = j;
            } else 
                if (text.charAt(i) == '/' && text.charAt(i + 1) == '*') {
                j = i + 2;
                while (j < text.length() - 1 && !(text.charAt(j) == '*' && text.charAt(j + 1) == '/')) {
                    j++;
                }
                if (j == text.length()) {
                    setCharacterAttributes(i, text.length() - i, _cwStyleM, true);

                } else {
                    System.out.println("j " + j + " i " + i);
                    setCharacterAttributes(i, j - i + 2, _cwStyleM, true);
                }
                i = j + 2;
            }
        }

    }

    private static List<HiliteWord> processWords(String content) {
        System.out.println("palabra reservada");
        content += " ";
        List<HiliteWord> hiliteWords = new ArrayList<HiliteWord>();
        int lastWhitespacePosition = 0;
        String word = "";
        char[] data = content.toCharArray();
        for (int index = 0; index < data.length; index++) {
            char ch = data[index];
            if (!(Character.isLetter(ch) || Character.isDigit(ch) || ch == '_')) {
                lastWhitespacePosition = index;
                if (word.length() > 0) {
                    if (isReservedWord(word)) {
                        hiliteWords.add(new HiliteWord(word, (lastWhitespacePosition - word.length())));
                    }
                    word = "";
                }
            } else {
                word += ch;
            }
        }
        return hiliteWords;
    }

    private static List<HiliteWord> processWords3(String content) {
        System.out.println("identificador");
        content += " ";
        List<HiliteWord> hiliteWords = new ArrayList<HiliteWord>();
        int lastWhitespacePosition = 0;
        String word = "";
        char[] data = content.toCharArray();
        for (int index = 0; index < data.length; index++) {
            char ch = data[index];
            if (!(Character.isLetter(ch) || Character.isDigit(ch) || ch == '_')) {
                lastWhitespacePosition = index;
                if (word.length() > 0) {
                    if (!(isReservedWord(word)) && !(isNumber(word))) {
                        hiliteWords.add(new HiliteWord(word, (lastWhitespacePosition - word.length())));
                    }
                    word = "";
                }
            } else {
                word += ch;
            }
        }
        return hiliteWords;
    }

    private static List<HiliteWord> processWords2(String content) {
        content += " ";
        List<HiliteWord> hiliteWords = new ArrayList<HiliteWord>();
        int lastWhitespacePosition = 0;
        String word = "";
        char[] data = content.toCharArray();
        for (int index = 0; index < data.length; index++) {
            char ch = data[index];
            if (!(Character.isLetter(ch) || Character.isDigit(ch) || ch == '_')) {
                lastWhitespacePosition = index;
                if (word.length() > 0) {

                    if (isNumber(word)) {
                        hiliteWords.add(new HiliteWord(word, (lastWhitespacePosition - word.length())));
                    }
                    word = "";
                }
            } else {
                word += ch;
            }
        }
        return hiliteWords;
    }

    private static final boolean isReservedWord(String word) {
        return (word.equals("integer")
                || word.equals("real")
                || word.equals("main")
                || word.equals("if")
                || word.equals("then")
                || word.equals("else")
                || word.equals("end")
                || word.equals("do")
                || word.equals("while")
                || word.equals("repeat")
                || word.equals("until")
                || word.equals("read")
                || word.equals("write")
                || word.equals("float")
                || word.equals("integer")
                || word.equals("bool"));
    }

    private static final boolean isNumber(String word) {

        try {
            Integer.parseInt(word);
            return true;
        } catch (NumberFormatException nfe) {
            return false;
        }

    }

}
