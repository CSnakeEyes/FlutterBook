import 'package:flutterbook/Appointments/AppointmentsModel.dart';
import 'package:sqflite/sqflite.dart';

class AppointmentsDBWorker {

  static final AppointmentsDBWorker db = AppointmentsDBWorker._();

  static const String DB_NAME = 'appointments.db';
  static const String TBL_NAME = 'appointments';
  static const String KEY_ID = 'id';
  static const String KEY_TITLE = 'title';
  static const String KEY_DESCRIPTION = 'description';
  static const String KEY_DATE = 'date';
  static const String KEY_TIME = 'time';

  Database _db;

  AppointmentsDBWorker._();

  Future<Database> get database async => _db ??= await _init();

  Future<Database> _init() async {
    return await openDatabase(DB_NAME,
        version: 1,
        onOpen: (db) {},
        onCreate: (Database db, int version) async {
          await db.execute(
              "CREATE TABLE IF NOT EXISTS $TBL_NAME ("
                  "$KEY_ID INTEGER PRIMARY KEY,"
                  "$KEY_TITLE TEXT,"
                  "$KEY_DESCRIPTION TEXT,"
                  "$KEY_DATE TEXT,"
                  "$KEY_TIME TEXT"
              ")"
          );
        }
    );
  }

    Future<int> create(Appointment appt) async {
    Database db = await database;
    await db.insert(
      TBL_NAME,
      _appointmentToMap(appt),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return 0;
  }

  Future<void> delete(int id) async {
    Database db = await database;
    await db.delete(TBL_NAME, where: "$KEY_ID = ?", whereArgs: [id]);
  }

  Future<Appointment> get(int id) async {
    Database db = await database;
    var values = await db.query(TBL_NAME, where: "$KEY_ID = ?", whereArgs: [id]);
    return values.isEmpty ? null : _appointmentFromMap(values.first);
  }

  Future<List<Appointment>> getAll() async {
    Database db = await database;
    var values = await db.query(TBL_NAME);
    return values.isNotEmpty ? values.map((m) => _appointmentFromMap(m)).toList() : [];
  }

  Future<void> update(Appointment appt) async {
    Database db = await database;
    await db.update(TBL_NAME, _appointmentToMap(appt),
        where: "$KEY_ID = ?", whereArgs: [appt.id]);
  }

  Appointment _appointmentFromMap(Map<String, dynamic> map) {
    return Appointment()
      ..id = map[KEY_ID]
      ..title = map[KEY_TITLE]
      ..description = map[KEY_DESCRIPTION]
      ..date = map[KEY_DATE]
      ..time = map[KEY_TIME];
  }

  Map<String, dynamic> _appointmentToMap(Appointment appt) {
    return Map<String, dynamic>()
      ..[KEY_ID] = appt.id
      ..[KEY_TITLE] = appt.title
      ..[KEY_DESCRIPTION] = appt.description
      ..[KEY_DATE] = appt.date
      ..[KEY_TIME] = appt.time;
  }

}