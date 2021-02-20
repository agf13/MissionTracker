import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Vehicle {
  int id = -1;

  String license;
  String status;

  int seats;
  int cargo;

  String driver;
  String color;

  Vehicle({this.id=-1, this.license, this.color, this.status ,this.seats, this.cargo, this.driver});

  void setAll(String newLicense, String newStatus, int newSeats, String newDriver, String newColor, int newCargo){
    setLicense(newLicense);
    setStatus(newStatus);
    setSeats(newSeats);
    setDriver(newDriver);
    setColor(newColor);
    setCargo(newCargo);
  }


  //<id>
  int getId(){ return this.id; }
  void setId(int id){
    //only set the id once
    if(this.id < 0) {
      if(id == null){
        this.id = -1;
        print("setID::Passed a null missionId");
      }
      else {
        this.id = id;
      }
    }
  }

  String getStatus(){return this.status;}
  void setStatus(String newStatus){
    if(newStatus!=null){
      this.license = newStatus;
    }
    else{
      this.license = getDefaultStatus();
    }
  }


  String getLicense(){return this.license;}
  void setLicense(String newLicense){
    if(newLicense!=null){
      this.license = newLicense;
    }
    else{
      this.license = getDefaultLicense();
    }
  }


  int getSeats(){return this.seats;}
  void setSeats(int newSeats){
    if(newSeats!=null){
      this.seats = newSeats;
    }
    else{
      this.seats = getDefaultSeats();
    }
  }


  int getCargo(){return this.cargo;}
  void setCargo(int newCargo){
    if(newCargo!=null){
      this.cargo = newCargo;
    }
    else{
      this.cargo = getDefaultCargo();
    }
  }


  String getDriver(){return this.driver;}
  void setDriver(String newDriver){
    if(newDriver!=null){
      this.driver = newDriver;
    }
    else{
      this.driver = getDefaultDriver();
    }
  }



  String getColor(){return this.color;}
  void setColor(String newColor){
    if(newColor!=null){
      this.color = newColor;
    }
    else{
      this.color = getDefaultColor();
    }
  }






  //<defaultValues>
  String getDefaultLicense(){ return "(none)";}
  String getDefaultStatus(){ return "(none)";}
  int getDefaultSeats(){ return 0; }
  String getDefaultDriver(){ return "(none)"; }
  String getDefaultColor(){ return "(none)"; }
  int getDefaultCargo(){ return 0; }


  //<utilsFunction>
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'license': license,
      'status': status,
      'seats': seats,
      'driver': driver,
      'color': color,
      'cargo': cargo,
    };
  }


  factory Vehicle.fromJson(Map<dynamic, dynamic> json) {
    return Vehicle(
      id: json['id'],
      license: json['license'],
      status: json['status'],
      seats: json['seats'],
      driver: json['driver'],
      color: json['color'],
      cargo: json['cargo'],
    );
  }

  @override
  bool operator == (Object other){
    if(identical(this, other))
      return true;
    else if(other is Vehicle){
      if(this.runtimeType == other.runtimeType &&
          this.license == other.getLicense() &&
          this.driver == other.getDriver() &&
          this.status == other.getStatus() &&
          this.seats == other.getSeats() &&
          this.cargo == other.getCargo() &&
          this.color == other.getColor()){
        return true;
      }
      return false;
    }
    return false;
  }

  @override
  int get hashCode {
    return this.license.hashCode ^
    this.status.hashCode ^
    this.driver.hashCode ^
    this.color.hashCode ^
    this.seats.hashCode ^
    this.cargo.hashCode;
  }

  @override
  String toString() {
    return 'Vehicle{id: $id, license: $license, seats: $seats, driver: $driver}';
  }


}
