import 'package:flutter/material.dart';

@immutable
class Message {
  final String message;
  final DateTime createAt;

  const Message({
    @required this.message,
    this.createAt,
  });
}