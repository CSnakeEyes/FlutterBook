import "../BaseModel.dart";

PetsModel petsModel = PetsModel();

class Pet {
  int id;
  String name;

  ///Pet name
  String path;

  ///Pet photo in gallery
  String birthday;

  ///Pet birthday
  String latestVisit;

  ///Last day that pet was

  @override
  String toString() {
    return "{ id=$id name=$name path=$path birthday=$birthday lastestVisit=$latestVisit }";
  }
}

class PetsModel extends BaseModel<Pet> {
  String path;
  String birthday;
  String latestVisit;

  ///Update value of the image of the pet
  void setPath(String path) {
    this.path = path;
    notifyListeners();
  }

  ///Update value of the birthday of the pet
  void setBirthday(String birthday) {
    this.birthday = birthday;
    notifyListeners();
  }

  ///Update value of the last day that te veterinarian was visited
  void setLatestVisit(String latestVisit) {
    this.latestVisit = latestVisit;
    notifyListeners();
  }
}
