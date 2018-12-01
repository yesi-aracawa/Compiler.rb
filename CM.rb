# #********************************************************/
# # Archivo: tm.c                                         */
# # La computadora TM ("Compiler Machine")                */
# # Construccidn de compiladores: principios y practica   */
# # Kenneth C. Louden                                     */
# #********************************************************/

Class maquina
    def init(self)
        self.IADDR_SIZE = 1024 # incremente para programas grandes */
        self.DADDR_SIZE = 1024 # incremente para programas grandes */
        self.PC_REG = 7
        self.STEPRESULT = ''

        self.iMem = {}
        self.dMem = []
        self.reg = []

        for i in (0..8)
            self.reg.append(0)
        end
        (self.DADDR_SIZE).each do |i|
            self.dMem.append(0)
        self.dMem[0] = self.DADDR_SIZE - 1
        end
    end

    def cargaInstrucciones(self) #lee el codigo intermedio
        ruta = "code_interm.txt"

        with open(ruta, "r") as archivo:
            contenido = archivo.read()
            contenido += "final"
        #print contenido
        renglones = contenido.split('\n')
        renglones.each do |aux|
            params = aux.split('\t')
            if params[0] != "final":
                if params[1] == 'LD' || params[1] == 'LDA' || params[1] == 'LDC' || params[1] == 'ST' \
                    || params[1] == 'JLT' || params[1] == 'JLE' || params[1] == 'JGE' || params[1] == 'JGT' \
                    || params[1] == 'JEQ' || params[1] == 'JNE':
                    obj = {
                        'opcode': params[1],
                        'r': params[2],
                        'd': params[3],
                        's': params[4]
                    }
                else
                    obj = {
                        'opcode': params[1],
                        'r': params[2],
                        's': params[3],
                        't': params[4]
                        }
                end
            end
            self.iMem[str(params[0])] = obj
         end
     end

    def error (self, msg, lineNo, instNo)
        print lineNo
        if instNo >= 0
            print 'Instruccion' + instNo
        end
        print msg
        return 0
     end

    def inicio(self):
        #print self.iMem
        self.STEPRESULT = 'OKAY'
        while self.STEPRESULT == 'OKAY' do
            self.STEPRESULT = self.ejecutarPaso()
        end
     end

    def ejecutarPaso(self)
        pc = self.reg[self.PC_REG]
        self.reg[self.PC_REG] = pc+1

        instActual = self.iMem[str(pc)]
        #print instActual

        if instActual.has_key('d')
            r = instActual['r']
            s = instActual['s']
            if type(eval(instActual['d'])) != float:
                m = int(instActual['d']) + self.reg[int(s)]
            else
                m = float(instActual['d']) + self.reg[int(s)]
            end
        else
            r = instActual['r']
            s = instActual['s']
            t = instActual['t']
        if instActual['opcode'] == 'HALT'
            print instActual['opcode'] + ' ' + str(r) + ' ' + str(s) + ' ' + str(t)
            return 'HALT'
        elsif instActual['opcode'] == 'ADD'
            self.reg[int(r)] = self.reg[int(s)] + self.reg[int(t)]
        elsif instActual['opcode'] == 'SUB'
            self.reg[int(r)] = self.reg[int(s)] - self.reg[int(t)]
        elsif instActual['opcode'] == 'MUL'
            self.reg[int(r)] = self.reg[int(s)] * self.reg[int(t)]
            #print 'a'
        elsif instActual['opcode'] == 'DIV'
            if self.reg[int(t)] == 0
                return 'ZERODIVIDE'
            else
                self.reg[int(r)] = self.reg[int(s)] / self.reg[int(t)]
            end
        elsif instActual['opcode'] == 'LD'
            self.reg[int(r)] = self.dMem[int(m)]
        elsif instActual['opcode'] == 'ST'
            self.dMem[int(m)] = self.reg[int(r)]
        elsif instActual['opcode'] == 'LDA'
            self.reg[int(r)] = int(m)
        elsif instActual['opcode'] == 'LDC'
            if type(eval(instActual['d'])) == float
                self.reg[int(r)] = float(instActual['d'])
            else
                self.reg[int(r)] = int(instActual['d'])
            end
        elsif instActual['opcode'] == 'JLT'
            if self.reg[int(r)] < 0
                self.reg[self.PC_REG] = int(m)
            end
        elsif instActual['opcode'] == 'JLE'
            if self.reg[int(r)] <= 0
                self.reg[self.PC_REG] = int(m)
            end
        elsif instActual['opcode'] == 'JGT'
            if self.reg[int(r)] > 0
                self.reg[self.PC_REG] = int(m)
            end
        elsif instActual['opcode'] == 'JGE'
            if self.reg[int(r)] >= 0
                self.reg[int(self.PC_REG)] = int(m)
            end
        elsif instActual['opcode'] == 'JEQ'
            if self.reg[int(r)] == 0
                self.reg[self.PC_REG] = int(m)
            end
        elsif instActual['opcode'] == 'JNE'
            if self.reg[int(r)] != 0
                self.reg[self.PC_REG] = int(m)
            end
        elsif instActual['opcode'] == 'IN'
            print 'CIN>>'
            begin
                dato = input()
                #tipo = self.hash.get()
                if type(dato) == float
                    self.reg[int(instActual['r'])] = float(dato)
                else
                    self.reg[int(instActual['r'])] = int(dato)
                end
            rescue StandardError => e
                #print e
                return 'INVALID VALUE'
            end
        elsif instActual['opcode'] == 'OUT'
            b = int(int(instActual['r']))
            print 'OUT>> ' + str(self.reg[b])
        end
        return 'OKAY'
    end
end

TEM = maquina()
TEM.cargaInstrucciones()
TEM.inicio()
