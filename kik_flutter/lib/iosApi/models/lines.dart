import 'package:json_annotation/json_annotation.dart';

part '../../model/Line.g.dart';
@JsonSerializable()
class Line {

  int x;
  int y;
  int z;

  factory Line.fromJson(Map<String, dynamic> json) => _$LineFromJson(json);
  Map<String, dynamic> toJson() => _$LineFromJson(this);

}