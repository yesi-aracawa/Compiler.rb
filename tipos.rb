TOKEN = Struct.new(:val,:tipo,:lin) do #token a mostrar con sus propiedades
    def to_s
      col_val = "\e[1m\e[32m"
      col_tip = "\e[1;36m"
      col_lin = "\e[1m\e[31m"
      "TOKEN: {#{col_val}val:'#{val}'\e[0m, #{col_tip}tipo:#{tipo}\e[0m, #{col_lin}lin:#{lin}\e[0m}"
    end
    def inspect
      to_s
    end
  end
  
  Nodo = Struct.new(:token,:gram,:padre,:hijos) do #nodo estructura
    def to_s
      "{ token: (#{token}), gram: #{gram}, padre: #{padre.to_s}, hijos: #{hijos} }"
    end
  end
  
  