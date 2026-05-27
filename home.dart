// ignore_for_file: use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../backend/firebase.dart';
import '../backend/app_localizations.dart';
import '../backend/language_provider.dart';
import 'ui.dart';

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({
    Key? key,
    required this.userName,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  int completedSessions = 0;
  int activeDays = 0;
  int totalHours = 0;
  int totalSessions = 0;
  double progressPercentage = 0.0;

  int exposureCompleted = 0;
  int relaxationCompleted = 0;
  int mindfulnessCompleted = 0;

  final int exposureTotal = 10;
  final int relaxationTotal = 8;
  final int mindfulnessTotal = 15;

  @override
  void initState() {
    super.initState();
    _loadSessionStats();
  }

  Future<void> _loadSessionStats() async {
    try {
      final user = FirebaseService.auth.currentUser;
      if (user == null) return;

      final sessionsSnapshot = await FirebaseFirestore.instance
          .collection('sessions')
          .where('userId', isEqualTo: user.uid)
          .get();

      final sessions = sessionsSnapshot.docs;
      final totalSessions = sessions.length;

      final uniqueDays = sessions
          .map((doc) {
            final date = (doc.data()['date'] as Timestamp).toDate();
            return DateTime(date.year, date.month, date.day);
          })
          .toSet()
          .length;

      final totalSeconds = sessions.fold<int>(0, (sum, doc) {
        return sum + (doc.data()['duration'] as int? ?? 0);
      });
      final totalHours = totalSeconds ~/ 3600;

      int countByType(String type) {
        return sessions.where((doc) => doc.data()['type'] == type).length;
      }

      setState(() {
        completedSessions = totalSessions;
        activeDays = uniqueDays;
        this.totalHours = totalHours;
        this.totalSessions = totalSessions;
        progressPercentage = totalSessions > 0 ? 100.0 : 0.0;
        exposureCompleted = countByType('exposure');
        relaxationCompleted = countByType('relaxation');
        mindfulnessCompleted = countByType('mindfulness');
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        completedSessions = 0;
        activeDays = 0;
        totalHours = 0;
        totalSessions = 0;
        progressPercentage = 0.0;
        exposureCompleted = 0;
        relaxationCompleted = 0;
        mindfulnessCompleted = 0;
      });
    }
  }

  Widget _buildEnvironmentOption(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
  }) {
    final languageCode = Provider.of<LanguageProvider>(context, listen: false)
        .locale
        .languageCode;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? AppUI.purplePrimary.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppUI.purplePrimary : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          if (languageCode != 'ar')
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppUI.purplePrimary.withOpacity(0.2)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppUI.purplePrimary : Colors.grey[600],
                size: 24,
              ),
            ),
          if (languageCode != 'ar') const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: languageCode == 'ar'
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppUI.purplePrimary : Colors.black,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (languageCode == 'ar') const SizedBox(width: 12),
          if (languageCode == 'ar')
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppUI.purplePrimary.withOpacity(0.2)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppUI.purplePrimary : Colors.grey[600],
                size: 24,
              ),
            ),
          if (isSelected)
            Padding(
              padding: languageCode == 'ar'
                  ? const EdgeInsets.only(right: 8)
                  : const EdgeInsets.only(left: 8),
              child: Icon(
                Icons.check_circle,
                color: AppUI.purplePrimary,
              ),
            ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0: // Dashboard

        break;
      case 1: // VR Environments
        Navigator.pushNamed(context, '/vr-environments');
        break;
      case 2: // Sessions History
        Navigator.pushNamed(context, '/sessions-history');
        break;
      case 3: // Profile
        Navigator.pushNamed(context, '/profile');
        break;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  String _getGreeting(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n?.translate('good_morning') ?? 'Good morning';
    if (hour < 17) return l10n?.translate('good_afternoon') ?? 'Good afternoon';
    return l10n?.translate('good_evening') ?? 'Good evening';
  }

  void _startTodaySession() {
    Navigator.pushNamed(context, '/vr-environments');
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final locale = languageProvider.locale;
    final languageCode = locale.languageCode;
    final l10n = AppLocalizations.of(context);

    return Directionality(
      textDirection:
          languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
          title: Text(
            l10n?.translate('dashboard') ?? 'Dashboard',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                height: 270,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    image: AssetImage('assets/5.png'),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: languageCode == 'ar'
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getGreeting(context),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        l10n?.translate('continue_your_journey') ??
                            'Continue Your Healing Journey',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        textAlign: languageCode == 'ar'
                            ? TextAlign.right
                            : TextAlign.left,
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(
                                text: l10n?.translate('you_have_completed') ??
                                    "You've completed "),
                            TextSpan(
                              text: '$completedSessions',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                            TextSpan(
                              text: l10n?.translate(
                                      'sessions_progress_message') ??
                                  ' sessions this month. Your progress is remarkable. Ready for today\'s session?',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Align(
                        alignment: languageCode == 'ar'
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: AppUI.gradientButton(
                          text: l10n?.translate('start_today_session') ??
                              'Start Today\'s Session',
                          onPressed: _startTodaySession,
                          height: 35,
                          icon: Icons.play_arrow,
                          colors: [
                            AppUI.purpleSecondary,
                            AppUI.purplePrimary,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _statTile(
                    context,
                    title: l10n?.translate('session_duration') ?? 'مدة الجلسة',
                    value: languageCode == 'ar' ? '30 دقيقة' : '30 min',
                    icon: Icons.timer,
                    color: AppUI.purplePrimary,
                  ),
                  _statTile(
                    context,
                    title: l10n?.translate('exposure_level') ?? 'مستوى التعرض',
                    value: l10n?.translate('medium') ?? 'متوسط',
                    icon: Icons.insights,
                    color: AppUI.purpleSecondary,
                  ),
                  _statTile(
                    context,
                    title: l10n?.translate('session_goal') ?? 'هدف الجلسة',
                    value: l10n?.translate('calmness') ?? 'تهدئة',
                    icon: Icons.flag,
                    color: AppUI.purpleAccent,
                  ),
                  _statTile(
                    context,
                    title: l10n?.translate('environment_type') ?? 'نوع البيئة',
                    value: l10n?.translate('relaxation') ?? 'استرخاء',
                    icon: Icons.public,
                    color: AppUI.purpleDark,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              AppUI.card(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: languageCode == 'ar'
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.translate('session_configuration') ??
                          'تهيئة جلسة علاجية',
                      style: AppUI.headingMedium,
                      textAlign: languageCode == 'ar'
                          ? TextAlign.right
                          : TextAlign.left,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n?.translate(
                              'choose_environment_based_on_condition') ??
                          'اختيار البيئة حسب حالة المستفيد (تعرض / استرخاء)',
                      style: AppUI.captionText,
                      textAlign: languageCode == 'ar'
                          ? TextAlign.right
                          : TextAlign.left,
                    ),
                    const SizedBox(height: 20),

                    /// Current Environment Type
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppUI.purplePrimary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppUI.purplePrimary.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (languageCode == 'ar') ...[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  l10n?.translate('current_environment') ??
                                      'البيئة الحالية',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppUI.purplePrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n?.translate('relaxation_environment') ??
                                      'بيئة استرخاء',
                                  style: AppUI.bodyText,
                                ),
                              ],
                            ),
                            Icon(
                              Icons.spa,
                              color: AppUI.purplePrimary,
                              size: 30,
                            ),
                          ] else ...[
                            Icon(
                              Icons.spa,
                              color: AppUI.purplePrimary,
                              size: 30,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n?.translate('current_environment') ??
                                      'Current Environment',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppUI.purplePrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n?.translate('relaxation_environment') ??
                                      'Relaxation Environment',
                                  style: AppUI.bodyText,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// Environment Selection Options
                    Text(
                      l10n?.translate('available_environments') ??
                          'البيئات المتاحة',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                      textAlign: languageCode == 'ar'
                          ? TextAlign.right
                          : TextAlign.left,
                    ),
                    const SizedBox(height: 12),
                    _buildEnvironmentOption(
                      context,
                      title:
                          l10n?.translate('gradual_exposure') ?? 'تعرض تدريجي',
                      description: l10n?.translate('exposure_description') ??
                          'مواجهة مخاوف بشكل تدريجي',
                      icon: Icons.thermostat_auto,
                      isSelected: false,
                    ),
                    const SizedBox(height: 12),
                    _buildEnvironmentOption(
                      context,
                      title:
                          l10n?.translate('deep_relaxation') ?? 'استرخاء عميق',
                      description: l10n?.translate('relaxation_description') ??
                          'تهدئة واسترخاء للعقل والجسم',
                      icon: Icons.self_improvement,
                      isSelected: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AppUI.card(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: languageCode == 'ar'
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (languageCode == 'ar') ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              l10n?.translate('specialist') ?? 'المختص',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: Colors.amber[700],
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n?.translate('specialist_notes') ??
                                    'ملاحظات المختص',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: Colors.amber[700],
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n?.translate('specialist_notes') ??
                                    'Specialist Notes',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              l10n?.translate('specialist') ?? 'Specialist',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey[200]!,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (languageCode != 'ar')
                            Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.grey[500],
                              size: 20,
                            ),
                          if (languageCode != 'ar') const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n?.translate('specialist_notes_placeholder') ??
                                  (languageCode == 'ar'
                                      ? 'ستظهر هنا ملاحظات وتوجيهات المختص حول تقدمك وجلساتك القادمة. استمر في المتابعة المنتظمة لتحقيق أفضل النتائج.'
                                      : 'Specialist notes and guidance about your progress and upcoming sessions will appear here. Continue with regular follow-ups for optimal results.'),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                height: 1.5,
                              ),
                              textAlign: languageCode == 'ar'
                                  ? TextAlign.right
                                  : TextAlign.left,
                            ),
                          ),
                          if (languageCode == 'ar') const SizedBox(width: 12),
                          if (languageCode == 'ar')
                            Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.grey[500],
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: languageCode == 'ar'
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () {
                          // يمكنك إضافة دالة هنا لفتح صفحة الملاحظات
                          print('View all specialist notes');
                        },
                        icon: Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: languageCode == 'ar'
                              ? Colors.grey[600]
                              : AppUI.purplePrimary,
                        ),
                        label: Text(
                          l10n?.translate('view_all_notes') ??
                              'عرض جميع الملاحظات',
                          style: TextStyle(
                            color: languageCode == 'ar'
                                ? Colors.grey[600]
                                : AppUI.purplePrimary,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavBar(context),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.dashboard),
          label: l10n?.translate('dashboard') ?? 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.vrpano),
          label: l10n?.translate('vr_environments') ?? 'VR',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.history),
          label: l10n?.translate('history') ?? 'History',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: l10n?.translate('profile') ?? 'Profile',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: AppUI.purplePrimary,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      onTap: _onItemTapped,
      backgroundColor: Colors.white,
      elevation: 10,
    );
  }

  Widget _statTile(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final languageCode = Provider.of<LanguageProvider>(context, listen: false)
        .locale
        .languageCode;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: languageCode == 'ar'
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Align(
            alignment:
                languageCode == 'ar' ? Alignment.topRight : Alignment.topLeft,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: languageCode == 'ar' ? TextAlign.right : TextAlign.left,
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: color.withOpacity(0.8),
            ),
            textAlign: languageCode == 'ar' ? TextAlign.right : TextAlign.left,
          ),
        ],
      ),
    );
  }
}
