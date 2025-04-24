import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:cadartroapp/Helper/db_helper.dart';
import 'package:cadartroapp/Utils/StyleWidget/StyleButton.dart';

class Input extends StatefulWidget {
  @override
  _InputState createState() => _InputState();
}

class _InputState extends State<Input> {
  final _textController = TextEditingController();
  final _numController = TextEditingController();
  final databHelper = DatabaseHelper();
  List<Map<String, dynamic>> cadastros = [];

  @override
  void initState() {
    super.initState();
    carregarCadastros();
  }

  void carregarCadastros() async {
    final data = await databHelper.todosCadastros();
    setState(() {
      cadastros = data;
    });
  }

  void cadstrar() async {
    String texto = _textController.text;
    int? numero = _verificaNum(_numController.text);

    if (texto.isNotEmpty && numero != null && numero > 0) {
      try {
        await databHelper.cadastroInsert({'texto': texto, 'numero': numero});
        //limpando is inputs
        _textController.clear();
        _numController.clear();
        carregarCadastros();
        _showMessage(context, "Cadastro realizado com sucesso!");
      } catch (e) {
        if (e is DatabaseException && e.isUniqueConstraintError()) {
          _showMessage(
            context,
            'Este número já está cadastrado',
            isError: true,
          );
        } else {
          _showMessage(
            context,
            'Erro ao registrar ${e.toString()}',
            isError: true,
          );
        }
      }
    } else {
      _showMessage(
        context,
        "Algum campo esta incorreto, tente novamente!",
        isError: true,
      );
    }
  }

  //verifica se o valor do campo é um número válido
  int? _verificaNum(String numInput) {
    if (numInput.isEmpty) {
      return null;
    }
    int? verificaNum = int.tryParse(numInput);
    if (verificaNum == null || verificaNum < 0) {
      return null;
    }
    return verificaNum;
  }

  //exibe uma mensagem na tela quando os dados são carregados
  void _showMessage(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError
                ? const Color.fromARGB(121, 0, 0, 0)
                : const Color.fromARGB(183, 255, 255, 255),
        duration: isError ? Duration(seconds: 5) : Duration(seconds: 5),
      ),
    );
  }

  //input de casatro texto e numeros
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Área de Cadastro', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color(0xFF1C1C1E),
      ),
      body: Row(
        children: [
          // Coluna de Inputs (lado esquerdo)
          Expanded(
            flex: 1,
            child: Container(
              color: Color(0xFF2C2C2E),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _textController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Insira um Texto',
                          labelStyle: TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Color(0xFF3A3A3C),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white30),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      TextField(
                        controller: _numController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Insira Números',
                          labelStyle: TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Color(0xFF3A3A3C),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white30),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 32),
                      StyleButton(
                        onPressed: cadstrar,
                        text: 'Salvar',
                        type: ButtonType.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Coluna da tabela (lado direito)
          Expanded(
            flex: 2,
            child: Container(
              color: Color(0xFF3A3A3C),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ListView.builder(
                  itemCount: cadastros.length,
                  itemBuilder: (context, index) {
                    final cadastro = cadastros[index];
                    return Card(
                      color: Color(0xFF4A4A4C),
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          'Texto: ${cadastro['texto']}',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          'Número: ${cadastro['numero']}',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
