import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'dart:io';
import 'dart:convert' show utf8;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';
import 'dart:convert';
import 'dart:async';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:seletor_captura_imagens/src/ImagemSelecionadaModel.dart';

class Camera extends StatefulWidget {
  Color colorPrimaria;
  Color colorSecundaria;

  Camera({this.colorPrimaria, this.colorSecundaria});

  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> with WidgetsBindingObserver {
  CameraController
      controller; //Classe responsável para estabelecer conexão com a câmera do dispositivo
  List cameras; //Lista de câmeras (geralmente são duas, traseira e frontal)
  int selectedCameraIdx; //Responsável por armazenar o índice de qual câmera o usuário escolheu (0 cam traseira, 1 cam frontal)
  String imagePath; //Salavará o caminho da foto tirada
  String nomeArquivo, diretorioArquivo = '';

  /*Função responsável por iniciar a câmera do dispositivo*/
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    availableCameras().then((availableCameras) {
      cameras =
          availableCameras; //Faz parte do câmera plugins, e retorna a lista de câmeras disponíveis no dispositivo
      if (cameras.length > 0) {
        setState(() {
          selectedCameraIdx = 0; //Seleciono a camera 1(frontal)
        });

        _initCameraController(cameras[selectedCameraIdx]).then((void v) {});
      } else {
        print("Sem câmeras disponíveis");
      }
    }).catchError((erro) {
      print('Erro ao iniciar câmeras' + erro);
    });
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    //print('state = $state');
    try {
      if (state == AppLifecycleState.resumed) {
        if (controller != null) {
          var status = await Permission.camera.status;
          if (status.isUndetermined) {
            // We didn't ask for permission yet.
          }
          print('permissão da camera');
          print(status.toString());

          if (status.isGranted) {
            controller.initialize();
          } else if (status.isUndetermined) {
            Permission.camera.request();
          } else if (status.isDenied) {
            //permissão de câmera negada
            await Permission.camera.request();
          } else if (status.isPermanentlyDenied || status.isRestricted) {
            //permissão de câmera negada permanentemente
            Navigator.pop(context, null);
          }
        } else {
          return null; //on pause camera disposed so we need call again "issue is only for android"
        }
      }
    } catch (error) {
      print(error.toString());
    }
  }

  Future _initCameraController(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }

    controller = CameraController(
        cameraDescription,
        ResolutionPreset
            .high); //Resolution preset é a qualidade da imagem capturada (low, medium e high)

    /*Será chamado quando se alterar entre 
      câmera frontal e traseira*/
    controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (controller.value.hasError) {
        print('Erro ao trocar de câmera ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } catch (erro) {
      print('Erro ao iniciar câmera ' + erro.toString());
    }

    if (mounted) {
      setState(() {});
    }
  }

  /*Isso retornará um CameraPreview widget se o objeto do controlador for
    inicializado com êxito, ou um Text widget com o rótulo 'Carregando'.
    O CameraPreview widget retornará uma visão da câmera.*/
  Widget _cameraPreview() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        '',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.w900,
        ),
      );
    }

    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: CameraPreview(controller),
    );
  }

  void _tirarfoto(context) async {
    try {
      //Directory tempDir = await getTemporaryDirectory();

      Directory tempDir = Directory.systemTemp;
      String tempPath = tempDir.path;

      print('temporária: ');
      print(tempDir);

      nomeArquivo = DateTime.now().microsecondsSinceEpoch.toString() + '.png';
      diretorioArquivo =
          tempPath + '/' + nomeArquivo; //tempPath substitui appDiretorio

      print('DIRETÓRIO: ' + diretorioArquivo);
      print('ARQUIVO: ' + nomeArquivo);

      await controller.takePicture(diretorioArquivo);
      bool fotoEspelhada = await desespelharImagem(tempPath);
      if (fotoEspelhada) {
        verFoto(context,
            await ImagemSelecionada().imagemSelecionada(diretorioArquivo));
      } else {
        //print('espelahdo false');
      }
    } catch (erro) {
      print('Erro ao tira foto: ' + erro.toString());
    }
  }

  Future<bool> desespelharImagem(String tempPath) async {
    try {
      if (cameras[selectedCameraIdx].lensDirection ==
          CameraLensDirection.front) {
        FlutterFFmpeg _ffmpeg = new FlutterFFmpeg();

        await _ffmpeg.execute(
            "-y -i $diretorioArquivo -filter:v \"hflip\" $tempPath'/1'$nomeArquivo");
        diretorioArquivo = tempPath + '/1' + nomeArquivo;
        return true;
      } else {
        return true;
      }
    } catch (error) {
      print(error.toString());
      return false;
    }
  }

  /*Função que retorna um alert dialog exibindo
    para o usuário a foto de perfil do mesmo*/
  verFoto(context, ImagemSelecionada file) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            titlePadding: EdgeInsets.all(3),
            backgroundColor: Colors.black54,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.black12),
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  children: [
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image(
                            image: Image.file(File(file.path)).image,
                            fit: BoxFit.scaleDown,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xffE74C3C)),
                  padding: EdgeInsets.all(6),
                  child: Row(
                    children: [
                      Text('Tirar novamente',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                },
              ),
              GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xff449200)),
                  padding: EdgeInsets.all(6),
                  child: Row(
                    children: [
                      Text(
                        'Selecionar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                onTap: () async {
                  Navigator.canPop(context)
                      ? Navigator.pop(context)
                      : print('');
                  Navigator.canPop(context)
                      ? Navigator.pop(context, file)
                      : print('');
                },
              ),
            ],
          );
        });
  }

  Widget _cameraTogglesRowWidget() {
    if (cameras == null || cameras.isEmpty) {
      return Spacer();
    }

    CameraDescription selectedCamera = cameras[selectedCameraIdx];
    CameraLensDirection lensDirection = selectedCamera.lensDirection;

    return ClipOval(
      child: Material(
        color: Colors.white, // button color
        child: InkWell(
          splashColor: Color(0xffC7A040), // inkwell color
          child: SizedBox(
              width: 50,
              height: 50,
              child:
                  Icon(_getCameraLensIcon(lensDirection), color: Colors.black)),
          onTap: () {
            _onSwitchCamera();
          },
        ),
      ),
    );
  }

  void _onSwitchCamera() {
    selectedCameraIdx =
        selectedCameraIdx < cameras.length - 1 ? selectedCameraIdx + 1 : 0;
    CameraDescription selectedCamera = cameras[selectedCameraIdx];
    _initCameraController(selectedCamera);
  }

  IconData _getCameraLensIcon(CameraLensDirection direction) {
    switch (direction) {
      case CameraLensDirection.back:
        return Icons.camera_rear;
      case CameraLensDirection.front:
        return Icons.camera_front;
      case CameraLensDirection.external:
        return Icons.camera;
      default:
        return Icons.device_unknown;
    }
  }

  //Tela do APP
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => sair(context, widget.colorSecundaria),
      child: Container(
        color:
            widget.colorPrimaria == null ? Colors.black : widget.colorPrimaria,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Color(0xff585757),
            body: Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                    widget.colorPrimaria == null
                        ? Colors.black
                        : widget.colorPrimaria,
                    widget.colorSecundaria == null
                        ? Colors.grey
                        : widget.colorSecundaria,
                  ])),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      color: Colors.black,
                      child: _cameraPreview(),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipOval(
                            child: Material(
                              color: Colors.white, // button color
                              child: InkWell(
                                splashColor: Color(0xffC7A040), // inkwell color
                                child: SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: Icon(Icons.camera)),
                                onTap: () {
                                  _tirarfoto(context);
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [_cameraTogglesRowWidget()],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> sair(BuildContext context, Color colors) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              titlePadding: EdgeInsets.all(3),
              backgroundColor: colors == null ? Colors.white : colors,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(15)),
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Text(
                        'Atenção',
                        style: TextStyle(color: Colors.white, fontSize: 22),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Tem certeza que deseja sair sem tirar uma foto?',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Color(0xffE74C3C)),
                                padding: EdgeInsets.all(6),
                                child: Row(
                                  children: [
                                    Text('cancelar',
                                        style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                              ),
                              onTap: () async {
                                Navigator.pop(context);
                              },
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            GestureDetector(
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Color(0xff449200)),
                                padding: EdgeInsets.all(6),
                                child: Row(
                                  children: [
                                    Text(
                                      'sim',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () async {
                                Navigator.canPop(context)
                                    ? Navigator.pop(context)
                                    : print('');
                                Navigator.canPop(context)
                                    ? Navigator.pop(
                                        context,
                                        ImagemSelecionada(
                                            path: null, imgB64: null))
                                    : print('');
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  )),
            ),
          );
        });
  }
}
