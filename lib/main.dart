import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'widgets/login_page.dart';
import 'widgets/registration_page.dart';
import 'widgets/task_form.dart';
import 'widgets/task_search_delegate.dart';
import 'models/task.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task App',
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasData && snapshot.data != null) {
            // User is logged in, show HomePage
            return HomePage();
          }
          
          // User is not logged in, show LoginPage
          return LoginPage();
        },
      ),
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegistrationPage(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks'),
        actions: [
          if (user != null) ...[
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                await GoogleSignIn().signOut();
              },
            ),
          ],
        ],
      ),
      body: user != null 
        ? TaskSearchDelegate(userId: user.uid).buildResults(context)
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text('Login'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: Text('Register'),
                ),
              ],
            ),
          ),
      floatingActionButton: user != null
        ? FloatingActionButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => TaskForm(userId: user.uid),
              );
            },
            child: Icon(Icons.add),
          )
        : null,
    );
  }
}
