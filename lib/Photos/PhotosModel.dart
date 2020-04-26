import 'dart:io';
import 'dart:typed_data';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:photo_manager/photo_manager.dart';

import "./../BaseModel.dart";

PhotosModel photosModel = PhotosModel();

class PhotosModel extends BaseModel<Uint8List> {
  String path;
  File pictureFile;
  String selected = 'Local Storage';

  void getAlbumImgs({path}) async {
    if (path != null) {
      await ImageGallerySaver.saveFile(path);
    }
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
