import 'package:flutter/foundation.dart';

class UberItem {
  final String listId;
  final String userId;
  late final String anotherUserId;
  late final bool reserved;
  final String startingLocation;
  final String destination;
  final DateTime selectedDateTime;
  final bool wantToFindRide;
  final bool wantToOfferRide;
  final String notes;
  final int pay;

  UberItem({
    required this.listId,
    required this.userId,
    required this.anotherUserId,
    required this.reserved,
    required this.startingLocation,
    required this.destination,
    required this.selectedDateTime,
    required this.wantToFindRide,
    required this.wantToOfferRide,
    required this.notes,
    required this.pay
  });

  factory UberItem.fromJson(Map<String, dynamic> json) {
    return UberItem(
      listId: json['_id'],
      userId: json['userId'],
      anotherUserId: json['anotherUserId'],
      reserved: json['reserved'],
      startingLocation: json['startingLocation'],
      destination: json['destination'],
      selectedDateTime: DateTime.parse(json['selectedDateTime']),
      wantToFindRide: json['wantToFindRide'],
      wantToOfferRide: json['wantToOfferRide'],
      notes: json['notes'],
      pay: json['pay']
    );
  }
}

class UberListProvider extends ChangeNotifier {
  List<UberItem> _uberList = [];

  void setList(List<UberItem> newList) {
    _uberList = newList;
    notifyListeners();
  }

  List<UberItem> get uberList => _uberList;

}
