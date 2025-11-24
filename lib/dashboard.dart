import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/screens/schedule_screen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool _isLoading = true;
  String? _firstUserId;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('users').limit(1).get();
      if (mounted) {
        if (snapshot.docs.isNotEmpty) {
          setState(() {
            _firstUserId = snapshot.docs.first.id;
            _isLoading = false;
          });
        } else {
          // If no data exists, automatically populate it
          await _pushJsonToFirestore();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Error initializing data: $e";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pushJsonToFirestore() async {
    try {
      final String response =
          await rootBundle.loadString('assets/nextweekstask.json');
      final data = json.decode(response);

      final WriteBatch batch = FirebaseFirestore.instance.batch();
      final users = data['users'] as Map<String, dynamic>;

      users.forEach((userId, userData) {
        final userDocRef =
            FirebaseFirestore.instance.collection('users').doc(userId);
        userData = userData as Map<String, dynamic>;

        final profile = userData.remove('profile');
        final settings = userData.remove('settings');

        batch.set(userDocRef, {'profile': profile, 'settings': settings});

        final schedules = userData['schedules'] as Map<String, dynamic>;
        schedules.forEach((weekId, weekData) {
          final weekDocRef = userDocRef.collection('schedules').doc(weekId);
          weekData = weekData as Map<String, dynamic>;

          final days = weekData.remove('days');
          batch.set(weekDocRef, weekData);

          if (days != null) {
            final daysData = days as Map<String, dynamic>;
            daysData.forEach((date, dayData) {
              final dayDocRef = weekDocRef.collection('days').doc(date);
              dayData = dayData as Map<String, dynamic>;
              batch.set(dayDocRef, dayData);
            });
          }
        });
      });

      await batch.commit();

      // After pushing data, re-initialize to get the user ID
      if (mounted) {
        await _initializeData();
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error pushing JSON to Firestore: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Habitrion Admin Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
          child: Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (_firstUserId != null) {
      return ScheduleBody(userId: _firstUserId!);
    }
    // This state should ideally not be reached if initialization is successful
    return const Center(
      child: Text('Could not load user data. Please restart the application.'),
    );
  }
}
