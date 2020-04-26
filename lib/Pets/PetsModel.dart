import "../BaseModel.dart";

PetsModel petsModel = PetsModel();

class Pet {
  int id;
  String name;
  String path = "";
  String birthday;
  String latestVisit;

  @override
  String toString() {
    return "{ id=$id name=$name path=$path birthday=$birthday lastestVisit=$latestVisit }";
  }
}

class PetsModel extends BaseModel<Pet> with DateSelection {
  void setPath(String path) {
    print(this.entityBeingEdited.path);
    this.entityBeingEdited.path = path;
    notifyListeners();
  }

  void setBirthday(String birthday) {
    this.entityBeingEdited.birthday = birthday;
    notifyListeners();
  }

  void setLatestVisit(String latestVisit) {
    this.entityBeingEdited.latestVisit = latestVisit;
    notifyListeners();
  }
}
