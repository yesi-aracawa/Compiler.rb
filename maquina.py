import pickle

class maquina:
    def __init__(self):
        self.IADDR_SIZE = 1024
        self.DADDR_SIZE = 1024
        self.PC_REG = 7
        self.STEPRESULT = ''

        self.iMem = {}
        self.dMem = []
        self.reg = []

        for i in range(8):
            self.reg.append(0)
        for i in range(self.DADDR_SIZE):
            self.dMem.append(0)
        self.dMem[0] = self.DADDR_SIZE - 1

    def cargaInstrucciones(self):
        ruta = "intermedio.txt"

        with open(ruta, "r") as archivo:
            contenido = archivo.read()
            contenido += "final"
        #print contenido
        renglones = contenido.split('\n')
        for aux in renglones:
            params = aux.split('\t')
            if params[0] != "final":
                if params[1] == 'LD' or params[1] == 'LDA' or params[1] == 'LDC' or params[1] == 'ST' \
                    or params[1] == 'JLT' or params[1] == 'JLE' or params[1] == 'JGE' or params[1] == 'JGT' \
                    or params[1] == 'JEQ' or params[1] == 'JNE':
                    obj = {
                        'opcode': params[1],
                        'r': params[2],
                        'd': params[3],
                        's': params[4]
                    }
                else:
                    obj = {
                        'opcode': params[1],
                        'r': params[2],
                        's': params[3],
                        't': params[4]
                        }
            self.iMem[str(params[0])] = obj

    def error (self, msg, lineNo, instNo):
        print lineNo
        if instNo >= 0:
            print 'Instruccion' + instNo
        print msg
        return 0

    def inicio(self):
        #print self.iMem
        self.STEPRESULT = 'OKAY'
        while(self.STEPRESULT == 'OKAY'):
            self.STEPRESULT = self.ejecutarPaso()

    def ejecutarPaso(self):
        pc = self.reg[self.PC_REG]
        self.reg[self.PC_REG] = pc+1

        instActual = self.iMem[str(pc)]
        #print instActual

        if instActual.has_key('d'):
            r = instActual['r']
            s = instActual['s']
            if type(eval(instActual['d'])) != float:
                m = int(instActual['d']) + self.reg[int(s)]
            else:
                m = float(instActual['d']) + self.reg[int(s)]
        else:
            r = instActual['r']
            s = instActual['s']
            t = instActual['t']
        if instActual['opcode'] == 'HALT':
            print instActual['opcode'] + ' ' + str(r) + ' ' + str(s) + ' ' + str(t)
            return 'HALT'
        elif instActual['opcode'] == 'ADD':
            self.reg[int(r)] = self.reg[int(s)] + self.reg[int(t)]
        elif instActual['opcode'] == 'SUB':
            self.reg[int(r)] = self.reg[int(s)] - self.reg[int(t)]
        elif instActual['opcode'] == 'MUL':
            self.reg[int(r)] = self.reg[int(s)] * self.reg[int(t)]
            #print 'a'
        elif instActual['opcode'] == 'DIV':
            if self.reg[int(t)] == 0:
                return 'ZERODIVIDE'
            else:
                self.reg[int(r)] = self.reg[int(s)] / self.reg[int(t)]
        elif instActual['opcode'] == 'LD':
            self.reg[int(r)] = self.dMem[int(m)]
        elif instActual['opcode'] == 'ST':
            self.dMem[int(m)] = self.reg[int(r)]
        elif instActual['opcode'] == 'LDA':
            self.reg[int(r)] = int(m)
        elif instActual['opcode'] == 'LDC':
            if type(eval(instActual['d'])) == float:
                self.reg[int(r)] = float(instActual['d'])
            else:
                self.reg[int(r)] = int(instActual['d'])
        elif instActual['opcode'] == 'JLT':
            if self.reg[int(r)] < 0:
                self.reg[self.PC_REG] = int(m)
        elif instActual['opcode'] == 'JLE':
            if self.reg[int(r)] <= 0:
                self.reg[self.PC_REG] = int(m)
        elif instActual['opcode'] == 'JGT':
            if self.reg[int(r)] > 0:
                self.reg[self.PC_REG] = int(m)
        elif instActual['opcode'] == 'JGE':
            if self.reg[int(r)] >= 0:
                self.reg[int(self.PC_REG)] = int(m)
        elif instActual['opcode'] == 'JEQ':
            if self.reg[int(r)] == 0:
                self.reg[self.PC_REG] = int(m)
        elif instActual['opcode'] == 'JNE':
            if self.reg[int(r)] != 0:
                self.reg[self.PC_REG] = int(m)
        elif instActual['opcode'] == 'IN':
            print 'CIN>>'
            try:
                dato = input()
                #tipo = self.hash.get()
                if type(dato) == float:
                    self.reg[int(instActual['r'])] = float(dato)
                else:
                    self.reg[int(instActual['r'])] = int(dato)
            except Exception as e:
                #print e
                return 'INVALID VALUE'
        elif instActual['opcode'] == 'OUT':
            b = int(int(instActual['r']))
            print 'OUT>> ' + str(self.reg[b])
        return 'OKAY'

TEM = maquina()
TEM.cargaInstrucciones()
TEM.inicio()
