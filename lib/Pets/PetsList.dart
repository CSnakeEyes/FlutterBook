import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutterbook/Pets/PetsModel.dart';
import 'package:scoped_model/scoped_model.dart';

///Class to show a list of pets in the screen
class PetsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<PetsModel>(
      model: petsModel,
      child: ScopedModelDescendant<PetsModel>(
        builder: (BuildContext context, Widget child, PetsModel model) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () {
                petsModel.entityBeingEdited = Pet();
                petsModel.setStackIndex(1);
              },
            ),
            body: GridView.count(
              padding: EdgeInsets.all(10.0),
              primary: false,
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              shrinkWrap: true,
              children: _buildGrid(model.entityList, model),
            ),
          );
        },
      ),
    );
  }

  ///This method will build a grid of card items
  List<Widget> _buildGrid(List<Pet> pets, PetsModel model) {
    return pets.map((pet) => _buildCardItem(pet, model)).toList();
  }

  ///This method will build a card item of the grid
  Widget _buildCardItem(Pet pet, PetsModel model) {
    return GestureDetector(
      onTap: () {
        model.entityBeingEdited = pet;
        model.setStackIndex(1);
      },
      child: Card(
        elevation: 8.0,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: ClipRRect(
                      child: Image.file(
                        File(pet.path),
                        fit: BoxFit.cover,
                      ),
                    )),
              ),
              Container(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  pet.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            ]),
      ),
    );
  }
}
