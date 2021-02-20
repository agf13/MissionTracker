import 'dart:core';

import 'package:flutter/material.dart';

class Mission {
  int _missionId = -1;

  String _title;
  String _importance;

  String _details;
  String _additionalInformation;

  Mission({missionId, title, importance, details, additionalInformation}){
    // this._missionId = -1;
    setId(missionId);
    setTitle(title);
    setImportance(importance);
    setDetails(details);
    setAdditionalInformation(additionalInformation);
  }


  void setAll(String title, String importance, String details, String additionalInformation){
    setTitle(title);
    setImportance(importance);
    setDetails(details);
    setAdditionalInformation(additionalInformation);
  }


  //<id>
  int getId(){ return this._missionId; }
  void setId(int id){
    //only set the id once
    if(this._missionId < 0) {
      if(id == null){
        this._missionId = -1;
        print("setID::Passed a null missionId");
      }
      else {
        this._missionId = id;
      }
    }
  }

  //<title>
  String getTitle(){ return this._title; }
  void setTitle(String title){
    if(this._title == null)
      this._title = getDefaultTile();
    this._title = title;
  }

  String getImportance(){ return this._importance; }
  void setImportance(String importance) {
    if(this._importance == null)
      this._importance= getDefaultImportance();
    this._importance = importance;
  }

  //<details>
  String getDetails(){ return this._details; }
  void setDetails(String details){
    if(this._details == null)
      this._details = getDefaultDetails();
    this._details = details;
  }

  //<additionalInformation>
  String getAdditionalInformation() { return this._additionalInformation; }
  void setAdditionalInformation(String additionalInformation) {
    if(this._additionalInformation == null)
      this._additionalInformation = getDefaultAdditionalInformation();
    this._additionalInformation = additionalInformation;
  }




  //<defaultValues>
  String getDefaultTile(){ return "(no title)";}
  String getDefaultImportance(){ return "(none)";}
  String getDefaultDeadline(){ return "(no date given)"; }
  String getDefaultDetails(){ return "(no details)"; }
  String getDefaultAdditionalInformation(){ return "(no additional information)"; }
  String getDefaultDateAdded(){ return "(no date given)"; }
  String getDefaultDate() { return "(no date given)"; }


  //<utilsFunction>
  Map<String, dynamic> toMap() {
    return {
      'missionId': _missionId,
      'title': _title,
      'importance': _importance,
      'details': _details,
      'additionalInformation': _additionalInformation,
    };
  }


  factory Mission.fromJson(Map<dynamic, dynamic> json) {
    return Mission(
      missionId: json['missionId'],
      title: json['title'],
      importance: json['importance'],
      details: json['details'],
      additionalInformation: json['additionalInformation'],
    );
  }

  @override
  bool operator == (Object other){
    if(identical(this, other))
      return true;
    else if(other is Mission){
      if(this.runtimeType == other.runtimeType &&
          this._title == other.getTitle() &&
          this._details == other.getDetails() &&
          this._importance == other.getImportance() &&
          this._additionalInformation == other.getAdditionalInformation()){
        return true;
      }
      return false;
    }
    return false;
  }

  @override
  int get hashCode {
    return this._title.hashCode ^
          this._importance.hashCode ^
          this._details.hashCode ^
          this._additionalInformation.hashCode;
  }

  @override
  String toString(){
    return "Id: $_missionId : Title: $_title (importance: $_importance)";
  }
}
