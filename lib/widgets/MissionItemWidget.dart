//
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:mission_tracker_v2/entities/Mission.dart';
// import 'package:mission_tracker_v2/widgets/MissionWidget.dart';
// import 'package:sqflite/sqflite.dart';
//
// class MissionItemWidget extends StatefulWidget{
//   Vehicle mission;
//   Function editMission;
//   Function addMission;
//   Function deleteMission;
//   Future<Database> database;
//
//
//   MissionItemWidget({this.mission, this.database, this.addMission, this.editMission, this.deleteMission});
//
//   @override
//   State<StatefulWidget> createState() {
//     return _MissionItemWidgetState();
//   }
//
// }
//
// class _MissionItemWidgetState extends State<MissionItemWidget>{
//
//   var _importanceFont = TextStyle(fontSize: 16, fontWeight: FontWeight.bold, backgroundColor: Colors.white24);
//   var _titleFont = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
//   var _deadlineFont = TextStyle(fontSize: 12);
//   var _detailsFont = TextStyle();
//   var _additionalInformationFont = TextStyle();
//   var _dateAddedFont = TextStyle();
//
//   @override
//   Widget build(BuildContext context) {
//     Vehicle mission = widget.mission;
//
//     return ListTile(
//       leading: Text(
//           mission.getImportance(),
//           style: this._importanceFont,
//       ),
//       title: Text(
//         mission.getTitle(),
//         style: this._titleFont,
//       ),
//       trailing: ElevatedButton(
//         child: Icon(Icons.edit),
//         onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context){
//                   return MissionWidget(
//                     database: widget.database,
//                     missionId: mission.getId(),
//                     addMission: widget.addMission,
//                     editMission: widget.editMission,
//                   );
//                 }
//               ),
//             );
//         },
//       ),
//       onTap: (){
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context){
//               return MissionWidget(
//                 database: widget.database,
//                 missionId: mission.getId(),
//                 addMission: widget.addMission,
//                 editMission: widget.editMission,
//               );
//             },
//           ),
//         );
//       },
//       onLongPress: (){
//         showDialog(
//           context: context,
//           builder: (BuildContext context){
//             return AlertDialog(
//               title: Text(
//                 "Delete this mission?",
//               ),
//               actions: [
//                 FlatButton(
//                   onPressed: (){
//                     widget.deleteMission(mission);
//                     Navigator.of(context).pop();
//                   },
//                   child: Text(
//                     "Delete",
//                   ),
//                 ),
//                 FlatButton(
//                   onPressed: (){
//                     Navigator.of(context).pop();
//                   },
//                   child: Text(
//                     "Close",
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
//
// }