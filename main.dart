// ignore_for_file: use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'backend/firebase.dart';
import 'backend/language_provider.dart';
import 'frontend/home.dart';
import 'frontend/profile.dart';
import 'frontend/welcome.dart';
import 'frontend/login.dart';
import 'frontend/ui.dart';
import 'icons/user_sessions_screen.dart';
import '../backend/app_localizations.dart';
import 'icons/vr_environments_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print(' Starting VR MindEase App...');

  try {
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

    await FirebaseService.initialize();

    print(' Firebase initialized successfully');
  } catch (e) {
    print(' Error initializing Firebase: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LanguageProvider(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final languageProvider = Provider.of<LanguageProvider>(context);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'VR MindEase',
            locale: languageProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar'),
              Locale('en'),
              Locale('fr'),
            ],
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppUI.purpleSecondary,
                brightness: Brightness.light,
              ),
              textTheme: const TextTheme(
                displayLarge: AppUI.headingLarge,
                displayMedium: AppUI.headingMedium,
                displaySmall: AppUI.headingSmall,
                bodyLarge: AppUI.bodyText,
                bodyMedium: AppUI.captionText,
                labelLarge: AppUI.buttonText,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: AppUI.primaryWhite,
                elevation: 1,
                centerTitle: true,
                iconTheme: IconThemeData(color: AppUI.textColor),
              ),
              scaffoldBackgroundColor: AppUI.primaryWhite,
              primaryColor: AppUI.purpleSecondary,
            ),
            home: const AuthWrapper(),
            routes: {
              '/welcome': (context) => const WelcomeScreen(),
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeScreen(userName: ''),
              '/profile': (context) => const ProfileScreen(),
              '/sessions-history': (context) => const UserSessionsScreen(),
              '/vr-environments': (context) => const VREnvironmentsScreen(),
            },
            onUnknownRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => const WelcomeScreen(),
              );
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppUI.purplePrimary,
            ),
          );
        }

        if (snapshot.hasError) {
          print(' Auth error: ${snapshot.error}');
          return const ErrorScreen();
        }

        final user = snapshot.data;

        if (user == null) {
          return const FirstTimeCheck();
        } else {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppUI.purplePrimary,
                  ),
                );
              }

              if (userSnapshot.hasError) {
                print(' Error fetching user data: ${userSnapshot.error}');
                return const HomeScreen(userName: 'User');
              }

              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                print(' User document not found');
                return const HomeScreen(userName: 'User');
              }

              final userData =
                  userSnapshot.data!.data() as Map<String, dynamic>;
              final username = userData['username'] ?? 'User';

              return HomeScreen(userName: username);
            },
          );
        }
      },
    );
  }
}

class FirstTimeCheck extends StatefulWidget {
  const FirstTimeCheck({super.key});

  @override
  State<FirstTimeCheck> createState() => _FirstTimeCheckState();
}

class _FirstTimeCheckState extends State<FirstTimeCheck> {
  bool _isFirstTime = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isLoading = false;

      _isFirstTime = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppUI.purplePrimary,
        ),
      );
    }

    if (_isFirstTime) {
      return const WelcomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 20),
              Text(
                'Something went wrong',
                style: AppUI.headingMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Please restart the app and try again.',
                style: AppUI.bodyText,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const AuthWrapper(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppUI.purplePrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
                child: Text(
                  'Try Again',
                  style: AppUI.buttonText.copyWith(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
