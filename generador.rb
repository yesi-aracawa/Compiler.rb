def generar
    arr = ['main', 'if', 'then', 'else', 'end', 'do','while','repeat', 'until', 'read', 'write', 'float', 'integer', 'bool',
        'a', 'b', 'c', 'd', 'f', 'g', '"Hola"', '"Hola', 'Hola"', ':=', ':', '=', '!', '!=', '+', '++', '-', '--', '%', '/',
        '//', '/*', '*/', '<', '<=', '>', '>=', '==', '(', ')', '{', '}', '[', ']',',',';']
    str = 'main {'
    r = Random.new
    len = r.rand(256)
    while len > 0
        i = r.rand(arr.length-1)
        str = str + ' ' + arr[i]
        len = len - 1
    end
    str = str + "}"
    return str
end

i = 3
while i < 9
    File.truncate("./gold/#{i}_input.txt", 0)
    File.open("./gold/#{i}_input.txt", 'w') do |f1|
        f1.puts generar
    end
    i = i + 1
end