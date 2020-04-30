import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterbook/Pets/PetsModel.dart';
import 'package:flutterbook/Pets/PetsDBWorker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scoped_model/scoped_model.dart';

import '../utils.dart';

///Class to modify or create a new pet item
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
    ///Set listener controller for name input
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

                    ///When the user press it, it will return to [PetsList]
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

                      ///When the input is pressed the user will be able to type and
                      ///update the value of [name]
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

                        ///When the button is pressed the ui will show a date picker
                        ///and allow the user to update [birthay]
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

                        ///When the button is pressed the ui will show a date picker
                        ///and allow the user to update [latestVisit]
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

  ///This method will show an error if there was a problem
  ///selecting an image from the fallery
  Text _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  ///This method allows the user to preview the selected image in the gallery
  Widget _previewImage() {
    ///Check if there was an erryr
    final Text retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }

    ///Check if a file was selected
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

  ///This method helps to retrieve the lost data when
  ///the app redirects the user to the gallery, this the app is destroyed at that moment
  ///(just android devices)
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

  ///This method saves a pet model in the local database
  void _saveLocal(BuildContext context, PetsModel model) async {
    ///If any field is empty, don't proceed
    if (!_formKey.currentState.validate()) {
      return;
    }
    model.setPath(imageFile.path);

    ///Check if it is an existent document to know if creation or update is needed
    if (model.entityBeingEdited.id != null) {
      await PetsDBWorker.db.update(model.entityBeingEdited);
    } else {
      await PetsDBWorker.db.create(model.entityBeingEdited);
    }

    ///Return to [PetsList]
    model.loadData(PetsDBWorker.db);
    model.setStackIndex(0);
  }

  ///This method saves a pet model in the cloud
  void _saveInCloud(PetsModel model) async {
    ///If any field is empty, don't proceed
    if (!_formKey.currentState.validate()) {
      return;
    }

    ///Otherwise, add info to the could and return to [PetList]
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

  ///This method opens the gallery so that the user can pick a photo from the gallery
  ///once the image is selected, the state [imageFile] will be updated
  Future _selectImage(BuildContext context) async {
    ///Open gallery
    File galleryImage =
        await ImagePicker.pickImage(source: ImageSource.gallery);

    ///Update state
    setState(() {
      imageFile = galleryImage;
    });
  }
}
