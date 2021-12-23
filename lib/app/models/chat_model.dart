import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import "parents/model.dart";
import 'user_model.dart';

class Chat extends Model {
  String id = UniqueKey().toString();

  // message text
  String text;

  // time of the message
  int time;

  // user id who send the message
  String userId;
  bool isOffer;
  User user;

  List customMedia;

  String customDescription;

  String customPrice;

  String customDate;

  Chat(
      {this.text,
      this.time,
      this.userId,
      this.user,
      this.isOffer,
      this.customDescription,
      this.customMedia,
      this.customPrice,
      this.customDate});

  Chat.fromDocumentSnapshot(DocumentSnapshot jsonMap) {
    try {
      id = jsonMap.id;
      text = jsonMap.get('message') != null
          ? jsonMap.get('message').toString()
          : '';
      time = jsonMap.get('time') != null ? jsonMap.get('time') : 0;
      userId =
          jsonMap.get('user') != null ? jsonMap.get('user').toString() : null;
      customPrice = jsonMap.get("custom_price") != null
          ? jsonMap.get("custom_price")
          : null;
      customDescription = jsonMap.get("custom_desc") != null
          ? jsonMap.get("custom_desc")
          : null;
      customMedia = jsonMap.get("custom_media") != null
          ? jsonMap.get("custom_media")
          : null;
      isOffer =
          jsonMap.get("is_offer") != null ? jsonMap.get("is_offer") : null;

      customDate = jsonMap.get("custom_date") != null
          ? jsonMap.get("custom_date")
          : null;
    } catch (e) {
      id = null;
      text = '';
      time = 0;
      user = null;
      userId = null;
      print(e);
    }
  }

  @override
  Map<String, dynamic> toJson() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["message"] = text;
    map["time"] = time;
    map["user"] = userId;
    map["custom_price"] = customPrice;
    map["custom_desc"] = customDescription;
    map["custom_media"] = customMedia;
    map["is_offer"] = isOffer;
    map["custom_date"] = customDate;
    return map;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is Chat &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          text == other.text &&
          time == other.time &&
          userId == other.userId;

  @override
  int get hashCode =>
      super.hashCode ^
      id.hashCode ^
      text.hashCode ^
      time.hashCode ^
      userId.hashCode;
}
