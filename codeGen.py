import os
import sys
import HaAsh

flag = True
emitloc = 0
highemitloc = 0
tmpoffset = 0
ac = 0
ac1 = 1
gp = 5
mp = 6
pc = 7

def codeGen(t):
    global mp, ac
    file = open('intermedio.txt', 'w')
    file.write("")
    file.close()
    s = "File:intermedio.tm\n"
    emitComment("TINY Compilation to TM Code")
    emitComment(s)
    emitComment("Standard prelude:")
    emitRM("LD",mp,0,ac,"load maxaddress from location 0")
    emitRM("ST",ac,0,ac,"clear location 0")
    emitComment("End of standard prelude.")
    cGen(t)
    emitComment("End of execution.")
    emitRO("HALT",0,0,0,"")

def escribir(code):
    file = open('intermedio.txt', 'a')
    file.write(code)
    file.write("\n")
    file.close()

def cGen(t):
    if  t != None:
        if t.nodekind == "sentencia":
            genStmt(t)
        elif t.nodekind == "expresion":
            genExp(t)
        cGen(t.sibling)


def genStmt(t):
    global ac, pc, gp, flag
    p1 = 0
    p2 = 0
    p3 = 0
    savedloc1 = 0
    savedloc2 = 0
    currentloc = 0
    loc = 0
    if t.kind == "if":
        if flag: emitComment("-> if");
        p1 = t.child[0]
        p2 = t.child[1]
        p3 = t.child[2]

        cGen(p1)
        savedLoc1 = emitSkip(1)
        emitComment("if: jump to else belongs here")

        cGen(p2)
        savedLoc2 = emitSkip(1)
        emitComment("if: jump to end belongs here")
        currentLoc = emitSkip(0)
        emitBackup(savedLoc1)
        emitRM_Abs("JEQ", ac, currentLoc, "if: jmp to else")
        emitRestore()

        cGen(p3)
        currentLoc = emitSkip(0)
        emitBackup(savedLoc2)
        emitRM_Abs("LDA", pc, currentLoc, "jmp to end")
        emitRestore()
        if flag: emitComment("<- if")

    elif t.kind == "repeat":
        if flag: emitComment("-> repeat")
        p1 = t.child[0]
        p2 = t.child[1]
        savedLoc1 = emitSkip(0)
        emitComment("repeat: jump after body comes back here")
        cGen(p1)

        cGen(p2)
        emitRM_Abs("JEQ", ac, savedLoc1, "repeat: jmp back to body")
        if flag: emitComment("<- repeat")

    elif t.kind == "while":
        loc1 = emitSkip(0)

        cGen(t.child[0])
        loc2 = emitSkip(1)

        cGen(t.child[1])
        currentLoc = emitSkip(0)
        emitBackup(loc2)
        emitRM_Abs('JEQ', ac, (currentLoc+ 1))
        #if fBreak:
        #    emitBackup(b)
        #    emitRM_Abs('LDA', pc, (currentLoc + 1))
        #    fBreak = False
        emitRestore()
        emitRM_Abs('LDA', pc, loc1)

    elif t.kind == "asignacion":
        if flag: emitComment("-> assign")
        cGen(t.child[0])
        loc = HaAsh.st_lookup(t.attr)
        emitRM("ST",ac,loc,gp,"assign: store value")
        if flag:  emitComment("<- assign")

    elif t.kind == "cin":
        emitRO("IN",ac,0,0,"read integer value")
        print HaAsh.st_lookup(t.attr), "hellow", t.attr
        loc = HaAsh.st_lookup(t.attr)
        emitRM("ST",ac,loc,gp,"read: store value")

    elif t.kind == "cout":
        cGen(t.child[0])
        emitRO("OUT",ac,0,0,"write ac")

    elif t.kind == "do":
        if flag: emitComment("-> do")
        p1 = t.child[0]
        p2 = t.child[1]
        savedLoc1 = emitSkip(0)
        emitComment("do: jump after body comes back here")
        cGen(p1)

        cGen(p2)
        emitRM_Abs("JEQ", ac, savedLoc1, "do: jmp back to body")
        if flag: emitComment("<- do")

    elif t.kind == "bloque":
        cGen(t.child[0])

def genExp(t):
    global tmpoffset, gp, mp, ac, ac1
    loc = 0
    p1 = 0
    p2 = 0
    if t.kind == "real" or t.kind == "integer":
        if flag: emitComment("-> Const")
        emitRM("LDC",ac,t.attr,0,"load const")
        if flag:  emitComment("<- Const")
    elif t.kind == "id":
        if flag: emitComment("-> Id")
        loc = HaAsh.st_lookup(t.attr)
        emitRM("LD",ac,loc,gp,"load id value")
        if flag: emitComment("<- Id")
    elif t.kind == "op":
        if flag: emitComment("-> Op")
        p1 = t.child[0]
        p2 = t.child[1]
        cGen(p1)
        emitRM("ST",ac,tmpoffset,mp,"op: push left")
        tmpoffset = tmpoffset - 1
        cGen(p2)
        tmpoffset = tmpoffset + 1
        emitRM("LD",ac1,tmpoffset,mp,"op: load left")
        if t.attr == "+":
            emitRO("ADD",ac,ac1,ac,"op +")
        elif t.attr == "-":
            emitRO("SUB",ac,ac1,ac,"op -")
        elif t.attr == "*":
            emitRO("MUL",ac,ac1,ac,"op *")
        elif t.attr == "/":
            emitRO("DIV",ac,ac1,ac,"op /")
        elif t.attr == "<":
            emitRO("SUB", ac, ac1, ac, "op <")
            emitRM("JLT", ac, 2, pc, "br if true")
            emitRM("LDC", ac, 0, ac, "false case")
            emitRM("LDA", pc, 1, pc, "unconditional jmp")
            emitRM("LDC", ac, 1, ac, "true case")
        elif t.attr == "<=":
            emitRO("SUB", ac, ac1, ac, "op <=")
            emitRM("JLE", ac, 2, pc, "br if true")
            emitRM("LDC", ac, 0, ac, "false case")
            emitRM("LDA", pc, 1, pc, "unconditional jmp")
            emitRM("LDC", ac, 1, ac, "true case")
        elif t.attr == '>':
            emitRO('SUB', ac, ac1, ac, "op >")
            emitRM('JGT', ac, 2, pc, "br if true")
            emitRM('LDC', ac, 0, ac, "false case")
            emitRM('LDA', pc, 1, pc, "unconditional jmp")
            emitRM('LDC', ac, 1, ac, "true case")
        elif t.attr == '>=':
            emitRO('SUB', ac, ac1, ac, "op >=")
            emitRM('JGE', ac, 2, pc, "br if true")
            emitRM('LDC', ac, 0, ac, "false case")
            emitRM('LDA', pc, 1, pc, "unconditional jmp")
            emitRM('LDC', ac, 1, ac, "true case")
        elif t.attr == "==":
            emitRO("SUB", ac, ac1, ac, "op ==")
            emitRM("JEQ", ac, 2, pc, "br if true")
            emitRM("LDC", ac, 0, ac, "false case")
            emitRM("LDA", pc, 1, pc, "unconditional jmp")
            emitRM("LDC", ac, 1, ac, "true case")
        elif t.attr == "!=":
            emitRO("SUB", ac, ac1, ac, "op !=")
            emitRM("JNE", ac, 2, pc, "br if true")
            emitRM("LDC", ac, 0, ac, "false case")
            emitRM("LDA", pc, 1, pc, "unconditional jmp")
            emitRM("LDC", ac, 1, ac, "true case")
        else:
            emitComment("BUG: Unknown operator")
        if flag:  emitComment("<- Op")

def emitComment(c):
    global flag
    if flag: print(c)

def emitRO(op, r, s, t, c):
    global emitloc, highemitloc, flag
    m = str(emitloc) + "\t" + str(op) + "\t" + str(r) + "\t" + str(s) + "\t" + str(t)
    print m
    escribir(m)
    #print emitloc,op,r,s,t
    emitloc = emitloc + 1
    if flag: print(c)
    #print("\n")
    if highemitloc < emitloc: highemitloc = emitloc

def emitRM(op, r, d, s, c):
    global emitloc, highemitloc, flag
    m = str(emitloc) + "\t" + str(op) + "\t" + str(r) + "\t" + str(d) + "\t" + str(s)
    print m
    escribir(m)
    #print emitloc, op, r, d, s
    emitloc = emitloc + 1
    if flag: print(c)
    #print("\n")
    if (highemitloc < emitloc):  highemitloc = emitloc

def emitSkip(howmany):
    global emitloc, highemitloc
    i = emitloc
    emitloc = emitloc + howmany
    if (highemitloc < emitloc):  highemitloc = emitloc
    return i

def emitBackup(loc):
    global emitloc, highemitloc
    if (loc > highemitloc): emitComment("BUG in emitBackup")
    emitloc = loc

def emitRestore():
    global emitloc, highemitloc
    emitloc = highemitloc

def emitRM_Abs(op, r, a, c):
    global emitloc, highemitloc, pc, flag
    m = str(emitloc) + "\t" + str(op) + "\t" + str(r) + "\t" + str(int(a-(emitloc+1))) + "\t" + str(pc)
    print m
    escribir(m)
    #print emitloc,op,r,(a-(emitloc+1)),pc
    emitloc = emitloc + 1
    if flag: print(c)
    #print ("\n")
    if highemitloc < emitloc: highemitloc = emitloc

