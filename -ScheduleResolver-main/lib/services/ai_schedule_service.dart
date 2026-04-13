import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/task_model.dart';
import '../models/schedule_analysis.dart';
import 'dart:convert';


class AiScheduleService extends ChangeNotifier{

  ScheduleAnalysis? _currentAnalysis;
  bool _isloading = false;
  String? _errorMessage;

  final String _apikey = "";

  ScheduleAnalysis? get currentAnalysis => _currentAnalysis;
  bool get isloading => _isloading;
  String? get errorMessage => _errorMessage;

  Future<void> analyzeSchedule(List<TaskModel> tasks) async {
    _errorMessage = null;
    if(_apikey.isEmpty) {
      _errorMessage = "API Key is missing. Please add your Gemini API key in ai_schedule_service.dart";
      notifyListeners();
      return;
    }
    if(tasks.isEmpty) {
      _errorMessage = "No tasks to analyze.";
      notifyListeners();
      return;
    }

    _isloading = true;
    notifyListeners();

    try {
      final ai = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apikey);
      final taskJson = jsonEncode(tasks.map((task) => task.toJson()).toList());

      final prompt = '''
      
      You are an expert student scheduling assistant. The user has provider the following task for their day in JSON format:
      
      $taskJson
      
      Please provide exactly 4 sections of markdown text:
      1. ### Detected Conflicts
      List any scheduling conflicts or state that there are none.
      2. ### Ranked Tasks
      Ranks which tasks needed attention first.
      3. ### Recommended Schedule
      Provide a revise dailu timeline view adjusting the task times
      4. ### Explanation
      Explain why this recommendation was made.
    ''';
      final content = [Content.text(prompt)];
      final response = await ai.generateContent(content);

      _currentAnalysis = _parseResponse(response.text ?? '');

    } catch (e) {

      _errorMessage = e.toString();

    } finally {
      _isloading = false;
      notifyListeners();
    }
  }

  ScheduleAnalysis _parseResponse(String fullText) {
    String conflicts = '',
        rankedTasks = '',
        recommendedSchedule = '',
        explanation = '';

    final sections = fullText.split('###');
    for (var section in sections) {
      if (section.startsWith('Detected Conflicts')) {
        conflicts = section.replaceFirst('Detected Conflicts', '').trim();
      } else if (section.startsWith('Ranked Tasks')) {
        rankedTasks = section.replaceFirst('Ranked Tasks', '').trim();
      } else if (section.startsWith('Recommended Schedule')) {
        recommendedSchedule = section.replaceFirst('Recommended Schedule', '').trim();
      } else if (section.startsWith('Explanation')) {
        explanation = section.replaceFirst('Explanation', '').trim();
      }
    }

    return ScheduleAnalysis(
      conflicts: conflicts,
      rankedTasks: rankedTasks,
      recommendedSchedule: recommendedSchedule,
      explanation: explanation,
    );
  }
}