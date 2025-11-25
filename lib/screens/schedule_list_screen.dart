
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/schedule_model.dart';
import '../services/firestore_service.dart';
import '../providers/user_provider.dart';
import 'day_detail_screen.dart';

class ScheduleListScreen extends StatefulWidget {
  const ScheduleListScreen({super.key});

  @override
  State<ScheduleListScreen> createState() => _ScheduleListScreenState();
}

class _ScheduleListScreenState extends State<ScheduleListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  Future<List<Schedule>>? _schedulesFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if the future is null to prevent re-fetching on every rebuild
    if (_schedulesFuture == null) {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      if (user != null) {
        _loadSchedules(user.id);
      }
    }
  }

  void _loadSchedules(String userId) {
    setState(() {
      _schedulesFuture = _firestoreService.getSchedules(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark background for the whole screen
      appBar: AppBar(
        title: Text(user != null ? '${user.profile.name}''s Schedules' : 'Schedules', style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E1E1E), // Appbar color
        elevation: 0,
      ),
      body: user == null
          ? const Center(child: Text('Please log in to see your schedules.', style: TextStyle(color: Colors.white)))
          : FutureBuilder<List<Schedule>>(
              future: _schedulesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: () => _addNextWeeksTasks(user.id),
                      child: const Text('Add Next Week''s Tasks Arun' ),
                    ),
                  );
                }

                final schedules = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: schedules.length,
                  itemBuilder: (context, index) {
                    final schedule = schedules[index];
                    
                    // --- CORRECTED CALCULATION ---
                    // Calculate totals from subcategoriesSummary
                    final totalPlanned = schedule.subcategoriesSummary.values.fold(0.0, (sum, sub) => sum + sub.planned);
                    final totalActual = schedule.subcategoriesSummary.values.fold(0.0, (sum, sub) => sum + sub.actual);
                    final progress = totalPlanned > 0 ? totalActual / totalPlanned : 0.0;

                    return Card(
                      color: const Color(0xFF1E1E1E), // Card background color
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DayDetailScreen(userId: user.id, weekId: schedule.id),
                            ),
                          ).then((_) => _loadSchedules(user.id)); // Re-fetch on return
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                schedule.id.replaceAll('_', ' '),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Planned: ${totalPlanned.toStringAsFixed(1)} hrs / Actual: ${totalActual.toStringAsFixed(1)} hrs',
                                style: TextStyle(color: Colors.grey[400], fontSize: 14),
                              ),
                              const SizedBox(height: 12),
                              if (totalPlanned > 0)
                                LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: Colors.grey[800],
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),
                                  minHeight: 6,
                                  borderRadius: BorderRadius.circular(3),
                                )
                              else
                                const SizedBox.shrink(),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  void _addNextWeeksTasks(String userId) async {
    try {
      await _firestoreService.importNextWeeksTasks(userId);
      _loadSchedules(userId); // Reload schedules
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully added next week''s tasks!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding tasks: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
