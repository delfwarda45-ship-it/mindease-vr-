// ignore_for_file: use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../backend/firebase.dart';
import '../backend/app_localizations.dart';
import '../backend/language_provider.dart';
import 'ui.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  String _username = '';
  String _email = '';
  bool _isLoading = true;
  bool _isEditing = false;
  bool _showLanguageDropdown = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final List<Map<String, dynamic>> _supportedLanguages = [
    {'code': 'ar', 'name': 'العربية', 'flag': '🇸🇦'},
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseService.auth.currentUser;
      if (user != null) {
        final userDoc = await FirebaseService.firestore
            .collection('users')
            .doc(user.uid)
            .get();
        final userData = userDoc.data() as Map<String, dynamic>?;

        setState(() {
          _username = userData?['username'] ?? 'User';
          _email = userData?['email'] ?? user.email ?? '';
          _usernameController.text = _username;
          _emailController.text = _email;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final user = FirebaseService.auth.currentUser;
      if (user == null) return;

      setState(() {
        _isLoading = true;
      });

      await FirebaseService.firestore.collection('users').doc(user.uid).update({
        'username': _usernameController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (_emailController.text.trim() != user.email) {
        await user.updateEmail(_emailController.text.trim());
      }

      await _loadUserData();

      setState(() {
        _isEditing = false;
      });

      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.translate('profile_updated') ??
              'Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error updating profile: $e');

      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${l10n?.translate('update_error') ?? 'Error updating profile'}: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseService.auth.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  void _changeLanguage(String languageCode) {
    Provider.of<LanguageProvider>(context, listen: false)
        .setLocale(Locale(languageCode));
    setState(() {
      _showLanguageDropdown = false;
    });
  }

  String _getCurrentLanguageName(String currentCode) {
    final lang = _supportedLanguages.firstWhere(
      (lang) => lang['code'] == currentCode,
      orElse: () => _supportedLanguages[1],
    );
    return lang['name'];
  }

  String _getCurrentLanguageFlag(String currentCode) {
    final lang = _supportedLanguages.firstWhere(
      (lang) => lang['code'] == currentCode,
      orElse: () => _supportedLanguages[1],
    );
    return lang['flag'];
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final locale = languageProvider.locale;
    final languageCode = locale.languageCode;
    final l10n = AppLocalizations.of(context);
    final currentLanguageName = _getCurrentLanguageName(languageCode);
    final currentLanguageFlag = _getCurrentLanguageFlag(languageCode);

    return Directionality(
      textDirection:
          languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Stack(
          children: [
            // Background Image
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/1.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // Content
            SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: languageCode == 'ar'
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: languageCode == 'ar'
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          IconButton(
                            icon: Icon(
                              languageCode == 'ar'
                                  ? Icons.arrow_forward
                                  : Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppUI.purplePrimary.withOpacity(0.1),
                                border: Border.all(
                                  color: AppUI.purplePrimary,
                                  width: 3,
                                ),
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 50,
                                color: AppUI.purplePrimary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _isLoading
                                  ? (l10n?.translate('loading') ?? 'Loading...')
                                  : _username,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isLoading ? '' : _email,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(24),
                        child: _isLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                  color: AppUI.purplePrimary,
                                ),
                              )
                            : Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    AppUI.buildTextField(
                                      label: l10n?.translate('username') ??
                                          'Username',
                                      controller: _usernameController,
                                      hintText:
                                          l10n?.translate('enter_username') ??
                                              'Enter your username',
                                      prefixIcon: Icon(
                                        Icons.person_outline,
                                        color: AppUI.purplePrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    AppUI.buildTextField(
                                      label:
                                          l10n?.translate('email') ?? 'Email',
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      hintText:
                                          l10n?.translate('enter_email') ??
                                              'Enter your email',
                                      prefixIcon: Icon(
                                        Icons.email_outlined,
                                        color: AppUI.purplePrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    if (!_isEditing)
                                      AppUI.gradientButton(
                                        text: l10n?.translate('edit_profile') ??
                                            'Edit Profile',
                                        onPressed: () {
                                          setState(() {
                                            _isEditing = true;
                                          });
                                        },
                                        icon: Icons.edit,
                                      )
                                    else
                                      Row(
                                        children: [
                                          Expanded(
                                            child: AppUI.secondaryButton(
                                              text: l10n?.translate('cancel') ??
                                                  'Cancel',
                                              onPressed: () {
                                                setState(() {
                                                  _isEditing = false;
                                                  _usernameController.text =
                                                      _username;
                                                  _emailController.text =
                                                      _email;
                                                });
                                              },
                                              outlined: true,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: AppUI.gradientButton(
                                              text: l10n?.translate('save') ??
                                                  'Save',
                                              onPressed: _updateProfile,
                                              icon: Icons.save,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                      ),

                      const SizedBox(height: 30),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppUI.purplePrimary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.language,
                                  color: AppUI.purplePrimary,
                                  size: 22,
                                ),
                              ),
                              title: Text(
                                l10n?.translate('language') ?? 'Language',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                l10n?.translate('change_app_language') ??
                                    'Change app language',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  _showLanguageDropdown
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  color: AppUI.purplePrimary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showLanguageDropdown =
                                        !_showLanguageDropdown;
                                  });
                                },
                              ),
                              onTap: () {
                                setState(() {
                                  _showLanguageDropdown =
                                      !_showLanguageDropdown;
                                });
                              },
                            ),
                            if (!_showLanguageDropdown)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          currentLanguageFlag,
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          currentLanguageName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppUI.purplePrimary
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Text(
                                        languageCode.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppUI.purplePrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (_showLanguageDropdown)
                              Column(
                                children: _supportedLanguages.map((lang) {
                                  final isSelected =
                                      lang['code'] == languageCode;
                                  return Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: isSelected
                                          ? null
                                          : () => _changeLanguage(lang['code']),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppUI.purplePrimary
                                                  .withOpacity(0.1)
                                              : Colors.transparent,
                                          border: Border(
                                            top: BorderSide(
                                              color: Colors.grey.shade200,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  lang['flag'],
                                                  style: const TextStyle(
                                                      fontSize: 20),
                                                ),
                                                const SizedBox(width: 15),
                                                Text(
                                                  lang['name'],
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: isSelected
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                    color: isSelected
                                                        ? AppUI.purplePrimary
                                                        : Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (isSelected)
                                              Icon(
                                                Icons.check_circle,
                                                color: AppUI.purplePrimary,
                                                size: 20,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Logout Button Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.logout,
                              color: Colors.red,
                              size: 22,
                            ),
                          ),
                          title: Text(
                            l10n?.translate('logout') ?? 'Logout',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                          subtitle: Text(
                            l10n?.translate('sign_out_account') ??
                                'Sign out of your account',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          trailing: Icon(
                            languageCode == 'ar'
                                ? Icons.chevron_left
                                : Icons.chevron_right,
                            color: Colors.red,
                          ),
                          onTap: () {
                            _showLogoutDialog();
                          },
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // App Version
                      Center(
                        child: Text(
                          'VR MindEase v1.0.0',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    final l10n = AppLocalizations.of(context);

    final languageCode = Provider.of<LanguageProvider>(context, listen: false)
        .locale
        .languageCode;

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection:
            languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            l10n?.translate('logout') ?? 'Logout',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppUI.purplePrimary,
            ),
          ),
          content: Text(
            l10n?.translate('confirm_logout') ??
                'Are you sure you want to logout?',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n?.translate('cancel') ?? 'Cancel',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                l10n?.translate('logout') ?? 'Logout',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
