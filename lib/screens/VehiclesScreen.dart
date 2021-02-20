
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mission_tracker_v2/entities/Vehicle.dart';
import 'package:mission_tracker_v2/widgets/VehicleItemWidget.dart';
import 'package:mission_tracker_v2/widgets/VehicleWidget.dart';
import 'package:sqflite/sqflite.dart';
import 'package:connectivity/connectivity.dart';
import 'package:web_socket_channel/io.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sql.dart';

import 'package:mission_tracker_v2/widgets/MissionItemWidget.dart';
import 'package:mission_tracker_v2/widgets/MissionWidget.dart';
import 'package:mission_tracker_v2/entities/Mission.dart';

class VehicleScreen extends StatefulWidget{
  final Future<Database> database;

  VehicleScreen({Key key, this.database}): super(key:key);

  @override
  State<StatefulWidget> createState() => _VehicleScreenState();
}


class _VehicleScreenState extends State<VehicleScreen> {
  static const String _GET_VEHICLES_SERVER_PATH = 'http://172.20.10.11:2021/all';
  static const String _GET_COLORS_SERVER_PATH = 'http://172.20.10.11:2021/colors';

  static const String _POST_VEHICLE = 'http://172.20.10.11:2021/vehicle';
  static const String _DELETE_VEHICLE = 'http://172.20.10.11:2021/vehicle';

  static const String _UPDATE_VEHICLE = 'http://172.20.10.11:2021/vehicle';

  Future<List<Vehicle>> _vehicleList;

  @override
  void initState() {
    super.initState();
    _initWebSocketConnection();
    // _vehicleList = _getVehicles_local();
    _vehicleList = _getVehicles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Vehicle List",
        ),
      ),
      body: FutureBuilder<List<Vehicle>>(
          future: _vehicleList,
          builder: (BuildContext context,
              AsyncSnapshot<List<Vehicle>> snapshot) {
            if (snapshot.hasData &&
                snapshot.connectionState != ConnectionState.waiting) {
              return ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return VehicleItemWidget(
                    vehicle: snapshot.data[index],
                    database: widget.database,
                    addVehicle: this.addVehicle,
                    editVehicle: this.editVehicle,
                    deleteVehicle: this.deleteVehicle,
                  );
                },
              );
            }
            else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          this._navigateToVehicle();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _navigateToVehicle({Vehicle vehicle}) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return VehicleWidget(
            database: widget.database,
            id: vehicle?.getId(),
            addVehicle: this.addVehicle,
            editVehicle: this.editVehicle,
          );
        },
      ),
    );
  }

  ///
  ///           <SERVER METHODS>
  ///
  ///
  Future<List<Vehicle>> _getVehicles() async {
    var connectivityResult = await (Connectivity().checkConnectivity()).timeout(
        Duration(seconds: 5));

    if (connectivityResult == ConnectivityResult.none) {
      _showConnectionError();
      print('_getRules:: Connection error');
      return _getVehicles_local();
    }

    print(connectivityResult.toString());

    // Call the GET method on the API, get the list of rules from the server
    try {
      final response = await http
          .get(_GET_VEHICLES_SERVER_PATH)
          .timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        final vehicles = List<Vehicle>.from(
            json.decode(response.body).map((data) => Vehicle.fromJson(data)));
        await _syncAPIWithDatabase(vehiclesFromAPI: vehicles);
        await _syncDatabaseWithAPI(vehiclesFromAPI: vehicles);
        print('_getRules:: ' + vehicles.toString());
        return vehicles;
      } else {
        // Scaffold.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(
        //       'There was an error while retrieving rules from the API!',
        //     ),
        //   ),
        // );
        print('_getMissions:: There was an error while retrieving rules from the API!');
        return _getVehicles_local();
      }
    } catch (error) {
      _showConnectionError();
      print('_getMissions:: ' + error.toString());
      return _getVehicles_local();
    }
  }


  Future<void> addVehicle(Vehicle vehicle) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      _showConnectionError();
      addVehicle_local(vehicle);
      print('_createMission:: Connection error');
      return;
    }

    try {
      //set the vehicleId
      int vehicleId = await getNextVehicleId();
      vehicle.setId(vehicleId);

      // Call the POST method on the API, save the rule on the remote server
      print('_createVehicle:: POST: ' + vehicle.toString());

      final response = await http
          .post(
        _POST_VEHICLE,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(vehicle.toMap()),
      )
          .timeout(Duration(milliseconds: 5000));

      if (response.statusCode == 200) {
        addVehicle_local(vehicle);
      }
    } catch (error) {
      _showConnectionError();
      addVehicle_local(vehicle);
      print('_createMission:: ' + error.toString());
    }

    setState(() {
      this._vehicleList = _getVehicles();
    });
  }

  Future<void> editVehicle(Vehicle mission) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      _showConnectionError();
      print('_eidtMission:: Connection error');
      return;
    }

    try {
      // Call the POST method on the API, save the rule on the remote server
      final missionToUpdate = mission.toMap();
      missionToUpdate['id'] = mission.getId();

      final response = await http.post(
        '$_UPDATE_VEHICLE',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(missionToUpdate),
      );

      if (response.statusCode == 200) {
        editMission_local(mission);
      } else {
        // Scaffold.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(
        //       'There was an error while updating the mission on the API!',
        //     ),
        //   ),
        // );
        print('_updateMission:: There was an error while updating the mission on the API!');
      }
    } catch (error) {
      _showConnectionError();
      print('_updateMission:: ' + error.toString());
    }
  }


  Future<void> deleteVehicle(Vehicle vehicle) async {
    print("ammmm, print?");
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      _showConnectionError();
      print('_deleteMission:: Connection error');
      deleteMission_local(vehicle);
      return;
    }

    print("print print?");

    try {
      // Call the POST method on the API, save the rule on the remote server
      final missionToRemoveId = vehicle.getId();

      print("in between print");

      final response = await http.delete(
        '$_DELETE_VEHICLE/$missionToRemoveId',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(Duration(seconds: 4));

      print("here print print");

      if (response.statusCode == 200) {
        deleteMission_local(vehicle);
      }
      else {
        print('_deleteMission:: There was an error while deleting the mission on the API!');
      }
    } catch (error) {
      _showConnectionError();
      print('_deleteMission:: ' + error.toString());
      deleteMission_local(vehicle);
    }
  }


  ///
  ///         </SERVER METHODS>
  ///

  /// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

  ///
  ///         <LOCAL METHODS>
  ///
  Future<List<Vehicle>> _getVehicles_local() async{
    //get the database
    final Database db = await widget.database;

    //get all Missions
    final List<Map<String, dynamic>> maps = await db.query("Vehicles").timeout(Duration(seconds: 5));

    //convert List<Map<String, dynamic>> to List<Mission>
    final List<Vehicle> vehicles = List.generate(maps.length, (i){
      Vehicle vehicle = new Vehicle();
      vehicle.setId(maps[i]["id"]);

      vehicle.setAll(
        maps[i]["license"],
        maps[i]["status"],
        (maps[i]["seats"]),
        maps[i]["driver"],
        maps[i]["color"],
        (maps[i]["cargo"]),
      );

      return vehicle;
    });

    print("Local vehicles get all: " + vehicles.toString());

    return vehicles;
  }

  Future<void> addVehicle_local(Vehicle vehicle) async{
    final Database db = await widget.database;

    //set the missionId
    int missionId = await getNextVehicleId();
    vehicle.setId(missionId);

    //add the mission
    await db.insert(
      "Vehicles",
      vehicle.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print("Mission created locally: " + vehicle.toString());
    setState(() {
      _vehicleList = _getVehicles_local();
    });
  }


  Future<void> editMission_local(Vehicle mission) async{
    final Database db = await widget.database;

    await db.update(
      "Vehicles",
      mission.toMap(),
      where: "id = ?",
      whereArgs: [mission.getId()],
    );

    setState(() {
      _vehicleList = _getVehicles_local();
    });
  }

  Future<void> deleteMission_local(Vehicle mission) async{
    print('deleteMission_local:: insides');
    final Database db = await widget.database;

    await db.delete(
      "Vehicles",
      where: "id = ?",
      whereArgs: [mission.getId()],
    );

    setState((){
      _vehicleList = _getVehicles_local();
    });
  }

  Future<int> getNextVehicleId() async {
    final Database db = await widget.database;
    int maxExistingMissionId = 0;
    final result = await db.rawQuery("SELECT MAX(id) FROM Vehicles");
    if(result.length != 0)
      maxExistingMissionId = Sqflite.firstIntValue(result);

    return maxExistingMissionId+1;
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text(
  //         "Missions available"
  //       ),
  //     ),
  //     body: Form(
  //       child: Column(
  //         children: [
  //           TextFormField(
  //             decoration: InputDecoration(
  //               labelText: "label",
  //             ),
  //             initialValue: "buna",
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }


  void _initWebSocketConnection() async{
    var connnResult = await (Connectivity().checkConnectivity());

    if(connnResult == ConnectivityResult.none){
      return;
    }

    final channel = IOWebSocketChannel.connect("ws://10.0.2.2:8080");

    channel.stream.listen((message) {
      final mission = Vehicle.fromJson(json.decode(message));
      // Scaffold.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(
      //       mission.toString(),
      //     ),
      //   ),
      // );
      print('WebSocket received: ' + message);
    });
  }


  Future<void> _syncAPIWithDatabase({List<Vehicle> vehiclesFromAPI}) async {
    // Get a reference to the database.
    final Database db = await widget.database;

    // Query the table for all The Candidates.
    final List<Map<String, dynamic>> maps = await db.query('Vehicles');

    // Convert the List<Map<String, dynamic>> into a List<Candidate>.
    final vehiclesFromDB = List.generate(maps.length, (i) {
      return Vehicle(
        id: maps[i]['id'],
        license: maps[i]['license'],
        color: maps[i]['color'],
        status: maps[i]['status'],
        seats: maps[i]['seats'],
        cargo: maps[i]['cargo'],
        driver: maps[i]['driver'],
      );
    });

    // Check if there are new elements in the DB that are not on the API
    for (final vehicleFromDB in vehiclesFromDB) {
      if (vehiclesFromAPI.indexWhere((vehicleFromAPI) => vehicleFromDB.getId() == vehicleFromAPI.getId()) == -1) {
        // Then send a POST request for the new rule

        // Call the POST method on the API, save the rule on the remote server
        await http.post(
          _POST_VEHICLE,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(vehicleFromDB.toMap()),
        );

        // Add to the list as well
        vehiclesFromAPI.add(vehicleFromDB);
      }
    }

    print('_syncAPIWithDatabase:: ' + vehiclesFromAPI.toString());
  }


  Future<void> _syncDatabaseWithAPI({List<Vehicle> vehiclesFromAPI}) async {
    // Get a reference to the database.
    final Database db = await widget.database;

    // Query the table for all The Candidates.
    final List<Map<String, dynamic>> maps = await db.query('Vehicles');

    // Convert the List<Map<String, dynamic>> into a List<Candidate>.
    final vehiclesFromDB = List.generate(maps.length, (i) {
      return Vehicle(
        id: maps[i]['id'],
        license: maps[i]['license'],
        color: maps[i]['color'],
        status: maps[i]['status'],
        seats: maps[i]['seats'],
        cargo: maps[i]['cargo'],
        driver: maps[i]['driver'],
      );
    });

    // Check if there are new elements in the API that are not on the DB
    for (final vehicleFromAPI in vehiclesFromAPI) {
      if (vehiclesFromDB.indexWhere((vehicleFromDB) => vehicleFromAPI == vehicleFromDB) ==
          -1) {
        // Then add it to the local DB

        // Get a reference to the database.
        final Database db = await widget.database;

        // Insert the Candidate into the correct table. Also specify the
        // `conflictAlgorithm`. In this case, if the same rule is inserted
        // multiple times, it replaces the previous data.
        await db.insert(
          'Vehicles',
          vehicleFromAPI.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        vehiclesFromDB.add(vehicleFromAPI);
      }
    }

    print('_syncDatabaseWithAPI:: ' + vehiclesFromDB.toString());
  }


  void _showConnectionError() {
    // Scaffold.of(context).hideCurrentSnackBar();
    print("showing a snackBar");
    // Scaffold.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text(
    //       'The application is offline!',
    //     ),
    //     // action: SnackBarAction(
    //     //   label: 'Retry',
    //     //   onPressed: () {
    //     //     setState(() {
    //     //       _missionList = _getMissions();
    //     //     });
    //     //
    //     //   },
    //     // ),
    //     // duration: Duration(seconds: 2),
    //   ),
    // );
    print("snackBar was showed");
  }
}