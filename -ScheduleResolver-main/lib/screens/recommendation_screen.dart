import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_schedule_service.dart';

class RecommendationScreen extends StatelessWidget {
  const RecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final aiService = Provider.of<AiScheduleService>(context);
    final analysis = aiService.currentAnalysis;

    if (analysis == null) {
      return const Scaffold(body: Center(child: Text('No Data')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('AI Schedule Recommendation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context, 
              'Detected Conflicts', 
              analysis.conflicts, 
              Colors.red.shade100, 
              Icons.warning_amber_rounded,
              textColor: Colors.black
            ),
            _buildSection(
              context, 
              'Ranked Tasks', 
              analysis.rankedTasks, 
              const Color.fromARGB(255, 4, 4, 126), 
              Icons.format_list_numbered,
              textColor: Colors.white
            ),
            _buildSection(
              context, 
              'Recommended Schedule', 
              analysis.recommendedSchedule, 
              const Color.fromARGB(255, 4, 126, 8), 
              Icons.calendar_today,
              textColor: Colors.white
            ),
            _buildSection(
              context, 
              'Explanation', 
              analysis.explanation, 
              const Color.fromARGB(255, 169, 69, 8), 
              Icons.lightbulb_outline,
              textColor: Colors.white
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, 
    String title, 
    String content, 
    Color bgColor, 
    IconData icon,
    {Color textColor = Colors.black}
  ) {
    return Card(
      color: bgColor,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 28, color: textColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title, 
                    style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold,
                      color: textColor
                    )
                  ),
                ),
              ],
            ),
            const Divider(),
            Text(
              content, 
              style: TextStyle(
                fontSize: 16, 
                height: 1.5,
                color: textColor
              )
            ),
          ],
        ),
      ),
    );
  }
}
