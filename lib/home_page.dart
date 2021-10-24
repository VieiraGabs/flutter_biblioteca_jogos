// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:jogos/inclusao_route.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? jogoFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de Jogos'),
        actions: [
          IconButton(
            onPressed: () {
              _showFilter(context);
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                jogoFilter = null;
              });
            },
            icon: const Icon(Icons.list),
          ),
        ],
      ),
      body: _body(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => InclusaoRoute()),
          );
        },
        tooltip: 'Adicionar Jogo',
        child: Icon(Icons.add),
      ),
    );
  }

  CollectionReference cfJogos = FirebaseFirestore.instance.collection("jogos");

  Column _body(context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            //        stream: cfJogos.orderBy("nome").snapshots(),
            stream: cfJogos.where("genero", isEqualTo: jogoFilter).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = snapshot.requireData;

              return data.size > 0
                  ? ListView.builder(
                      itemCount: data.size,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                              data.docs[index].get("foto"),
                            ),
                          ),
                          title: Text(data.docs[index].get("nome")),
                          subtitle: Text(
                            data.docs[index].get("genero"),
                          ),
                          onLongPress: () {
                            _excluirJogo(context, data.docs[index].id,
                                data.docs[index].get("nome"));
                          },
                        );
                      },
                    )
                  : Center(
                      child: Text("Não há jogos com o nome informado"),
                    );
            },
          ),
        ),
      ],
    );
  }

  _excluirJogo(context, id, nome) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Exclusão de Jogo'),
          content: Text("Confirma exclusão do jogo $nome ?"),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                cfJogos.doc(id).delete();
                Navigator.of(context).pop();
              },
              child: Text('Sim'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Não'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showFilter(BuildContext context) async {
    String? valueText;

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Informe o jogo para filtrar'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  valueText = value;
                });
              },
              decoration: InputDecoration(hintText: "Jogo"),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: Text('Cancelar'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              ElevatedButton(
                child: Text('Ok'),
                onPressed: () {
                  setState(() {
                    jogoFilter = valueText;
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }
}
