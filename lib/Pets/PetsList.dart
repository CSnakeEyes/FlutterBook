import 'package:flutter/material.dart';
import 'package:flutterbook/Pets/PetsModel.dart';
import 'package:scoped_model/scoped_model.dart';

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

  List<Widget> _buildGrid(List<Pet> pets, PetsModel model) {
    return pets.map((pet) => _buildCardItem(pet, model)).toList();
  }

  Widget _buildCardItem(Pet pet, PetsModel model) {
    return GestureDetector(
      onTap: () {
        model.entityBeingEdited = pet;
        model.setStackIndex(1);
      },
      child: Card(
        elevation: 8.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(pet.name),
      ),
    );
  }
}
