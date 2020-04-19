import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'NotesModel.dart' show Note, NotesModel;
import 'NotesDBWorker.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class NotesList extends StatelessWidget {

  Color _toColor(String str) {
    Color color;
    switch (str) {
      case "red" : color = Colors.red; break;
      case "green" : color = Colors.green; break;
      case "blue" : color = Colors.blue; break;
      case "yellow" : color = Colors.yellow; break;
      case "grey" : color = Colors.grey; break;
      case "purple" : color = Colors.purple; break;
    }

    return color;
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<NotesModel>(
        builder: (BuildContext context, Widget child, NotesModel model) {
          return Scaffold(
              floatingActionButton: FloatingActionButton(
                  child: Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    model.entityBeingEdited = Note();
                    model.setColor(null);
                    model.setStackIndex(1);
                  }
              ),
              body: ListView.builder(
                  itemCount: model.entityList.length,
                  itemBuilder: (BuildContext context, int index) {
                    Note note = model.entityList[index];
                    Color color = _toColor(note.color);
                    return Container(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Slidable(
                            actionPane: SlidableDrawerActionPane(),
                            actionExtentRatio: .25,
                            secondaryActions: [
                              IconSlideAction(
                                  caption: "Delete",
                                  color: Colors.red,
                                  icon: Icons.delete,
                                  onTap: () => _deleteNote(context, model, note)
                              )
                            ],
                            child: Card(
                                elevation: 8,
                                color: color,
                                child: ListTile(
                                  title: Text(note.title),
                                  subtitle: Text(note.content),
                                  onTap: () {
                                    model.entityBeingEdited = note;
                                    model.setColor(model.entityBeingEdited.color);
                                    model.setStackIndex(1);
                                  },
                                )
                            )
                        )
                    );
                  }
              )
          );
        }
    );
  }

  _deleteNote(BuildContext context, NotesModel model, Note note) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext alertContext) {
          return AlertDialog(
              title: Text("Delete Note"),
              content: Text(
                  "Are you sure you want to delete ${note.title}?"
              ),
              actions: [
                FlatButton(child: Text("Cancel"),
                    onPressed: () {
                      Navigator.of(alertContext).pop();
                    }
                ),
                FlatButton(child: Text("Delete"),
                    onPressed: () async {
                      await NotesDBWorker.db.delete(note.id);
                      Navigator.of(alertContext).pop();
                      Scaffold.of(context).showSnackBar(
                          SnackBar(
                              backgroundColor: Colors.red,
                              duration: Duration(seconds : 2),
                              content: Text("Note deleted")
                          )
                      );
                      model.loadData(NotesDBWorker.db);
                    }
                )
              ]
          );
        }
    );
  }
}
