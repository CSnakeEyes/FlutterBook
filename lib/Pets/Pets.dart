import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'PetsDBWorker.dart';
import 'PetsModel.dart' show PetsModel, petsModel;
import 'PetsList.dart';
import 'PetsEntry.dart';

class Pets extends StatelessWidget {
  Pets() {
    petsModel.loadData(PetsDBWorker.db);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<PetsModel>(
      model: petsModel,
      child: ScopedModelDescendant<PetsModel>(
        builder: (BuildContext context, Widget child, PetsModel model) {
          return IndexedStack(
            index: model.stackIndex,
            children: <Widget>[
              PetsList(),
              PetsEntry(),
            ],
          );
        },
      ),
    );
  }
}
