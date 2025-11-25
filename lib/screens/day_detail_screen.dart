import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/day_model.dart';
import '../services/firestore_service.dart';
import '../widgets/charts_panel.dart';

class DayDetailScreen extends StatefulWidget {
  final String userId;
  final String weekId;

  const DayDetailScreen(
      {super.key, required this.userId, required this.weekId});

  @override
  State<DayDetailScreen> createState() => _DayDetailScreenState();
}

class _DayDetailScreenState extends State<DayDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  Future<List<Day>>? _daysFuture;
  int _selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDays();
  }

  void _loadDays() {
    setState(() {
      _daysFuture = _firestoreService.getDays(widget.userId, widget.weekId);
    });
  }

  DateTime _parseDateFromId(String dayId) {
    final parsableId = dayId.replaceAll('_', '-').replaceAll(' ', '-');
    try {
      return DateFormat('yyyy-MM-dd').parse(parsableId);
    } catch (e) {
      return DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(widget.weekId.replaceAll('_', ' '),
            style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E1E1E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Day>>(
        future: _daysFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.white));
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No tasks found for this week.',
                    style: TextStyle(color: Colors.white)));
          }

          final days = snapshot.data!;
          days.sort((a, b) =>
              _parseDateFromId(a.id).compareTo(_parseDateFromId(b.id)));
          final selectedDay = days[_selectedDayIndex];

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 110,
                child: ListView.builder(
                  itemCount: days.length,
                  itemBuilder: (context, index) {
                    final day = days[index];
                    final date = _parseDateFromId(day.id);
                    final isSelected = index == _selectedDayIndex;
                    return Material(
                      color: isSelected
                          ? Colors.deepPurpleAccent.withOpacity(0.2)
                          : Colors.transparent,
                      child: InkWell(
                        onTap: () => setState(() => _selectedDayIndex = index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 24),
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: isSelected
                                    ? Colors.deepPurpleAccent
                                    : Colors.transparent,
                                width: 4,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('EEE').format(date),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('MMM d').format(date),
                                style: TextStyle(
                                    color: Colors.grey[400], fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const VerticalDivider(
                  width: 1, thickness: 1, color: Color(0xFF2A2A2A)),
              Expanded(
                child: LayoutBuilder(builder: (context, constraints) {
                  const double taskListWidth = 500.0;
                  final double chartPanelWidth =
                      max(400.0, constraints.maxWidth - taskListWidth);
                  final double totalContentWidth = taskListWidth + chartPanelWidth;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: totalContentWidth,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: taskListWidth,
                            child: ListView(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 16),
                              children: [
                                Text(
                                  DateFormat('EEEE, MMMM d').format(
                                      _parseDateFromId(selectedDay.id)),
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                const SizedBox(height: 24),
                                if (selectedDay.segments.isEmpty)
                                  const Center(
                                      child: Padding(
                                          padding: EdgeInsets.only(top: 40),
                                          child: Text('No tasks for this day.',
                                              style: TextStyle(
                                                  color: Colors.grey))))
                                else
                                  ...selectedDay.segments.map((task) =>
                                      _buildTaskEditor(task, selectedDay.id)),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: chartPanelWidth,
                            child: ChartsPanel(tasks: selectedDay.segments),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTaskEditor(Task task, String dayId) {
    final TextEditingController controller = TextEditingController();
    final ValueNotifier<double> currentActual =
        ValueNotifier<double>(task.actual);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.subcategory,
            style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            task.activity,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            '${task.start} - ${task.end}',
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<double>(
            valueListenable: currentActual,
            builder: (context, actualValue, child) {
              if (actualValue >= task.planned) {
                return Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Completed! (${actualValue.toStringAsFixed(1)} / ${task.planned.toStringAsFixed(1)} hrs)',
                      style: const TextStyle(
                          color: Colors.green,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Progress: ${actualValue.toStringAsFixed(1)} / ${task.planned.toStringAsFixed(1)} hrs',
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 40,
                      child: TextField(
                        controller: controller,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: 'Add',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          filled: true,
                          fillColor: Colors.grey[800],
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      minimumSize: const Size(0, 40),
                    ),
                    onPressed: () async {
                      final additionalHours = double.tryParse(controller.text);
                      if (additionalHours == null || additionalHours <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Please enter a valid positive number.'),
                              backgroundColor: Colors.orange),
                        );
                        return;
                      }

                      try {
                        await _firestoreService.updateTaskActual(
                            widget.userId,
                            widget.weekId,
                            dayId,
                            task.id,
                            additionalHours,
                            task.planned);
                        currentActual.value += additionalHours;
                        controller.clear();

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Progress updated!'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 1)),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
                    child: const Icon(Icons.add, size: 20),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
