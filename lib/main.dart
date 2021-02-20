import 'package:flutter/material.dart';
import 'package:mission_tracker_v2/screens/LoginScreen.dart';
import 'package:mission_tracker_v2/screens/MissionScreen.dart';
import 'package:mission_tracker_v2/screens/VehiclesScreen.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:mission_tracker_v2/entities/Mission.dart';

import 'entities/Vehicle.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  final Future<Database> database = openDatabase(
    join(await getDatabasesPath(), "vehicleTracker_v2.db"),
    onCreate:(db, version){
      db.execute(
          "CREATE TABLE Vehicles("
          "id INT PRIMARY KEY,"
          "license TEXT,"
          "status TEXT,"
          "seats INT,"
          "driver TEXT,"
          "color TEXT,"
          "cargo INT)"
      );
    },
    version: 1,
  );

  runApp(MyApp(
    database: database,
  ));
}

class MyApp extends StatefulWidget {
  final Future<Database> database;

  MyApp({this.database}){
    initDatabse();
  }

  Future<void> initDatabse() async{
    final Database db = await this.database;

    final numberVehicles_rawResult = await db.rawQuery("SELECT COUNT(*) FROM Vehicles");
    int numberVehicles = Sqflite.firstIntValue(numberVehicles_rawResult);

    if(numberVehicles == 0){
      Vehicle firstVehicle = Vehicle();
      firstVehicle.setId(1);
      firstVehicle.setAll(
        "BV13ZCG",
        "new",
        5,
        "Mircea Ioan",
        "Blue",
        10
      );
      db.insert(
        "Vehicles",
        firstVehicle.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace
      );

      print("vehicle added in init: " + firstVehicle.toString());
    }


  }

  // This widget is the root of your application.
  @override
  State<StatefulWidget> createState() =>_MyAppState();
}


class _MyAppState extends State<MyApp>{

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Vehicle Tracker",
      theme: ThemeData(
        primaryColor: Colors.blue,
      ),
      home: VehicleScreen(
        database: widget.database,
      ),
    );
  }
  
}

