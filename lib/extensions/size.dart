import 'package:flutter/material.dart';

extension SizeSerializer on Size {
  Map<String, dynamic> toJson() => {
        'width': width,
        'height': height,
      };

  static Size fromJson(Map<String, dynamic> json) => Size(
        json['width'] as double? ?? double.infinity,
        json['height'] as double,
      );
}
