import 'package:flutter/material.dart';
import 'package:flutterbook/Photos/PhotosModel.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PhotosEntry extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<PhotosModel>(
      builder: (BuildContext context, Widget child, PhotosModel model) {
        return Scaffold(
            body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Container(
                width: 300.0,
                child: Image.memory(model.entityBeingEdited),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  MaterialButton(
                    padding: EdgeInsets.all(10.0),
                    color: Colors.red[700],
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      model.entityBeingEdited = null;
                      model.setStackIndex(0);
                    },
                  ),
                  MaterialButton(
                    padding: EdgeInsets.all(10.0),
                    color: Colors.amber[600],
                    child: Text(
                      "Send to Cloud",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      StorageReference storageReference = FirebaseStorage.instance.ref().child('bitch');
                      StorageUploadTask uploadTask = storageReference.putFile(model.pictureFile);
                      await uploadTask.onComplete;
                      print('Picture uploaded!');
                    },
                  ),
                  MaterialButton(
                    padding: EdgeInsets.all(10.0),
                    color: Colors.blue,
                    child: Text(
                      "Save Locally",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      await ImageGallerySaver.saveFile(model.path);
                      model.getAlbumImgs();
                      model.setStackIndex(0);
                    },
                  ),
                ],
              ),
            ),
          ],
        ));
      },
    );
  }
}
