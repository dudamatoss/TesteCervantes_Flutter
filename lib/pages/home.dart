import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:cadartroapp/Helper/db_helper.dart';
import 'package:cadartroapp/Utils/StyleWidget/StyleButton.dart';
import 'package:cadartroapp/Utils/StyleWidget/StyleInputs.dart';
import 'package:cadartroapp/Utils/StyleWidget/StyleTable.dart';

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
        duration: isError ? Duration(seconds: 2) : Duration(seconds: 1),
      ),
    );
  }
  //input de casatro texto e numeros
 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Teste Cervantes - Tela de Cadastro', style: TextStyle(color: Colors.white)),
      centerTitle: true,
      backgroundColor: Color(0xFF1C1C1E),
    ),
    body: Row(
      children: [
        // Coluna de Inputs 
        Expanded(
          flex: 1,
          child: Container(
            color: Color(0xFF2C2C2E),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      controller: _textController,
                      label: 'Insira um Texto',
                    ),
                    SizedBox(height: 24),
                    CustomTextField(
                      controller: _numController,
                      label: 'Insira Números',
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(width: 200,height: 45),
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
          //exibe tabela
          Expanded(
            flex: 2,
            child: Container(
              color:  StyleTable.containerColor,
              padding: StyleTable.padding, 
              child: ListView.builder(
                itemCount: cadastros.length,
                itemBuilder: (context, index) {
                  final cadastro = cadastros[index];
                  return Card(
                    color: StyleTable.cardColor,
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        'Texto: ${cadastro['texto']}',
                        style: StyleTable.titleStyle, 
                      ),
                      subtitle: Text(
                        'Número: ${cadastro['numero']}',
                        style: StyleTable.subtitleStyle, 
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
