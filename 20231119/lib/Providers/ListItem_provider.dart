import 'package:flutter/material.dart';

class ListItemProvider extends ChangeNotifier{
  String listId = '';
  String userId = '';
  String anotherUserId = '';
  bool reserved = false;
  String startingLocation = '';
  String destination = '';
  DateTime selectedDateTime = DateTime.now();
  bool wantToFindRide = false;
  bool wantToOfferRide = false;
  String notes = '';
  int pay = 0;

  //點擊卡片時使用
  void setList(String newListId, String newUserId, String newAnotherUserId, bool newReserved,
      String newStartingLocation,String newDestination, DateTime newSelectedDateTime, bool newWantToFindRide,
      bool newWantToOfferRide, String newNotes, int newPay) {
    listId = newListId;
    userId = newUserId;
    anotherUserId = newAnotherUserId;
    reserved = newReserved;
    startingLocation = newStartingLocation;
    destination = newDestination;
    selectedDateTime = newSelectedDateTime;
    wantToFindRide = newWantToFindRide;
    wantToOfferRide = newWantToOfferRide;
    notes = newNotes;
    pay = newPay;
    //notifyListeners();
  }

  //預約行程
  void setReserved(String newAnotherUserId, bool newReserved){
    anotherUserId = newAnotherUserId;
    reserved = newReserved;
    notifyListeners();
  }
  void cancelReserved(){
    anotherUserId = '';
    reserved = false;
    notifyListeners();
  }
}