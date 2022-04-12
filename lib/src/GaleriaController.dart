import 'package:flutter/material.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'ImagemSelecionadaModel.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:video_player/video_player.dart';

class Galeria extends StatefulWidget {
  Color colorPrimaria;
  Color colorSecundaria;

  Galeria({this.colorPrimaria, this.colorSecundaria});

  @override
  _GaleriaState createState() => _GaleriaState();
}

class _GaleriaState extends State<Galeria> {
  List<Album> _albums;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loading = true;
    initAsync();
  }

  Future<void> initAsync() async {
    if (await _promptPermissionSetting()) {
      List<Album> albums =
          await PhotoGallery.listAlbums(mediumType: MediumType.image);
      setState(() {
        _albums = albums;
        _loading = false;
      });
    } else {
      return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                titlePadding: EdgeInsets.all(3),
                backgroundColor: widget.colorSecundaria == null
                    ? Colors.grey
                    : widget.colorSecundaria,
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
                          'Você não permitiu o acesso a pasta de imagens do seu dispositivo',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        SizedBox(
                          height: 8,
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
                                      Text('canclar',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                                onTap: () async {
                                  Navigator.canPop(context)
                                      ? Navigator.pop(context)
                                      : print('');
                                  Navigator.canPop(context)
                                      ? Navigator.pop(context)
                                      : print('');
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
                                        'tentar novamente',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () async {
                                  Navigator.canPop(context)
                                      ? Navigator.pop(context)
                                      : print('');
                                  initAsync();
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
    setState(() {
      _loading = false;
    });
  }

  Future<bool> _promptPermissionSetting() async {
    if (Platform.isIOS &&
            await Permission.storage.request().isGranted &&
            await Permission.photos.request().isGranted ||
        Platform.isAndroid && await Permission.storage.request().isGranted) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: widget.colorPrimaria == null
              ? Colors.black
              : widget.colorPrimaria,
          title: const Text('Imagens'),
        ),
        body: _loading
            ? Center(
                child: CircularProgressIndicator(
                  backgroundColor: widget.colorPrimaria == null
                      ? Colors.black
                      : widget.colorPrimaria,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      widget.colorSecundaria == null
                          ? Colors.white
                          : widget.colorSecundaria),
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  double gridWidth = (constraints.maxWidth - 20) / 3;
                  double gridHeight = gridWidth + 33;
                  double ratio = gridWidth / gridHeight;
                  return Container(
                    padding: EdgeInsets.all(5),
                    child: GridView.count(
                      childAspectRatio: ratio,
                      crossAxisCount: 3,
                      mainAxisSpacing: 5.0,
                      crossAxisSpacing: 5.0,
                      children: <Widget>[
                        ...?_albums?.map(
                          (album) => GestureDetector(
                            onTap: () async {
                              print('Aessando outra page');
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AlbumPage(album,
                                          color: widget.colorPrimaria)));
                            },
                            child: Column(
                              children: <Widget>[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(5.0),
                                  child: Container(
                                    color: Colors.grey[300],
                                    height: gridWidth,
                                    width: gridWidth,
                                    child: FadeInImage(
                                      fit: BoxFit.cover,
                                      placeholder:
                                          MemoryImage(kTransparentImage),
                                      image: AlbumThumbnailProvider(
                                        albumId: album.id,
                                        mediumType: album.mediumType,
                                        highQuality: true,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.topLeft,
                                  padding: EdgeInsets.only(left: 2.0),
                                  child: Text(
                                    album.name,
                                    maxLines: 1,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      height: 1.2,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.topLeft,
                                  padding: EdgeInsets.only(left: 2.0),
                                  child: Text(
                                    album.count.toString(),
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      height: 1.2,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class AlbumPage extends StatefulWidget {
  Color color;
  final Album album;

  AlbumPage(Album album, {this.color}) : album = album;

  @override
  State<StatefulWidget> createState() => AlbumPageState();
}

class AlbumPageState extends State<AlbumPage> {
  List<Medium> _media;

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  void initAsync() async {
    MediaPage mediaPage = await widget.album.listMedia();
    setState(() {
      _media = mediaPage.items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: widget.color == null ? Colors.black : widget.color,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(widget.album.name),
        ),
        body: GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 1.0,
          crossAxisSpacing: 1.0,
          children: <Widget>[
            ...?_media?.map(
              (medium) => GestureDetector(
                onTap: () async {
                  File fileGaleriaed = await medium.getFile();
                  print(fileGaleriaed.path);
                  print('aaaa');
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ViewerPage(
                                medium,
                                color: widget.color,
                              )));
                },
                child: Container(
                  color: Colors.grey[300],
                  child: FadeInImage(
                    fit: BoxFit.cover,
                    placeholder: MemoryImage(kTransparentImage),
                    image: ThumbnailProvider(
                      mediumId: medium.id,
                      mediumType: medium.mediumType,
                      highQuality: true,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ViewerPage extends StatelessWidget {
  final Medium medium;
  Color color;

  ViewerPage(Medium medium, {this.color}) : medium = medium;

  @override
  Widget build(BuildContext context) {
    DateTime date = medium.creationDate ?? medium.modifiedDate;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: color == null ? Colors.black : color,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back_ios),
          ),
          title: Text(date?.toLocal().toString()),
        ),
        body: Container(
          alignment: Alignment.center,
          child: medium.mediumType == MediumType.image
              ? Stack(
                  children: [
                    FadeInImage(
                      fit: BoxFit.cover,
                      placeholder: MemoryImage(kTransparentImage),
                      image: PhotoProvider(mediumId: medium.id),
                    ),
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          color: Colors.black54,
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.all(10),
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
                                      Text('voltar',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 22)),
                                    ],
                                  ),
                                ),
                                onTap: () async {
                                  Navigator.pop(context);
                                },
                              ),
                              SizedBox(
                                width: 6,
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
                                        'selecionar',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () async {
                                  File file = await medium.getFile();
                                  ImagemSelecionada imagemSelecionada =
                                      await ImagemSelecionada()
                                          .imagemSelecionada(file.path);
                                  Navigator.canPop(context)
                                      ? Navigator.pop(context)
                                      : print('');
                                  Navigator.canPop(context)
                                      ? Navigator.pop(context)
                                      : print('');
                                  Navigator.canPop(context)
                                      ? Navigator.pop(
                                          context, imagemSelecionada)
                                      : print('');
                                },
                              ),
                            ],
                          ),
                        ))
                  ],
                )
              : VideoProvider(
                  mediumId: medium.id,
                ),
        ),
      ),
    );
  }
}

class VideoProvider extends StatefulWidget {
  final String mediumId;

  const VideoProvider({
    @required this.mediumId,
  });

  @override
  _VideoProviderState createState() => _VideoProviderState();
}

class _VideoProviderState extends State<VideoProvider> {
  VideoPlayerController _controller;
  File _file;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initAsync();
    });
    super.initState();
  }

  Future<void> initAsync() async {
    try {
      _file = await PhotoGallery.getFile(mediumId: widget.mediumId);
      _controller = VideoPlayerController.file(_file);
      _controller.initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
    } catch (e) {
      print("Failed : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return _controller == null || !_controller.value.isInitialized
        ? Container()
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
              FlatButton(
                onPressed: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
                child: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                ),
              ),
            ],
          );
  }
}
