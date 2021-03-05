import 'package:flutter/material.dart';

final textInputDecoration = InputDecoration(
    fillColor: Colors.white,
    filled: true,
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(45),
        borderSide: BorderSide(color: Colors.blueAccent, width: 2)
    ),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(45),
        borderSide: BorderSide(color: Colors.pink, width: 2)
    ),
    focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(45),
        borderSide: BorderSide(color: Colors.pink, width: 2),
    )
);

