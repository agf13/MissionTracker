

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mission_tracker_v2/entities/Mission.dart';
import 'package:mission_tracker_v2/entities/Vehicle.dart';
import 'package:sqflite/sqflite.dart';

class VehicleWidget extends StatefulWidget{
  VehicleWidget({Key key,this.database, this.id, this.addVehicle, this.editVehicle}) : super(key: key);

  final Future<Database> database;

  final int id;

  final Function addVehicle;
  final Function editVehicle;

  @override
  State<StatefulWidget> createState() {
    return _VehicleWidgetState();
  }

}

class _VehicleWidgetState extends State<VehicleWidget>{

  final _vehicleFormKey = GlobalKey<FormState>();

  TextEditingController _licenseInputController;
  TextEditingController _statusInputController;
  TextEditingController _seatsInputController;
  TextEditingController _driverInputController;

  TextEditingController _colorInputController;
  TextEditingController _cargoInputController;

  @override
  void initState(){
    super.initState();
    if(widget.id != null && widget.id != -1){
      getVehicle().then((vehicle) => {
        this._licenseInputController.text = vehicle?.getLicense(),
        this._statusInputController.text = vehicle?.getStatus(),
        this._seatsInputController.text = vehicle?.getSeats().toString(),
        this._driverInputController.text = vehicle?.getDriver(),
        this._colorInputController.text = vehicle?.getColor(),
        this._cargoInputController.text = vehicle?.getCargo().toString(),

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    this._licenseInputController = TextEditingController(text: "");
    this._statusInputController = TextEditingController(text: "");
    this._seatsInputController = TextEditingController(text: "");
    this._driverInputController = TextEditingController(text: "");

    this._cargoInputController = TextEditingController(text: "");
    this._seatsInputController = TextEditingController(text: "");
    this._colorInputController = TextEditingController(text: "");

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Vehicle Details",
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: this._vehicleFormKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: "License",
                ),
                controller: this._licenseInputController,
                validator: (value) {
                  if(value.isEmpty){
                    return "Insert a license";
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Status",
                ),
                controller: this._statusInputController,
                validator: (value) {
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Seats",
                ),
                controller: this._seatsInputController,
                validator: (value){
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Driver",
                ),
                controller: this._driverInputController,
                validator: (value){
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Color",
                ),
                controller: this._colorInputController,
                validator: (value){
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Cargo",
                ),
                controller: this._cargoInputController,
                validator: (value){
                  return null;
                },
              ),
              ElevatedButton(
                child: Text(
                  "Save",
                ),
                onPressed: (){
                  if(_vehicleFormKey.currentState.validate()){
                    Vehicle vehicle_fromForm = Vehicle();
                    vehicle_fromForm.setAll(
                      this._licenseInputController.text,
                      this._statusInputController.text,
                      int.parse(this._seatsInputController.text),
                      this._driverInputController.text,
                      this._colorInputController.text,
                      int.parse(this._cargoInputController.text)
                    );
                    if(widget.id != null && widget.id != -1){
                      vehicle_fromForm.setId(widget.id);
                      widget.editVehicle(vehicle_fromForm);
                    }
                    else{
                      widget.addVehicle(vehicle_fromForm);
                    }
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }



  Future<Vehicle> getVehicle() async{
    final Database db = await widget.database;

    final List<Map<String, dynamic>> vehicle_asMap = await db.query(
      "Vehicles",
      where: "id = ?",
      whereArgs: [widget.id],
    );

    if(vehicle_asMap.length == 0)
      return null;


    Vehicle vehicle = new Vehicle();
    vehicle.setId(vehicle_asMap[0]["id"]);
    vehicle.setAll(
      vehicle_asMap[0]["license"],
      vehicle_asMap[0]["status"],
      (vehicle_asMap[0]["seats"]),
      vehicle_asMap[0]["driver"],
      vehicle_asMap[0]["color"],
      (vehicle_asMap[0]["cargo"]),
    );

    return vehicle;
  }

}