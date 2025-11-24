
import 'package:flutter/material.dart';
import '../models/schedule_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import 'day_detail_screen.dart';

class ScheduleScreen extends StatefulWidget {
  final String userId;

  const ScheduleScreen({super.key, required this.userId});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  User? _user;
  List<Schedule>? _schedules;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final user = await _firestoreService.getUser(widget.userId);
      final schedules = await _firestoreService.getSchedules(widget.userId);
      if (mounted) {
        setState(() {
          _user = user;
          _schedules = schedules;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Failed to load data: $e";
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
        title: const Text("Weekly Schedule"),
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
    if (_user == null) {
      return const Center(child: Text("User not found."));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserProfile(),
          const SizedBox(height: 24),
          Text("Schedules", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 10),
          _buildSchedulesList(),
        ],
      ),
    );
  }

  Widget _buildUserProfile() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_user!.profile.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(_user!.profile.email, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildSchedulesList() {
    if (_schedules == null || _schedules!.isEmpty) {
      return const Text("No schedules found.");
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _schedules!.length,
      itemBuilder: (context, index) {
        final schedule = _schedules![index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            title: Text("Week: ${schedule.id.replaceAll('_', ' ')}"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DayDetailScreen(
                    userId: widget.userId,
                    weekId: schedule.id,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
