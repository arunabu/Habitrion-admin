
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';
import '../screens/schedule_list_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // In a real app, you would have an authentication flow.
    // For this example, we'll create and set a default user.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final defaultUser = User(
        id: 'user_001', // Hardcoded default user
        name: 'Arun',
        email: 'arun@example.com',
      );
      Provider.of<UserProvider>(context, listen: false).setUser(defaultUser);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    if (userProvider.user == null) {
      // You could show a loading spinner here while the user is being fetched
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Once the user is available, show the main screen
    return const ScheduleListScreen();
  }
}
