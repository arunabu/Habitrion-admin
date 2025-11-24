import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/day_model.dart';
import '../services/firestore_service.dart';

class DayDetailScreen extends StatefulWidget {
  final String userId;
  final String weekId;

  const DayDetailScreen({super.key, required this.userId, required this.weekId});

  @override
  State<DayDetailScreen> createState() => _DayDetailScreenState();
}

class _DayDetailScreenState extends State<DayDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Day>? _days;
  bool _isLoading = true;
  String? _error;
  int _selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDays();
  }

  Future<void> _loadDays() async {
    try {
      final days = await _firestoreService.getDays(widget.userId, widget.weekId);
      if (mounted) {
        setState(() {
          _days = days..sort((a, b) => a.date.compareTo(b.date));
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load daily tasks: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Week ${widget.weekId.replaceAll('-', ' ')}',
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _days == null || _days!.isEmpty
                  ? const Center(child: Text('No tasks found for this week.', style: TextStyle(color: Colors.white)))
                  : Row(
                      children: [
                        _buildNavigationRail(),
                        _buildContentArea(),
                      ],
                    ),
    );
  }

  Widget _buildNavigationRail() {
    return Container(
      width: 80,
      color: const Color(0xFF121212),
      child: ListView.builder(
        itemCount: _days!.length,
        itemBuilder: (context, index) {
          final day = _days![index];
          final isSelected = index == _selectedDayIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedDayIndex = index),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2D2D2F) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(day.date).toUpperCase(), // e.g., MON
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContentArea() {
    final selectedDay = _days![_selectedDayIndex];
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                DateFormat('EEEE, MMMM d').format(selectedDay.date),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: selectedDay.tasks.length,
                itemBuilder: (context, index) {
                  return _buildTaskCard(selectedDay, selectedDay.tasks[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(Day day, Task task) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 0.0),
            child: Checkbox(
              value: task.isCompleted,
              onChanged: (bool? value) async {
                if (value != null) {
                  try {
                    await _firestoreService.updateTaskCompletion(
                      widget.userId,
                      widget.weekId,
                      day.id,
                      task.id,
                      value,
                    );
                    setState(() {
                      task.isCompleted = value;
                    });
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error updating task: $e")),
                    );
                  }
                }
              },
              side: const BorderSide(color: Colors.grey, width: 2),
              activeColor: Colors.deepPurpleAccent,
              checkColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: [
                    _buildInfoChip(
                      icon: Icons.access_time_filled,
                      label: '${task.startTime} - ${task.endTime}',
                    ),
                    _buildInfoChip(
                      icon: _getIconForCategory(task.category),
                      label: task.category,
                    ),
                    ...task.tags.map((tag) => _buildInfoChip(
                          icon: Icons.label_outline, // Generic tag icon
                          label: tag,
                        )),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return Icons.work;
      case 'personal':
        return Icons.person;
      case 'health':
        return Icons.favorite;
      case 'learning':
        return Icons.school;
      case 'balance':
        return Icons.balance;
      default:
        return Icons.circle;
    }
  }
}
