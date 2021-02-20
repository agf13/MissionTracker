//
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:mission_tracker_v2/screens/MissionScreen.dart';
// import 'package:sqflite/sqflite.dart';
//
// class LoginScreen extends StatefulWidget{
//
//   final Future<Database> database;
//
//   LoginScreen({this.database});
//
//   @override
//   State<StatefulWidget> createState() {
//     return _LoginScreenState();
//   }
//
// }
//
// class _LoginScreenState extends State<LoginScreen>{
//   final _formKey = GlobalKey<FormState>();
//
//   TextEditingController userInputController;
//   TextEditingController passInputController;
//
//   @override
//   void initState(){
//     this.userInputController = new TextEditingController(text: "");
//     this.passInputController = new TextEditingController(text: "");
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "Login Screen",
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Form(
//           key: this._formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 decoration: InputDecoration(
//                   labelText: "User",
//                 ),
//                 controller: this.userInputController,
//                 validator: (value){
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 decoration: InputDecoration(
//                   labelText: "Pass",
//                 ),
//                 controller: this.passInputController,
//                 validator: (value){
//                   return null;
//                 },
//               ),
//               ElevatedButton(
//                 child: Text(
//                   "Login",
//                 ),
//                 onPressed: (){
//                   if(this._formKey.currentState.validate()){
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) {
//                           return MissionScreen(database: widget.database);
//                         },
//                       ),
//                     );
//                   }
//                 },
//               ),
//             ],
//           ),
//
//         ),
//       ),
//     );
//   }
//
// }