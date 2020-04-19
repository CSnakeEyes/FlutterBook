import 'package:flutter/material.dart';
import 'Notes/Notes.dart';
import 'package:path_provider/path_provider.dart';
import 'Appointments/Appointments.dart';
import 'Contacts/Avatar.dart';
import 'Contacts/Contacts.dart';
import 'Tasks/Tasks.dart';

void main() {
  startMeUp() async {
    WidgetsFlutterBinding.ensureInitialized();
    Avatar.docsDir = await getApplicationDocumentsDirectory();
    runApp(FlutterBook());
  }

  startMeUp();
}

class FlutterBook extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Book',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
              title: Text('Miguel Angel Zamudio Arias'),
              bottom: TabBar(tabs: [
                Tab(icon: Icon(Icons.date_range), text: 'Appointments'),
                Tab(icon: Icon(Icons.contacts), text: 'Contacts'),
                Tab(icon: Icon(Icons.note), text: 'Notes'),
                Tab(icon: Icon(Icons.assignment_turned_in), text: 'Tasks'),
              ])),
          body: TabBarView(
            children: [
              Appointments(),
              Contacts(),
              Notes(),
              Tasks(),
            ],
          ),
        ),
      ),
    );
  }
}
