import 'dart:convert';
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:path_provider/path_provider.dart';

part 'assessment.g.dart';

@JsonSerializable()
class Assessment {
  final List<int> questions;
  final bool isDyslexic;
  int dyslexiaScore;

  Assessment(this.questions, this.isDyslexic, this.dyslexiaScore);

  factory Assessment.fromJson(Map<String, dynamic> json) =>
      _$AssessmentFromJson(json);
  Map<String, dynamic> toJson() => _$AssessmentToJson(this);
}

// Function to update the value of the first question in the JSON file
Future<void> updateDyslexiaScore(int questionNumber, int newValue) async {
  final directory = await getApplicationDocumentsDirectory();
  final path = directory.path;
  final file = File('$path/assessment_data.json');

  final jsonString = await file.readAsString();
  final assessment = Assessment.fromJson(json.decode(jsonString));
  assessment.questions[questionNumber - 1] = newValue;
  final updatedJsonString = json.encode(assessment.toJson());
  await file.writeAsString(updatedJsonString);
}
