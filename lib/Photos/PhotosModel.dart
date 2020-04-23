import 'dart:io';
import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';

import "./../BaseModel.dart";

PhotosModel photosModel = PhotosModel();

class PhotosModel extends BaseModel<Uint8List> {
  String path;
  File pictureFile;

  void getAlbumImgs() async {
    entityList.clear();
    List<AssetPathEntity> albums = await PhotoManager.getAssetPathList();
    for (AssetPathEntity album in albums) {
      if (album.name == 'flutterbook') {
        List<AssetEntity> imgs = await album.getAssetListPaged(0, 10);
        for (AssetEntity img in imgs) {
          entityList.add(await img.originBytes);
        }
      }
    }
    notifyListeners();
  }
}
