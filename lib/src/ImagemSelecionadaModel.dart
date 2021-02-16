import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:async';

class ImagemSelecionada {
  String path;
  String imgB64;

  ImagemSelecionada({this.path, this.imgB64});

  ImagemSelecionada.fromJson(Map<String, dynamic> json) {
    path = json['path'];
    imgB64 = json['imgB64'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['path'] = this.path;
    data['imgB64'] = this.imgB64;
    return data;
  }

  /*Cria o objeto da imagem selecionada*/
  Future<ImagemSelecionada> imagemSelecionada(String path) async {
    Uint8List bytes = await new File(path).readAsBytes();
    String imgBase64 = base64.encode(bytes);
    return ImagemSelecionada(path: path, imgB64: imgBase64);
  }
}
