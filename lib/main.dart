import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/src/services/system_chrome.dart';
import 'package:seletor_captura_imagens/src/CameraController.dart';
import 'package:seletor_captura_imagens/src/ImagemSelecionadaModel.dart';
import 'package:seletor_captura_imagens/src/GaleriaController.dart';

void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ImagemSelecionada imagemSelecionada;

  @override
  void initState() {
    // TODO: implement initState
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Exemplo - Modulo Seleção de imagens'),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.all(15),
                child: Text(
                  'Add foto',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              onTap: () async {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(6))),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            InkWell(
                              onTap: () async {
                                Navigator.pop(context);
                                ImagemSelecionada imagemSelecionada =
                                    await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Galeria(
                                                  colorPrimaria:
                                                      Color(0xff00172F),
                                                  colorSecundaria:
                                                      Color(0xffC7A040),
                                                )));
                                print('to na main');
                                if (imagemSelecionada == null) {
                                  print('SEM PERMISSÃO DE ACESSO A CAMERA');
                                } else {
                                  print(imagemSelecionada.path);
                                  print(imagemSelecionada.imgB64);
                                  setState(() {
                                    this.imagemSelecionada = imagemSelecionada;
                                  });
                                }
                              },
                              child: Container(
                                child: ListTile(
                                    title: Text("Gallery"),
                                    leading: Icon(
                                      Icons.image,
                                      color: Colors.black,
                                    )),
                              ),
                            ),
                            Container(
                              width: 200,
                              height: 1,
                              color: Colors.black12,
                            ),
                            InkWell(
                              onTap: () async {
                                Navigator.pop(context);
                                //O navigator irá retornar um objeto IagemSelecionda que conterá o path e a imagem em base64
                                ImagemSelecionada imagemSelecionada =
                                    await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Camera(
                                                  colorPrimaria:
                                                      Color(0xff00172F),
                                                  colorSecundaria:
                                                      Color(0xffC7A040),
                                                )));
                                print('to na main');

                                if (imagemSelecionada == null) {
                                  print('SEM PERMISSÃO DE ACESSO A CAMERA');
                                } else {
                                  if (imagemSelecionada.imgB64 == null ||
                                      imagemSelecionada.path == null) {
                                    print('saindo sem tirar foto');
                                  } else {
                                    setState(() {
                                      this.imagemSelecionada =
                                          imagemSelecionada;
                                    });
                                    print(imagemSelecionada.path.toString());
                                    print(imagemSelecionada.imgB64.toString());
                                  }
                                }
                              },
                              child: Container(
                                child: ListTile(
                                    title: Text("Camera"),
                                    leading: Icon(
                                      Icons.camera,
                                      color: Colors.black,
                                    )),
                              ),
                            ),
                          ],
                        ),
                      );
                    });
              },
            ),
            imagemSelecionada == null
                ? Text('Nenhuma imagem selecionada')
                : Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * .75,
                    child: Image(
                      fit: BoxFit.scaleDown,
                      image: Image.file(File(imagemSelecionada.path)).image,
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
