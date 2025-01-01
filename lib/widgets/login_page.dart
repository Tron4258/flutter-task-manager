import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatelessWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '882005093806-jofsdq57gkfbupplvk04mkaaj2t412sd.apps.googleusercontent.com',
    scopes: [
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _handleSignIn(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      print("User signed in: ${userCredential.user?.displayName}");
      
      // No need to navigate manually - StreamBuilder will handle it
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign in failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle login logic
              },
              child: Text('Login'),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.login),
              label: Text('Sign in with Google'),
              onPressed: () => _handleSignIn(context),  // Pass context to _handleSignIn
            ),
          ],
        ),
      ),
    );
  }
} 