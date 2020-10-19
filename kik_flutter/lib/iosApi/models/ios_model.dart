import 'package:json_annotation/json_annotation.dart';
import 'package:kik_flutter/iosApi/models/lines.dart';

part '../../model/IosModel.g.dart';

@JsonSerializable()
class IosModel {

   String currentSymbol;
   List<Line> lines;
   List<Symbol> gameState;

   IosModel(this.currentSymbol, this.lines, this.gameState);

   factory IosModel.fromJson(Map<String, dynamic> json) => _$IosModelFromJson(json);
   Map<String, dynamic> toJson() => _$IosModelFromJson(this);

}