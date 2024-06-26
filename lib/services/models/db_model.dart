import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:xmonapp/services/constants.dart';

// user table
@immutable
class CardioUser {
  final int? id;
  final String email;

  const CardioUser({
    this.id,
    required this.email,
  });

  CardioUser copyWith({int? id, String? email}) {
    return CardioUser(
      id: id ?? this.id,
      email: email ?? this.email,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      idColumn: id,
      emailColumn: email,
    };
  }

  CardioUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person: ID = $id, email = $email';

  @override
  bool operator ==(covariant CardioUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// signal abstract model
abstract class Signal {
  final int? id;
  final int userId;
  String? signalName;
  final int? signalId;
  final DateTime startTime;
  DateTime stopTime;
  final String signalType;

  Signal({
    this.id,
    this.signalName,
    this.signalId,
    required this.userId,
    required this.startTime,
    required this.stopTime,
    required this.signalType,
  });

  String get name =>
      signalName ??
      '$signalType ${stopTime.day}-${stopTime.month}-${stopTime.year} ${stopTime.hour}:${stopTime.minute}';

  set name(String newName) {
    signalName = newName;
  }

  set stoptime(DateTime time) {
    stopTime = time;
  }

  Signal.fromRow(Map<String, Object?> map) // from database to application
      : id = map[idColumn] as int,
        signalId = map[signalIdColumn] as int,
        signalName = map[nameColumn] as String,
        userId = map[userIdColumn] as int,
        startTime = map[startTimeColumn] as DateTime,
        stopTime = map[stopTimeColumn] as DateTime,
        signalType = map[signalTypeColumn] as String;

  Map<String, dynamic> toMap() {
    // from application to database
    return {
      idColumn: id,
      signalIdColumn: signalId,
      userIdColumn: userId,
      nameColumn: signalName,
      startTimeColumn: startTime.toIso8601String(),
      stopTimeColumn: stopTime.toIso8601String(),
      signalTypeColumn: signalType,
    };
  }

  @override
  String toString() =>
      'Signal: ID = $id, SN:$signalName, userID = $userId, type = $signalType';

  @override
  bool operator ==(covariant Signal other) {
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}

// ECG table
class EcgModel extends Signal {
  static const String tableName = ecgTable;
  static const String sType = 'ECG';
  String description = 'ECG Signal';
  late Uint8List? ecg = Uint8List(0);

  EcgModel({
    super.id,
    super.signalName,
    super.signalId,
    required super.userId,
    required super.startTime,
    required super.stopTime,
    this.ecg,
  }) : super(signalType: sType);

  // set ecg
  void setEcg(List<int> data) {
    ecg = Uint8List.fromList(data);
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['ecg'] = ecg;
    return map;
  }

  factory EcgModel.fromMap(Map<String, dynamic> map) {
    return EcgModel(
      id: map[idColumn],
      userId: map[userIdColumn],
      signalName: map[nameColumn],
      signalId: map[signalIdColumn],
      startTime: DateTime.parse(map[startTimeColumn]),
      stopTime: DateTime.parse(map[stopTimeColumn]),
      ecg: map['ecg'],
    );
  }
}

// BP table
class BpModel extends Signal {
  static const String tableName = bpTable;
  static const String sType = 'BP';
  String description = 'Blood Pressure Signal';

  late int bpSystolic;
  late int bpDiastolic;

  BpModel({
    super.id,
    super.signalName,
    super.signalId,
    required super.userId,
    required super.startTime,
    required super.stopTime,
    required this.bpSystolic,
    required this.bpDiastolic,
  }) : super(signalType: sType);

  void setBp({required int systolic, required int diastolic}) {
    bpSystolic = systolic;
    bpDiastolic = diastolic;
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['bp_systolic'] = bpSystolic;
    map['bp_diastolic'] = bpDiastolic;
    return map;
  }

  factory BpModel.fromMap(Map<String, dynamic> map) {
    try {
      return BpModel(
        id: map[idColumn],
        userId: map[userIdColumn],
        signalId: map[signalIdColumn],
        signalName: map[nameColumn],
        startTime: DateTime.parse(map[startTimeColumn]),
        stopTime: DateTime.parse(map[stopTimeColumn]),
        bpSystolic: map['bp_systolic'],
        bpDiastolic: map['bp_diastolic'],
      );
    } catch (e) {
      log('$e \n$map');
      rethrow;
    }
  }
}

// body temperature table
class BtempModel extends Signal {
  static const String tableName = btempTable;
  static const String sType = 'BTEMP';
  String description = 'Body Temperature Signal';

  double bodyTemp;

  BtempModel({
    super.id,
    super.signalName,
    super.signalId,
    required super.userId,
    required super.startTime,
    required super.stopTime,
    required this.bodyTemp,
  }) : super(signalType: sType);

  void setBodyTemp(double temp) {
    bodyTemp = temp;
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['body_temp'] = bodyTemp;
    return map;
  }

  factory BtempModel.fromMap(Map<String, dynamic> map) {
    return BtempModel(
      id: map[idColumn],
      userId: map[userIdColumn],
      signalId: map[signalIdColumn],
      signalName: map[nameColumn],
      startTime: DateTime.parse(map[startTimeColumn]),
      stopTime: DateTime.parse(map[stopTimeColumn]),
      bodyTemp: map['body_temp'],
    );
  }
}
