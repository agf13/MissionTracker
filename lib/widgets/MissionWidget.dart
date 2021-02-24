//
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:mission_tracker_v2/entities/Mission.dart';
// import 'package:sqflite/sqflite.dart';
//
// class MissionWidget extends StatefulWidget{
//   MissionWidget({Key key,this.database, this.missionId, this.addMission, this.editMission}) : super(key: key);
//
//   final Future<Database> database;
//
//   final int missionId;
//
//   final Function addMission;
//   final Function editMission;
//
//   @override
//   State<StatefulWidget> createState() {
//     return _MissionWidgetState();
//   }
//
// }
//
// class _MissionWidgetState extends State<MissionWidget>{
//
//   final _missionFormKey = GlobalKey<FormState>();
//
//   TextEditingController _titleInputController;
//   TextEditingController _importanceInputController;
//   TextEditingController _detailsInputController;
//   TextEditingController _additionalInformationInputController;
//
//   @override
//   void initState(){
//     super.initState();
//     if(widget.missionId != null && widget.missionId != -1){
//       getMission().then((mission) => {
//           this._titleInputController.text = mission?.getTitle(),
//         this._importanceInputController.text = mission?.getImportance(),
//         this._detailsInputController.text = mission?.getDetails(),
//         this._additionalInformationInputController.text = mission?.getAdditionalInformation(),
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     this._titleInputController = TextEditingController(text: "");
//     this._importanceInputController = TextEditingController(text: "");
//     this._detailsInputController = TextEditingController(text: "");
//     this._additionalInformationInputController = TextEditingController(text: "");
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "Mission Details",
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Form(
//           key: this._missionFormKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 decoration: InputDecoration(
//                   labelText: "Title",
//                 ),
//                 controller: this._titleInputController,
//                 validator: (value) {
//                   if(value.isEmpty){
//                     return "Please let the agent know";
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 decoration: InputDecoration(
//                   labelText: "Importance",
//                 ),
//                 controller: this._importanceInputController,
//                 validator: (value) {
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 decoration: InputDecoration(
//                   labelText: "Details",
//                 ),
//                 controller: this._detailsInputController,
//                 validator: (value){
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 decoration: InputDecoration(
//                   labelText: "Additional information:",
//                 ),
//                 controller: this._additionalInformationInputController,
//                 validator: (value){
//                   return null;
//                 },
//               ),
//               ElevatedButton(
//                 child: Text(
//                   "Save",
//                 ),
//                 onPressed: (){
//                   if(_missionFormKey.currentState.validate()){
//                     Vehicle mission_fromForm = Vehicle();
//                     mission_fromForm.setAll(
//                       this._titleInputController.text,
//                       this._importanceInputController.text,
//                       this._detailsInputController.text,
//                       this._additionalInformationInputController.text,
//                     );
//                     if(widget.missionId != null && widget.missionId != -1){
//                       mission_fromForm.setId(widget.missionId);
//                       widget.editMission(mission_fromForm);
//                     }
//                     else{
//                       widget.addMission(mission_fromForm);
//                     }
//                     Navigator.of(context).pop();
//                   }
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//
//
//   Future<Vehicle> getMission() async{
//     final Database db = await widget.database;
//
//     final List<Map<String, dynamic>> mission_asMap = await db.query(
//       "Missions",
//       where: "missionId = ?",
//       whereArgs: [widget.missionId],
//     );
//
//     if(mission_asMap.length == 0)
//       return null;
//
//     Vehicle mission = new Vehicle();
//     mission.setId(mission_asMap[0]["missionId"]);
//     mission.setAll(
//       mission_asMap[0]["title"],
//       mission_asMap[0]["importance"],
//       mission_asMap[0]["details"],
//       mission_asMap[0]["additionalInformation"],
//     );
//
//     return mission;
//   }
//
// }