import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:camera/camera.dart';
import 'package:flutterbook/Photos/PhotosModel.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:scoped_model/scoped_model.dart';

class PhotosList extends StatefulWidget {
  @override
  _PhotosListState createState() => _PhotosListState();
}

class _PhotosListState extends State<PhotosList> {
  bool isInitialized = false;
  CameraController cameraController;
  List<AssetPathEntity> listOfPaths;

  @override
  void initState() {
    super.initState();
    availableCameras().then((List<CameraDescription> value) {
      cameraController = CameraController(value[0], ResolutionPreset.medium);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<PhotosModel>(
        builder: (BuildContext context, Widget child, PhotosModel model) {
      return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon((isInitialized) ? Icons.camera_alt : Icons.add,
              color: Colors.white),
          onPressed: () async {
            if (!isInitialized) {
              cameraController.initialize().then((_) {
                if (!mounted) {
                  return;
                }
                setState(() => isInitialized = true);
              });
            } else {
              var path = join(
                (await getApplicationDocumentsDirectory()).path,
                '${DateTime.now()}.png',
              );
              await cameraController.takePicture(path);
              setState(() => isInitialized = false);
              model.path = path;
              model.entityBeingEdited = File(path).readAsBytesSync();
              model.setStackIndex(1);
            }
          },
        ),
        body: (isInitialized)
            ? AspectRatio(
                aspectRatio: cameraController.value.aspectRatio,
                child: CameraPreview(cameraController),
              )
            : GridView.count(
                primary: false,
                padding: EdgeInsets.all(10.0),
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                shrinkWrap: true,
                children: _buildGrid(model.entityList),
              ),
      );
    });
  }

  List<Widget> _buildGrid(List<Uint8List> imgs) {
    return imgs.map((img) => _buildCardItem(img)).toList();
  }

  Widget _buildCardItem(Uint8List img) {
    return GestureDetector(
      onTap: () {},
      child: Card(
        elevation: 8.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Image.memory(img),
      ),
    );
  }

  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }
}
