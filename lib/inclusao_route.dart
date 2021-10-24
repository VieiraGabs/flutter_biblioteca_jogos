// ignore_for_file: prefer_const_constructors, prefer_final_fields, unused_field, unrelated_type_equality_checks, unused_element, avoid_print

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class InclusaoRoute extends StatefulWidget {
  const InclusaoRoute({Key? key}) : super(key: key);

  @override
  _InclusaoRouteState createState() => _InclusaoRouteState();
}

class _InclusaoRouteState extends State<InclusaoRoute> {
  var _edNome = TextEditingController();
  var _edGenero = TextEditingController();
  var _edNota = TextEditingController();
  var _edFoto = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inclusão de Jogos'),
      ),
      body: _body(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(
            context,
          );
        },
        tooltip: 'Voltar',
        child: const Icon(Icons.arrow_back),
      ),
    );
  }

  Container _body() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _edNome,
            keyboardType: TextInputType.name,
            style: TextStyle(
              fontSize: 20,
            ),
            decoration: InputDecoration(
              labelText: "Nome",
            ),
          ),
          TextFormField(
            controller: _edGenero,
            keyboardType: TextInputType.name,
            style: TextStyle(
              fontSize: 20,
            ),
            decoration: InputDecoration(
              labelText: "Gênero",
            ),
          ),
          TextFormField(
            controller: _edNota,
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: 20,
            ),
            decoration: InputDecoration(
              labelText: "Nota",
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: _getImage,
                icon: Icon(Icons.photo_camera),
                color: Colors.blue,
              ),
              Expanded(
                child: TextFormField(
                  controller: _edFoto,
                  keyboardType: TextInputType.url,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                  decoration: InputDecoration(
                    labelText: "URL da Foto",
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: _imageFile == null
                ? Text("Clique no botão da câmera para fotografar")
                : Image.file(
                    File(_imageFile!.path),
                    fit: BoxFit.cover,
                  ),
          ),
          Row(
            children: [
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton(
                  onPressed: uploadFile,
                  child: Text("Salvar Imagem",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      )),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blueGrey.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton(
                  onPressed: _gravaDados,
                  child: Text(
                    "Cadastrar",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _getImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      setState(() {
        _imageFile = pickedFile;
      });
    } catch (e) {
      print("Erro no acesso à camera");
    }
  }

  Future<firebase_storage.UploadTask?> uploadFile() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Fotografe a imagem a ser salva'),
      ));
      return null;
    }

    firebase_storage.UploadTask uploadTask;

    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child(DateTime.now().millisecondsSinceEpoch.toString() + ".jpg");

    final metadata = firebase_storage.SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': _imageFile!.path});

    uploadTask = ref.putFile(File(_imageFile!.path), metadata);

    var imageURL = await (await uploadTask).ref.getDownloadURL();
    _edFoto.text = imageURL.toString();

    return Future.value(uploadTask);
  }

  Future<void> _gravaDados() async {
    if (_edNome.text == "" ||
        _edGenero.text == "" ||
        _edFoto.text == "" ||
        _edNota == "") {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Atenção'),
            content: Text('Por favor, preencha todos os campos'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Ok'),
              ),
            ],
          );
        },
      );
      return;
    }

    CollectionReference cfJogos =
        FirebaseFirestore.instance.collection("jogos");

    await cfJogos.add({
      "nome": _edNome.text,
      "genero": _edGenero.text,
      "nota": double.parse(_edNota.text),
      "foto": _edFoto.text,
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Cadastro realizado com sucesso'),
          content: Text("${_edNome.text} inserido na base de dados de jogos"),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Ok'),
            ),
          ],
        );
      },
    );

    _edNome.text = "";
    _edGenero.text = "";
    _edNota.text = "";
    _edFoto.text = "";
  }
}
