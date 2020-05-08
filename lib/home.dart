import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController _tarefa = TextEditingController();
  List _listaTarefas = [];
  Map<String, dynamic> _itemRemovido = Map();

  Future<File> _getArquivo() async {
    final diretorio = await getApplicationDocumentsDirectory();

    return File('${diretorio.path}/dados.json');
  }

  _salvarArquivo() async {
    var arquivo = await _getArquivo();

    var dados = json.encode(_listaTarefas);
    try {
      arquivo.writeAsString(dados);
    } catch (e) {
      print('Erro: ' + e.toString());
    }
  }

  _lerArquivo() async {
    try {
      final arquivo = await _getArquivo();
      return arquivo.readAsString();
    } catch (e) {
      print('Erro: ${e.toString()}');
      return null;
    }
  }

  _salvarTarefa() {
    String texto = _tarefa.text;
    Map<String, dynamic> tarefa = Map();

    tarefa['titulo'] = texto;
    tarefa['realizada'] = false;
    setState(() {
      _listaTarefas.add(tarefa);
    });
    _salvarArquivo();
    _tarefa.text = '';
  }

  @override
  void initState() {
    super.initState();
    _lerArquivo().then((dados) {
      setState(() {
        for (var item in json.decode(dados)) {
          _listaTarefas.add(item);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text(
            'Lista de tarefas',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: _listaTarefas.length,
                itemBuilder: (context, indice) {
                  String item = _listaTarefas[indice]['titulo'];
                  return Dismissible(
                    key: Key(DateTime.now().millisecond.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Icon(Icons.delete),
                        ],
                      ),
                    ),
                    onDismissed: (direcao) {
                      _itemRemovido = _listaTarefas[indice];
                      _listaTarefas.removeAt(indice);
                      _salvarArquivo();
                      final SnackBar snackBar = SnackBar(
                        duration: Duration(seconds: 10),
                        content: Text('Tarefa removida!!!'),
                        action: SnackBarAction(
                            label: 'Desfazer',
                            onPressed: () {
                              setState(() {
                                _listaTarefas.insert(indice, _itemRemovido);
                              });
                              _salvarArquivo();
                            }),
                      );
                      Scaffold.of(context).showSnackBar(snackBar);
                    },
                    child: CheckboxListTile(
                      title: Text(item),
                      value: _listaTarefas[indice]['realizada'],
                      onChanged: (flag) {
                        setState(() {
                          _listaTarefas[indice]['realizada'] = flag;
                          _salvarArquivo();
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Adicionar tarefa'),
                    content: TextField(
                      onChanged: (texto) {},
                      keyboardType: TextInputType.text,
                      controller: _tarefa,
                      decoration: InputDecoration(
                        labelText: 'Digite a tarefa',
                      ),
                    ),
                    actions: <Widget>[
                      FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Cancelar'),
                      ),
                      FlatButton(
                        onPressed: () {
                          _salvarTarefa();
                          Navigator.pop(context);
                        },
                        child: Text('Salvar'),
                      )
                    ],
                  );
                });
          },
          child: Icon(Icons.add),
          elevation: 6,
          backgroundColor: Colors.brown,
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.grey,
          shape: CircularNotchedRectangle(),
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.menu),
                onPressed: null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
