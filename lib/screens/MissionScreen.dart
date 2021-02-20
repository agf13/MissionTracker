//
// import 'dart:convert';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:connectivity/connectivity.dart';
// import 'package:web_socket_channel/io.dart';
// import 'package:http/http.dart' as http;
// import 'package:sqflite/sql.dart';
//
// import 'package:mission_tracker_v2/widgets/MissionItemWidget.dart';
// import 'package:mission_tracker_v2/widgets/MissionWidget.dart';
// import 'package:mission_tracker_v2/entities/Mission.dart';
//
// class MissionScreen extends StatefulWidget{
//   final Future<Database> database;
//
//   MissionScreen({Key key, this.database}): super(key:key);
//
//   @override
//   State<StatefulWidget> createState() => _MissionScreenState();
// }
//
//
// class _MissionScreenState extends State<MissionScreen> {
//   static const String _GET_MISSIONS_SERVER_PATH = 'http://192.168.1.102:8080/missions';
//   static const String _POST_MISSION = 'http://192.168.1.102:8080/mission';
//   static const String _UPDATE_MISSION = 'http://192.168.1.102:8080/update';
//   static const String _REMOVE_MISSION = 'http://192.168.1.102:8080/mission';
//
//   Future<List<Vehicle>> _missionList;
//
//   @override
//   void initState() {
//     super.initState();
//     _initWebSocketConnection();
//     //_missionList = _getMissions_local();
//     _missionList = _getMissions();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "Mission List",
//         ),
//       ),
//       body: FutureBuilder<List<Vehicle>>(
//           future: _missionList,
//           builder: (BuildContext context,
//               AsyncSnapshot<List<Vehicle>> snapshot) {
//             if (snapshot.hasData &&
//                 snapshot.connectionState != ConnectionState.waiting) {
//               return ListView.builder(
//                 padding: EdgeInsets.all(12),
//                 itemCount: snapshot.data.length,
//                 itemBuilder: (BuildContext context, int index) {
//                   return MissionItemWidget(
//                     mission: snapshot.data[index],
//                     database: widget.database,
//                     addMission: this.addMission,
//                     editMission: this.editMission,
//                     deleteMission: this.deleteMission,
//                   );
//                 },
//               );
//             }
//             else {
//               return Center(
//                 child: CircularProgressIndicator(),
//               );
//             }
//           }
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           this._navigateToMission();
//         },
//         child: Icon(Icons.add),
//       ),
//     );
//   }
//
//   void _navigateToMission({Vehicle mission}) async {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) {
//           return MissionWidget(
//             database: widget.database,
//             missionId: mission?.getId(),
//             addMission: this.addMission,
//             editMission: this.editMission,
//           );
//         },
//       ),
//     );
//   }
//
//   ///
//   ///           <SERVER METHODS>
//   ///
//   ///
//   Future<List<Vehicle>> _getMissions() async {
//     var connectivityResult = await (Connectivity().checkConnectivity()).timeout(
//         Duration(seconds: 5));
//
//     if (connectivityResult == ConnectivityResult.none) {
//       _showConnectionError();
//       print('_getRules:: Connection error');
//       return _getMissions_local();
//     }
//
//     print(connectivityResult.toString());
//
//     // Call the GET method on the API, get the list of rules from the server
//     try {
//       final response = await http
//           .get(_GET_MISSIONS_SERVER_PATH)
//           .timeout(const Duration(seconds: 2));
//
//       if (response.statusCode == 200) {
//         final missions = List<Vehicle>.from(
//             json.decode(response.body).map((data) => Vehicle.fromJson(data)));
//         await _syncAPIWithDatabase(missionsFromAPI: missions);
//         await _syncDatabaseWithAPI(missionsFromAPI: missions);
//         print('_getRules:: ' + missions.toString());
//         return missions;
//       } else {
//         // Scaffold.of(context).showSnackBar(
//         //   SnackBar(
//         //     content: Text(
//         //       'There was an error while retrieving rules from the API!',
//         //     ),
//         //   ),
//         // );
//         print('_getMissions:: There was an error while retrieving rules from the API!');
//         return _getMissions_local();
//       }
//     } catch (error) {
//       _showConnectionError();
//       print('_getMissions:: ' + error.toString());
//       return _getMissions_local();
//     }
//   }
//
//
//   Future<void> addMission(Vehicle mission) async {
//     var connectivityResult = await (Connectivity().checkConnectivity());
//     if (connectivityResult == ConnectivityResult.none) {
//       _showConnectionError();
//       addMission_local(mission);
//       print('_createMission:: Connection error');
//       return;
//     }
//
//     try {
//       //set the missionId
//       int missionId = await getNextMissionId();
//       mission.setId(missionId);
//
//       // Call the POST method on the API, save the rule on the remote server
//       print('_createMission:: POST: ' + mission.toString());
//
//       final response = await http
//           .post(
//         _POST_MISSION,
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//         },
//         body: jsonEncode(mission.toMap()),
//       )
//           .timeout(Duration(milliseconds: 5000));
//
//       if (response.statusCode == 200) {
//         addMission_local(mission);
//       }
//     } catch (error) {
//       _showConnectionError();
//       addMission_local(mission);
//       print('_createMission:: ' + error.toString());
//     }
//
//     setState(() {
//       this._missionList = _getMissions();
//     });
//   }
//
//   Future<void> editMission(Vehicle mission) async {
//     var connectivityResult = await (Connectivity().checkConnectivity());
//     if (connectivityResult == ConnectivityResult.none) {
//       _showConnectionError();
//       print('_eidtMission:: Connection error');
//       return;
//     }
//
//     try {
//       // Call the POST method on the API, save the rule on the remote server
//       final missionToUpdate = mission.toMap();
//       missionToUpdate['id'] = mission.getId();
//
//       final response = await http.post(
//         '$_UPDATE_MISSION',
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//         },
//         body: jsonEncode(missionToUpdate),
//       );
//
//       if (response.statusCode == 200) {
//         editMission_local(mission);
//       } else {
//         // Scaffold.of(context).showSnackBar(
//         //   SnackBar(
//         //     content: Text(
//         //       'There was an error while updating the mission on the API!',
//         //     ),
//         //   ),
//         // );
//         print('_updateMission:: There was an error while updating the mission on the API!');
//       }
//     } catch (error) {
//       _showConnectionError();
//       print('_updateMission:: ' + error.toString());
//     }
//   }
//
//
//   Future<void> deleteMission(Vehicle mission) async {
//     print("ammmm, print?");
//     var connectivityResult = await (Connectivity().checkConnectivity());
//     if (connectivityResult == ConnectivityResult.none) {
//       _showConnectionError();
//       print('_deleteMission:: Connection error');
//       deleteMission_local(mission);
//       return;
//     }
//
//     print("print print?");
//
//     try {
//       // Call the POST method on the API, save the rule on the remote server
//       final missionToRemoveId = mission.getId();
//
//       print("in between print");
//
//       final response = await http.post(
//         '$_REMOVE_MISSION/$missionToRemoveId',
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//         },
//       ).timeout(Duration(seconds: 4));
//
//       print("here print print");
//
//       if (response.statusCode == 200) {
//         deleteMission_local(mission);
//       }
//       else {
//         print('_deleteMission:: There was an error while deleting the mission on the API!');
//       }
//     } catch (error) {
//       _showConnectionError();
//       print('_deleteMission:: ' + error.toString());
//       deleteMission_local(mission);
//     }
//   }
//
//
//   ///
//   ///         </SERVER METHODS>
//   ///
//
//   /// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
//
//   ///
//   ///         <LOCAL METHODS>
//   ///
//   Future<List<Vehicle>> _getMissions_local() async{
//     //get the database
//     final Database db = await widget.database;
//
//     //get all Missions
//     final List<Map<String, dynamic>> maps = await db.query("Missions").timeout(Duration(seconds: 2));
//
//     //convert List<Map<String, dynamic>> to List<Mission>
//     final List<Vehicle> missions = List.generate(maps.length, (i){
//       Vehicle mission = new Vehicle();
//       mission.setId(maps[i]["missionId"]);
//       mission.setAll(
//         maps[i]["title"],
//         maps[i]["importance"],
//         maps[i]["details"],
//         maps[i]["additionalInformation"],
//       );
//       return mission;
//     });
//
//     print("Local missions get all: " + missions.toString());
//
//     return missions;
//   }
//
//   Future<void> addMission_local(Vehicle mission) async{
//     final Database db = await widget.database;
//
//     //set the missionId
//     int missionId = await getNextMissionId();
//     mission.setId(missionId);
//
//     //add the mission
//     await db.insert(
//       "Missions",
//       mission.toMap(),
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//
//     print("Mission created locally: " + mission.toString());
//     setState(() {
//       _missionList = _getMissions_local();
//     });
//   }
//
//
//   Future<void> editMission_local(Vehicle mission) async{
//     final Database db = await widget.database;
//
//     await db.update(
//       "Missions",
//       mission.toMap(),
//       where: "missionId = ?",
//       whereArgs: [mission.getId()],
//     );
//
//     setState(() {
//       _missionList = _getMissions_local();
//     });
//   }
//
//   Future<void> deleteMission_local(Vehicle mission) async{
//     print('deleteMission_local:: insides');
//     final Database db = await widget.database;
//
//     await db.delete(
//       "Missions",
//       where: "missionId = ?",
//       whereArgs: [mission.getId()],
//     );
//
//     setState((){
//       _missionList = _getMissions_local();
//     });
//   }
//
//   Future<int> getNextMissionId() async {
//     final Database db = await widget.database;
//     int maxExistingMissionId = 0;
//     final result = await db.rawQuery("SELECT MAX(missionId) FROM Missions");
//     if(result.length != 0)
//       maxExistingMissionId = Sqflite.firstIntValue(result);
//
//     return maxExistingMissionId+1;
//   }
//
//   // @override
//   // Widget build(BuildContext context) {
//   //   return Scaffold(
//   //     appBar: AppBar(
//   //       title: Text(
//   //         "Missions available"
//   //       ),
//   //     ),
//   //     body: Form(
//   //       child: Column(
//   //         children: [
//   //           TextFormField(
//   //             decoration: InputDecoration(
//   //               labelText: "label",
//   //             ),
//   //             initialValue: "buna",
//   //           )
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }
//
//
//   void _initWebSocketConnection() async{
//     var connnResult = await (Connectivity().checkConnectivity());
//
//     if(connnResult == ConnectivityResult.none){
//       return;
//     }
//
//     final channel = IOWebSocketChannel.connect("ws://10.0.2.2:8080");
//
//     channel.stream.listen((message) {
//       final mission = Vehicle.fromJson(json.decode(message));
//       // Scaffold.of(context).showSnackBar(
//       //   SnackBar(
//       //     content: Text(
//       //       mission.toString(),
//       //     ),
//       //   ),
//       // );
//       print('WebSocket received: ' + message);
//     });
//   }
//
//
//   Future<void> _syncAPIWithDatabase({List<Vehicle> missionsFromAPI}) async {
//     // Get a reference to the database.
//     final Database db = await widget.database;
//
//     // Query the table for all The Candidates.
//     final List<Map<String, dynamic>> maps = await db.query('Missions');
//
//     // Convert the List<Map<String, dynamic>> into a List<Candidate>.
//     final missionsFromDB = List.generate(maps.length, (i) {
//       return Vehicle(
//         missionId: maps[i]['missionId'],
//         importance: maps[i]['importance'],
//         title: maps[i]['title'],
//         details: maps[i]['details'],
//         additionalInformation: maps[i]['additionalInformation'],
//       );
//     });
//
//     // Check if there are new elements in the DB that are not on the API
//     for (final missionFromDB in missionsFromDB) {
//       if (missionsFromAPI.indexWhere((missionFromAPI) => missionFromDB.getId() == missionFromAPI.getId()) == -1) {
//         // Then send a POST request for the new rule
//
//         // Call the POST method on the API, save the rule on the remote server
//         await http.post(
//           _POST_MISSION,
//           headers: <String, String>{
//             'Content-Type': 'application/json; charset=UTF-8',
//           },
//           body: jsonEncode(missionFromDB.toMap()),
//         );
//
//         // Add to the list as well
//         missionsFromAPI.add(missionFromDB);
//       }
//     }
//
//     print('_syncAPIWithDatabase:: ' + missionsFromAPI.toString());
//   }
//
//
//   Future<void> _syncDatabaseWithAPI({List<Vehicle> missionsFromAPI}) async {
//     // Get a reference to the database.
//     final Database db = await widget.database;
//
//     // Query the table for all The Candidates.
//     final List<Map<String, dynamic>> maps = await db.query('Missions');
//
//     // Convert the List<Map<String, dynamic>> into a List<Candidate>.
//     final missionsFromDB = List.generate(maps.length, (i) {
//       return Vehicle(
//         missionId: maps[i]['missionId'],
//         title: maps[i]['title'],
//         importance: maps[i]['importance'],
//         details: maps[i]['details'],
//         additionalInformation: maps[i]['additionalInformation'],
//       );
//     });
//
//     // Check if there are new elements in the API that are not on the DB
//     for (final missionFromAPI in missionsFromAPI) {
//       if (missionsFromDB.indexWhere((missionFromDB) => missionFromAPI == missionFromDB) ==
//           -1) {
//         // Then add it to the local DB
//
//         // Get a reference to the database.
//         final Database db = await widget.database;
//
//         // Insert the Candidate into the correct table. Also specify the
//         // `conflictAlgorithm`. In this case, if the same rule is inserted
//         // multiple times, it replaces the previous data.
//         await db.insert(
//           'Missions',
//           missionFromAPI.toMap(),
//           conflictAlgorithm: ConflictAlgorithm.replace,
//         );
//
//         missionsFromDB.add(missionFromAPI);
//       }
//     }
//
//     print('_syncDatabaseWithAPI:: ' + missionsFromDB.toString());
//   }
//
//
//   void _showConnectionError() {
//     // Scaffold.of(context).hideCurrentSnackBar();
//     print("showing a snackBar");
//     // Scaffold.of(context).showSnackBar(
//     //   SnackBar(
//     //     content: Text(
//     //       'The application is offline!',
//     //     ),
//     //     // action: SnackBarAction(
//     //     //   label: 'Retry',
//     //     //   onPressed: () {
//     //     //     setState(() {
//     //     //       _missionList = _getMissions();
//     //     //     });
//     //     //
//     //     //   },
//     //     // ),
//     //     // duration: Duration(seconds: 2),
//     //   ),
//     // );
//     print("snackBar was showed");
//   }
// }