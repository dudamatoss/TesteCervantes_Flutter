import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:cadartroapp/Helper/db_helper.dart';
import 'package:cadartroapp/Utils/StyleWidget/StyleButton.dart';
import 'package:cadartroapp/Utils/StyleWidget/StyleInputs.dart';
import 'package:cadartroapp/Utils/StyleWidget/StyleTable.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int? numEditar;
  final TextEditingController textController = TextEditingController();
  final TextEditingController numController = TextEditingController();
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
    String texto = textController.text;
    int? numero = _verificaNum(numController.text);

    if (texto.isNotEmpty && numero != null && numero > 0) {
      try {
        await databHelper.cadastroInsert({'texto': texto, 'numero': numero});
        //limpando is inputs
        textController.clear();
        numController.clear();
        carregarCadastros();
        ExibirMsg(context, "Cadastro realizado com sucesso!");
      } catch (e) {
        if (e is DatabaseException && e.isUniqueConstraintError()) {
          ExibirMsg(context, 'Este número já está cadastrado', isError: true);
        } else {
          ExibirMsg(
            context,
            'Erro ao registrar ${e.toString()}',
            isError: true,
          );
        }
      }
    } else {
      ExibirMsg(
        context,
        "Algum campo esta incorreto ou vazio, tente novamente!",
        isError: true,
      );
    }
  }
  //metodo de deletar pou numero
  void deletar(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirmar exclusão'),
            content: Text('Tem certeza que deseja excluir este cadastro?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Excluir', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
    if (confirm == true) {
      final numero = cadastros[index]['numero'];
      // Chama a função do banco deletar
      final rowDelet = await databHelper.cadastroDelete(numero);
      ExibirMsg(context, "Cadastro deletado com sucesso");
      carregarCadastros();
      if (rowDelet > 0) {
        carregarCadastros();
      } else {
        ExibirMsg(context, "Erro ao excluir");
      }
    }
  }
  //metodo de editar
  void editar() async {
  final texto = textController.text;
  final novoNum = int.tryParse(numController.text);
    if (texto.isNotEmpty && novoNum != null && novoNum > 0 && numEditar != null) {
      final dadoEdit = {
        'texto': texto,
        'numero': novoNum,
      };
      await databHelper.cadastroEdit(numEditar!, dadoEdit); 
      ExibirMsg(context, "Seu cadastro foi atualizado com sucesso");
      setState(() {
        numEditar = null;
        textController.clear();
        numController.clear();
      });
      carregarCadastros();
    } else {
      ExibirMsg(
        context,
        "Algum campo está incorreto ou vazio, tente novamente!",
        isError: true,
      );
    }
}
  //preenche o input na hora da ediação
  void inputEdicao(Map<String, dynamic> cadastro) {
    setState(() {
      textController.text = cadastro['texto'];
      numController.text = cadastro['numero'].toString();
      numEditar = cadastro['numero'];
    });
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
  void ExibirMsg(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError
                ? const Color.fromARGB(121, 0, 0, 0)
                : const Color.fromARGB(183, 4, 94, 10),
        duration: isError ? Duration(seconds: 2) : Duration(seconds: 1),
      ),
    );
  }
  //input de casatro texto e numeros
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Teste Cervantes - Tela de Cadastro',
          style: TextStyle(color: Colors.white),
        ),
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
                        controller: textController,
                        label: 'Insira um Texto',
                      ),
                      SizedBox(height: 24),
                      CustomTextField(
                        controller: numController,
                        label: 'Insira Números',
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(width: 200, height: 100),
                      Column(
                        children: [
                          StyleButton(
                            onPressed: editar, // Chama o método de edição
                            text: 'Confirmar Edição',
                            type: ButtonType.primary,
                          ),
                        ],
                      ),
                      SizedBox(height: 23),
                      StyleButton(
                        onPressed: cadstrar, // Chama o método de cadastro
                        text: 'Cadastrar',
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
              color: StyleTable.containerColor,
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
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => deletar(index),
                            icon: Icon(
                              Icons.delete_sharp,
                              color: const Color.fromARGB(163, 255, 255, 255),
                            ),
                          ),
                          IconButton(
                            onPressed: () => inputEdicao(cadastro),
                            icon: Icon(
                              Icons.edit,
                              color: const Color.fromARGB(163, 255, 255, 255),
                            ),
                          ),
                        ],
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