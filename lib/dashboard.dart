
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String _jsonContent = '';
  bool _showCreateUserButton = false;

  @override
  void initState() {
    super.initState();
    _loadJsonData();
  }

  Future<void> _loadJsonData() async {
    try {
      final String response = await rootBundle.loadString('assets/nextweekstask.json');
      final data = await json.decode(response);
      setState(() {
        _jsonContent = const JsonEncoder.withIndent('  ').convert(data);
        _showCreateUserButton = true; 
      });
    } catch (e) {
      print("Error loading JSON data: $e");
      setState(() {
        _jsonContent = "Error loading JSON data: $e";
      });
    }
  }

  Future<void> _pushJsonToFirestore() async {
    try {
      final String response = await rootBundle.loadString('assets/nextweekstask.json');
      final data = json.decode(response);

      final WriteBatch batch = FirebaseFirestore.instance.batch();
      final users = data['users'] as Map<String, dynamic>;

      users.forEach((userId, userData) {
        final userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User collection created successfully!')),
        );
      }
    } catch (e) {
      print('Error pushing JSON to Firestore: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_showCreateUserButton)
              ElevatedButton(
                onPressed: _pushJsonToFirestore,
                child: const Text('Create Complete User Collection'),
              ),
          ],
        ),
      ),
    );
  }
}
