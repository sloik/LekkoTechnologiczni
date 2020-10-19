
import 'package:json_annotation/json_annotation.dart';

part '../../model/Symbol.g.dart';
@JsonSerializable()
class Symbol {
  String x;
  String y;
  String none;

  factory Symbol.fromJson(Map<String, dynamic> json) => _$SymbolFromJson(json);
  Map<String, dynamic> toJson() => _$SymbolFromJson(this);
}