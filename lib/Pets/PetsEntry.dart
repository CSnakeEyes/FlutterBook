import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterbook/Pets/PetsModel.dart';
import 'package:flutterbook/Pets/PetsDBWorker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scoped_model/scoped_model.dart';

import '../utils.dart';

class PetsEntry extends StatefulWidget {
  @override
  _PetsEntryState createState() => _PetsEntryState();
}

class _PetsEntryState extends State<PetsEntry> {
  String _retrieveDataError;
  dynamic _pickImageError;
  File imageFile;

  TextEditingController _nameController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  _PetsEntryState() {
    _nameController.addListener(() {
      petsModel.entityBeingEdited.name = _nameController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<PetsModel>(
      model: petsModel,
      child: ScopedModelDescendant<PetsModel>(
        builder: (BuildContext context, Widget child, PetsModel model) {
          if (model.entityBeingEdited != null) {
            _nameController.text = model.entityBeingEdited.name;
          }

          return Scaffold(
            bottomNavigationBar: Padding(
              padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
              child: Row(
                children: <Widget>[
                  FlatButton(
                    child: Text("Cancel"),
                    onPressed: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      model.setStackIndex(0);
                    },
                  ),
                  Spacer(),
                  FlatButton(
                    child: Text("Save in Cloud"),
                    onPressed: () => _saveInCloud(model),
                  ),
                  Spacer(),
                  FlatButton(
                    child: Text("Save Locally"),
                    onPressed: () => _saveLocal(context, model),
                  ),
                ],
              ),
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  Platform.isAndroid
                      ? FutureBuilder<void>(
                          future: retrieveLostData(),
                          builder: (BuildContext context,
                              AsyncSnapshot<void> snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.none:
                              case ConnectionState.waiting:
                                return Text(
                                  'You have not yet picked an image.',
                                  textAlign: TextAlign.center,
                                );
                              case ConnectionState.done:
                                return _previewImage();
                              default:
                                if (snapshot.hasError) {
                                  return Text(
                                    'Pick image/video error: ${snapshot.error}}',
                                    textAlign: TextAlign.center,
                                  );
                                }
                                return const Text(
                                  'You have not yet picked an image.',
                                  textAlign: TextAlign.center,
                                );
                            }
                          },
                        )
                      : SizedBox(),
                  MaterialButton(
                    child: Text("Change image"),
                    onPressed: () => _selectImage(context),
                  ),
                  ListTile(
                    leading: Icon(Icons.pets),
                    title: TextFormField(
                      decoration: InputDecoration(hintText: 'Name'),
                      controller: _nameController,
                      validator: (String value) {
                        return (value.length == 0
                            ? 'Please enter a name'
                            : null);
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.today),
                    title: Text('Birthday'),
                    subtitle: Text(petsModel.entityBeingEdited.birthday == null
                        ? ""
                        : toFormattedDate(
                            petsModel.entityBeingEdited.birthday)),
                    trailing: IconButton(
                        icon: Icon(Icons.edit),
                        color: Colors.red,
                        onPressed: () async {
                          try {
                            String chosenDate = await selectDate(
                              context,
                              petsModel,
                              petsModel.entityBeingEdited.birthday,
                            );
                            if (chosenDate != null) {
                              petsModel.setBirthday(chosenDate);
                            }
                          } catch (e) {
                            print(e);
                          }
                        }),
                  ),
                  ListTile(
                    leading: Icon(Icons.today),
                    title: Text('Last day visited'),
                    subtitle: Text(
                        petsModel.entityBeingEdited.latestVisit == null
                            ? ""
                            : toFormattedDate(
                                petsModel.entityBeingEdited.latestVisit)),
                    trailing: IconButton(
                        icon: Icon(Icons.edit),
                        color: Colors.red,
                        onPressed: () async {
                          try {
                            String chosenDate = await selectDate(
                              context,
                              petsModel,
                              petsModel.entityBeingEdited.latestVisit,
                            );
                            if (chosenDate != null) {
                              petsModel.setLatestVisit(chosenDate);
                            }
                          } catch (e) {
                            print(e);
                          }
                        }),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Text _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  Widget _previewImage() {
    final Text retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (imageFile != null) {
      return Image.file(imageFile);
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return const Text(
        'You have not yet picked an image.',
        textAlign: TextAlign.center,
      );
    }
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await ImagePicker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        imageFile = response.file;
      });
    } else {
      _retrieveDataError = response.exception.code;
    }
  }

  void _saveLocal(BuildContext context, PetsModel model) async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    model.setPath(imageFile.path);
    if (model.entityBeingEdited.id != null) {
      await PetsDBWorker.db.update(model.entityBeingEdited);
    } else {
      await PetsDBWorker.db.create(model.entityBeingEdited);
    }
    model.loadData(PetsDBWorker.db);
    model.setStackIndex(0);
  }

  void _saveInCloud(PetsModel model) async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    try {
      await Firestore.instance
          .collection('pets')
          .document(model.entityBeingEdited.name)
          .setData({
        'id': model.entityBeingEdited.name,
        'name': model.entityBeingEdited.name,
        'path': imageFile.path,
        'birthday': model.entityBeingEdited.birthday,
        'latestVisit': model.entityBeingEdited.latestVisit,
      });
      model.loadData(PetsDBWorker.db);
      model.setStackIndex(0);
    } catch (e) {
      print(e);
    }
  }

  Future _selectImage(BuildContext context) async {
    File galleryImage = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      imageFile = galleryImage;
    });
  }
}
