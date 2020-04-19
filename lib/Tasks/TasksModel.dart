import 'package:flutterbook/Tasks/TasksDBWorker.dart';
import '../BaseModel.dart';

TasksModel tasksModel = TasksModel();

class Task {
  int id;
  String description;
  String dueDate;
  bool completed = false;

  Map toMap() {
    return {
      TasksDBWorker.KEY_ID: id,
      TasksDBWorker.KEY_DESCRIPTION: description,
      TasksDBWorker.KEY_DUE_DATE: dueDate,
      TasksDBWorker.KEY_COMPLETED: completed
    };
  }

  String toString() {
    return "{ id=$id, description=$description, dueDate=$dueDate, completed=$completed }";
  }

  bool hasDueDate() {
    return dueDate != null;
  }
}

class TasksModel extends BaseModel<Task> with DateSelection {
}