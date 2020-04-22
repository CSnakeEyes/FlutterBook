import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'PhotosEntry.dart';
import 'PhotosModel.dart' show PhotosModel, photosModel;
import 'PhotosList.dart';

class Photos extends StatelessWidget {
  Photos() {
    photosModel.getAlbumImgs();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<PhotosModel>(
        model: photosModel,
        child: ScopedModelDescendant<PhotosModel>(
            builder: (BuildContext context, Widget child, PhotosModel model) {
          return IndexedStack(
            index: model.stackIndex,
            children: <Widget>[
              PhotosList(),
              PhotosEntry(),
            ],
          );
        }));
  }
}
