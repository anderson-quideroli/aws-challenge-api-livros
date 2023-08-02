from flask import Flask, jsonify, request

#criação do objeto Flask
app = Flask(__name__)

#Dicionarios criado dentro da lista livros.
livros = [
    {
        'id': 1,
        'título': 'O Senhor dos Anéis - A Sociedade do Anel',
        'autor': 'J.R.R Tolkien'
    },
    {
        'id': 2,
        'título': 'Harry Potter e a Pedra Filosofal',
        'autor': 'J.K Howling'

    },
    {
        'id': 3,
        'título': 'James Clear',
        'autor': 'Hábitos Atômicos'
    },
    {
        'id': 4,
        'título': 'teste3',
        'autor': 'Anderson Quideroli'
    },

]


#Consulta(Todos os livros)
@app.route('/livros',methods=['GET'])
def obter_livros():
    return jsonify(livros)

#Consulta Livro por ID
@app.route('/livros/<int:id>',methods=['GET'])
def obter_livro_id(id):
    for livro in livros:
       if livro.get('id') == id:
           return jsonify(livro)
#Editar livro por ID
@app.route('/livros/<int:id>',methods=['PUT'])
def editar_livro_por_id(id):
    livro_alterado = request.get_json()
    for indice,livro in enumerate(livros):
        if livro.get('id') == id:
            livros[indice].update(livro_alterado)
            return jsonify(livros[indice])
#Criar livro
@app.route('/livros',methods=['POST'])
def incluir_novo_livro():
    novo_livro = request.get_json()
    livros.append(novo_livro)
    
    return jsonify(livros)
#Deletar livro
@app.route('/livros/<int:id>',methods=['DELETE'])
def excluir_livro(id):
    for indice, livro in enumerate(livros):
        if livro.get('id') == id:
            del livros[indice]

    return jsonify(livros)


#Inicialização do servidor web na porta 8080/TCP
app.run(port=8080,host='0.0.0.0',debug=True)
