import "../BaseModel.dart";

PetsModel petsModel = PetsModel();

class Pet {
  int id;
  String name;
  String path;
  String birthday;
  String latestVisit;

  @override
  String toString() {
    return "{ id=$id name=$name path=$path birthday=$birthday lastestVisit=$latestVisit }";
  }
}

class PetsModel extends BaseModel<Pet> {
  String path;
  String birthday;
  String latestVisit;

  void setPath(String path) {
    this.path = path;
    notifyListeners();
  }

  void setBirthday(String birthday) {
    this.birthday = birthday;
    notifyListeners();
  }

  void setLatestVisit(String latestVisit) {
    this.latestVisit = latestVisit;
    notifyListeners();
  }
}
