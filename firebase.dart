import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static FirebaseAuth? _auth;
  static FirebaseFirestore? _firestore;
  static bool _isInitialized = false;

  static FirebaseAuth get auth {
    if (!_isInitialized || _auth == null) {
      throw Exception(
          'Firebase is not initialized. Call FirebaseService.initialize() first.');
    }
    return _auth!;
  }

  static FirebaseFirestore get firestore {
    if (!_isInitialized || _firestore == null) {
      throw Exception(
          'Firebase is not initialized. Call FirebaseService.initialize() first.');
    }
    return _firestore!;
  }

  static Future<void> initialize() async {
    try {
      print('🔄 Initializing Firebase...');

      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyBL2pRB0sJfZyTaYK2V6A3ejeJsSk5AC1Y",
          appId: "1:57707538269:android:e3c760b6bf7c1aa7722ab4",
          messagingSenderId: "57707538269",
          projectId: "volunteer-af128",
          storageBucket: "volunteer-af128.firebasestorage.app",
          iosClientId:
              "57707538269-j3q1911qiqa4bvvfepan9ea1p7ghf2sl.apps.googleusercontent.com",
          iosBundleId: "com.example.mindeasevr.app",
        ),
      );

      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _isInitialized = true;

      print(' Firebase initialized successfully');
      print(' Auth instance: $_auth');
      print(' Firestore instance: $_firestore');
    } catch (e) {
      print(' Error initializing Firebase: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  static bool get isInitialized => _isInitialized;

  static User? getCurrentUser() {
    if (!_isInitialized) return null;
    return _auth?.currentUser;
  }

  static Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      print(' Attempting login for: $email');
      final userCredential = await _auth!.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      print(' Login successful - User ID: ${userCredential.user?.uid}');
      return userCredential;
    } catch (e) {
      print(' Login error: $e');
      rethrow;
    }
  }

  // Register new user (SIMPLIFIED & NULL-SAFE)
  static Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // Ensure Firebase is initialized
      if (!_isInitialized) {
        print(' Firebase not initialized, initializing now...');
        await initialize();
      }

      print(' Creating account for: $email');

      // Create user in Authentication
      final userCredential = await _auth!.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final userId = userCredential.user?.uid;
      print(' User created in Auth - ID: $userId');

      if (userId == null) {
        throw Exception('Failed to get user ID after creation');
      }

      // Save basic user data in Firestore
      final userData = {
        'username': username,
        'email': email.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      print(' Saving user data to Firestore...');
      await _firestore!.collection('users').doc(userId).set(userData);

      print(' Account created successfully');
      print(' User data saved: $userData');

      return userCredential;
    } catch (e) {
      print(' Error creating account: $e');
      print(' Error type: ${e.runtimeType}');
      if (e is FirebaseAuthException) {
        print(' Firebase Auth Error Code: ${e.code}');
        print(' Firebase Auth Error Message: ${e.message}');
      }
      rethrow;
    }
  }

  // Sign out (null-safe)
  static Future<void> signOut() async {
    try {
      if (_isInitialized && _auth != null) {
        await _auth!.signOut();
        print('✅ Logout successful');
      }
    } catch (e) {
      print('❌ Logout error: $e');
      rethrow;
    }
  }

  // Reset password (null-safe)
  static Future<void> resetPassword(String email) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      await _auth!.sendPasswordResetEmail(email: email.trim());
      print('✅ Password reset email sent to: $email');
    } catch (e) {
      print('❌ Error resetting password: $e');
      rethrow;
    }
  }

  // Update user data (null-safe)
  static Future<void> updateUserData({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      await _firestore!.collection('users').doc(userId).update(data);
      print('✅ User data updated for ID: $userId');
    } catch (e) {
      print('❌ Error updating user data: $e');
      rethrow;
    }
  }

  // Get user data from Firestore (null-safe)
  static Future<DocumentSnapshot> getUserData(String userId) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      return await _firestore!.collection('users').doc(userId).get();
    } catch (e) {
      print('❌ Error fetching user data: $e');
      rethrow;
    }
  }

  // Check if user is logged in (null-safe)
  static bool isUserLoggedIn() {
    return _isInitialized && _auth?.currentUser != null;
  }

  // Listen to auth state changes (null-safe)
  static Stream<User?> get authStateChanges {
    if (!_isInitialized) {
      return Stream.value(null);
    }
    return _auth!.authStateChanges();
  }

  // Login shortcut (simplified)
  static Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return signInWithEmailAndPassword(email: email, password: password);
  }

  // Signup shortcut (SIMPLIFIED - no userType or additionalData)
  static Future<UserCredential> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    return signUpWithEmailAndPassword(
      email: email,
      password: password,
      username: username,
    );
  }
}
