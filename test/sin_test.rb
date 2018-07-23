require './lexico.rb'

module SinTest
    class TypeSum < Struct.new(:input, :expect)
    end
  
    DATA = [
        TypeSum.new('1_input.txt', '1_expect.txt'),
        TypeSum.new('2_input.txt', '2_expect.txt'),
        TypeSum.new('3_input.txt', '3_expect.txt'),
        TypeSum.new('4_input.txt', '4_expect.txt'),
        TypeSum.new('5_input.txt', '5_expect.txt'),
        TypeSum.new('6_input.txt', '6_expect.txt'),
        TypeSum.new('7_input.txt', '7_expect.txt'),
        TypeSum.new('8_input.txt', '8_expect.txt'),
    ]
  
    def test_sintactico(t)
      s = Sintactico.new
      l = Lexico.new
      path = './test/'
      i = 1

      DATA.each do |ts|
        testear(t, i, s, l, path, ts)
        i = i + 1
      end
    end
  end

  def testear(t, i, s, l, path, ts)
    t.log("\n------ TEST #{i}")
    if !File.exist?(path + ts.expect)
      puts "No existe: " + path + ts.expect
      return
    end
    expect = File.open(path + ts.expect,'r').read
    tokens = l.lexico(path + ts.input)
    arbol, err = s.init(tokens)
    puts "Test ##{i}" + err.to_s
    str = s.printa(arbol, "", true, "")
    unless expect == str
      t.error("\n------------ Expect:\n#{expect}\n------------ Got:\n#{str}\n")
    end
  end