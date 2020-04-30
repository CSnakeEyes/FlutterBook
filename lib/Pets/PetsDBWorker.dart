import 'package:flutterbook/Pets/PetsModel.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class PetsDBWorker {
  static final PetsDBWorker db = PetsDBWorker._();

  static const String DB_NAME = 'pets.db';
  static const String TBL_NAME = 'pets';
  static const String KEY_ID = 'id';
  static const String KEY_NAME = 'name';
  static const String KEY_PATH = 'path';
  static const String KEY_BIRTHDAY = 'birthday';
  static const String KEY_LATESTVISIT = 'latestvisit';

  Database _db;

  PetsDBWorker._();

  Future<Database> get database async => _db ??= await _init();

  Future<Database> _init() async {
    return await openDatabase(
      join(await getDatabasesPath(), DB_NAME),
      version: 1,
      onOpen: (db) async {
        //await db.execute("DROP TABLE $TBL_NAME");
        //await db.execute(
        //"CREATE TABLE IF NOT EXISTS $TBL_NAME ($KEY_ID INTEGER PRIMARY KEY, $KEY_NAME TEXT, $KEY_PATH TEXT, $KEY_BIRTHDAY TEXT, $KEY_LATESTVISIT TEXT)");
      },
      onCreate: (db, version) async {
        await db.execute(
            "CREATE TABLE IF NOT EXISTS $TBL_NAME ($KEY_ID INTEGER PRIMARY KEY, $KEY_NAME TEXT, $KEY_PATH TEXT, $KEY_BIRTHDAY TEXT, $KEY_LATESTVISIT TEXT)");
      },
    );
  }

  ///This method insert a new row in the [PETS_TABLE] with the information of [pet]
  Future<void> create(Pet pet) async {
    Map petMap = _petToMap(pet);
    Database db = await database;
    await db.insert(
      TBL_NAME,
      petMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  ///This method deletes a row in the [PETS_TABLE] given an [id]
  Future<void> delete(int id) async {
    Database db = await database;
    await db.delete(TBL_NAME, where: "$KEY_ID = ?", whereArgs: [id]);
  }

  ///This method gets an row in the [PETS_TABLE] given an [id]
  Future<Pet> get(int id) async {
    Database db = await database;
    var values =
        await db.query(TBL_NAME, where: "$KEY_ID = ?", whereArgs: [id]);
    return values.isEmpty ? null : _petFromMap(values.first);
  }

  ///This method obtains all the rows in the [PETS_TABLE]
  Future<List<Pet>> getAll() async {
    Database db = await database;
    var values = await db.query(TBL_NAME);
    return values.isNotEmpty ? values.map((m) => _petFromMap(m)).toList() : [];
  }

  ///This method updates a row in the [PETS_TABLE] given a [pet]
  Future<void> update(Pet pet) async {
    Database db = await database;
    await db.update(TBL_NAME, _petToMap(pet),
        where: "$KEY_ID = ?", whereArgs: [pet.id]);
  }

  ///This method transforms a [map] to a [pet object]
  Pet _petFromMap(Map<String, dynamic> map) {
    return Pet()
      ..id = map[KEY_ID]
      ..name = map[KEY_NAME]
      ..path = map[KEY_PATH]
      ..birthday = map[KEY_BIRTHDAY]
      ..latestVisit = map[KEY_LATESTVISIT];
  }

  ///This method transforms a [pet object] to a [map]
  Map<String, dynamic> _petToMap(Pet pet) {
    return Map<String, dynamic>()
      ..[KEY_NAME] = pet.name
      ..[KEY_PATH] = pet.path
      ..[KEY_BIRTHDAY] = pet.birthday
      ..[KEY_LATESTVISIT] = pet.latestVisit;
  }
}
