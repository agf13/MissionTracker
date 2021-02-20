

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mission_tracker_v2/entities/Mission.dart';
import 'package:mission_tracker_v2/entities/Vehicle.dart';
import 'package:mission_tracker_v2/widgets/MissionWidget.dart';
import 'package:mission_tracker_v2/widgets/VehicleWidget.dart';
import 'package:sqflite/sqflite.dart';

class VehicleItemWidget extends StatefulWidget{
  Vehicle vehicle;

  Function editVehicle;
  Function addVehicle;
  Function deleteVehicle;
  Future<Database> database;


  VehicleItemWidget({this.vehicle, this.database, this.addVehicle, this.editVehicle, this.deleteVehicle});

  @override
  State<StatefulWidget> createState() {
    return _VehicleItemWidgetState();
  }

}

class _VehicleItemWidgetState extends State<VehicleItemWidget>{

  var _licenseFont = TextStyle(fontSize: 16, fontWeight: FontWeight.bold, backgroundColor: Colors.white24);
  var _driverFont = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  var _deadlineFont = TextStyle(fontSize: 12);
  var _detailsFont = TextStyle();
  var _additionalInformationFont = TextStyle();
  var _dateAddedFont = TextStyle();

  @override
  Widget build(BuildContext context) {
    Vehicle vehicle = widget.vehicle;

    return ListTile(
      leading: Text(
        vehicle.getLicense(),
        style: this._licenseFont,
      ),
      title: Text(
        vehicle.getDriver(),
        style: this._driverFont,
      ),
      trailing: ElevatedButton(
        child: Icon(Icons.edit),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context){
                  return VehicleWidget(
                    database: widget.database,
                    id: vehicle.getId(),
                    addVehicle: widget.addVehicle,
                    editVehicle: widget.editVehicle,
                  );
                }
            ),
          );
        },
      ),
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context){
              return VehicleWidget(
                database: widget.database,
                id: vehicle.getId(),
                addVehicle: widget.addVehicle,
                editVehicle: widget.editVehicle,
              );
            },
          ),
        );
      },
      onLongPress: (){
        showDialog(
          context: context,
          builder: (BuildContext context){
            return AlertDialog(
              title: Text(
                "Delete this vehicle?",
              ),
              actions: [
                FlatButton(
                  onPressed: (){
                    widget.deleteVehicle(vehicle);
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Delete",
                  ),
                ),
                FlatButton(
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Close",
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

}