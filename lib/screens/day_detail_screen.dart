
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _loadDays();
  }

  Future<void> _loadDays() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final days = await _firestoreService.getDays(widget.userId, widget.weekId);
      if (mounted) {
        setState(() {
          _days = days;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Failed to load day details: $e";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.weekId.replaceAll('_', ' ')),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(_error!, style: const TextStyle(color: Colors.red)),
        ),
      );
    }
    if (_days == null || _days!.isEmpty) {
      return const Center(child: Text("No daily data found."));
    }

    return ListView.builder(
      itemCount: _days!.length,
      itemBuilder: (context, index) {
        final day = _days![index];
        return ExpansionTile(
          title: Text(day.day, style: const TextStyle(fontWeight: FontWeight.bold)),
          children: day.segments.asMap().entries.map((entry) {
            final segmentIndex = entry.key;
            final segment = entry.value;
            return ListTile(
              title: Text(segment.activity),
              subtitle: Text(
                  "${segment.category} - ${segment.subcategory}\n${segment.start} - ${segment.end} (Planned: ${segment.planned}h, Actual: ${segment.actual}h)"),
              trailing: IconButton(
                icon: Icon(
                  segment.actual >= segment.planned
                      ? Icons.check_circle
                      : Icons.check_circle_outline,
                  color: segment.actual >= segment.planned ? Colors.green : Colors.grey,
                ),
                onPressed: () => _updateTaskStatus(day, segmentIndex, segment),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _updateTaskStatus(Day day, int segmentIndex, Segment segment) async {
    final originalActual = segment.actual;
    final newActual = originalActual >= segment.planned ? 0.0 : segment.planned;

    // Optimistic UI update
    setState(() {
      day.segments[segmentIndex].actual = newActual;
    });

    try {
      await _firestoreService.updateTaskActual(
        widget.userId,
        widget.weekId,
        day.id,
        segmentIndex,
        newActual,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task updated successfully!'), duration: Duration(seconds: 1)),
        );
      }
    } catch (e) {
      if (mounted) {
        // Revert the change if the update fails
        setState(() {
          day.segments[segmentIndex].actual = originalActual;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating task: $e')),
        );
      }
    }
  }
}
