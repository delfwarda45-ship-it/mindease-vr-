import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login.dart';
import 'ui.dart';
import 'language_provider.dart';
import 'app_localizations.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  bool _isImageExpanded = false;

  List<Map<String, dynamic>> _pages = [];

  @override
  void initState() {
    super.initState();
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleImageExpansion() {
    _safeSetState(() {
      _isImageExpanded = !_isImageExpanded;
    });
  }

  List<Map<String, dynamic>> _getLocalizedPages(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return [
      {
        'image': 'assets/1.png',
        'title': l10n?.translate('welcome_title_1') ?? 'VR MindEase',
        'description': l10n?.translate('welcome_description_1') ??
            'VR MindEase combines cutting-edge virtual reality technology with evidence-based therapeutic approaches to support addiction recovery.',
        'gradient': [AppUI.purplePrimary, AppUI.purpleAccent],
      },
      {
        'image': 'assets/2.png',
        'title': l10n?.translate('welcome_title_2') ?? 'Immersive Therapy',
        'description': l10n?.translate('welcome_description_2') ??
            'Experience guided exposure therapy, mindfulness exercises, and relaxation techniques in immersive environments.',
        'gradient': [AppUI.purpleAccent, AppUI.purpleSecondary],
      },
      {
        'image': 'assets/3.png',
        'title': l10n?.translate('welcome_title_3') ?? 'Your Path to Recovery',
        'description': l10n?.translate('welcome_description_3') ??
            'Begin your journey towards recovery with our innovative VR-based therapeutic platform.',
        'gradient': [AppUI.purplePrimary, AppUI.purpleSecondary],
        'showButton': true,
      },
      // 👇 الصفحة الرابعة الجديدة
      {
        'title': l10n?.translate('vr_equipment_title') ??
            'اطلب نظارتك وابدأ رحلتك الافتراضية',
        'description': l10n?.translate('vr_equipment_description') ??
            'للاستفادة القصوى من تجربة العلاج بالواقع الافتراضي، نوصي باستخدام نظارة VR متوافقة مع هاتفك الذكي',
        'gradient': [AppUI.purplePrimary, AppUI.purpleSecondary],
        'showButton': true,
        'isVrPage': true, // علامة لتمييز الصفحة الرابعة
      },
    ];
  }

  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            l10n?.translate('select_language') ?? 'Select Language',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppUI.purplePrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _languageOption(
                context,
                l10n?.translate('english') ?? 'English',
                'EN',
                const Locale('en', 'US'),
                Icons.language,
              ),
              const SizedBox(height: 10),
              _languageOption(
                context,
                l10n?.translate('arabic') ?? 'Arabic',
                'AR',
                const Locale('ar'),
                Icons.language,
              ),
              const SizedBox(height: 10),
              _languageOption(
                context,
                l10n?.translate('french') ?? 'French',
                'FR',
                const Locale('fr'),
                Icons.language,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n?.translate('cancel') ?? 'Cancel',
                style: TextStyle(color: AppUI.purpleSecondary),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _languageOption(
    BuildContext context,
    String name,
    String code,
    Locale locale,
    IconData icon,
  ) {
    final currentLocale = Provider.of<LanguageProvider>(context).locale;
    final isSelected = currentLocale.languageCode == locale.languageCode;

    return Container(
      decoration: BoxDecoration(
        color:
            isSelected ? AppUI.purplePrimary.withOpacity(0.1) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppUI.purplePrimary : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppUI.purplePrimary : Colors.grey[600],
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? AppUI.purplePrimary : Colors.grey[800],
          ),
        ),
        subtitle: Text(
          code,
          style: TextStyle(
            color: isSelected ? AppUI.purpleSecondary : Colors.grey[600],
          ),
        ),
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: AppUI.purplePrimary,
              )
            : null,
        onTap: () {
          Provider.of<LanguageProvider>(context, listen: false)
              .setLocale(locale);
          Navigator.of(context).pop();
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final locale = languageProvider.locale;
    final isArabic = locale.languageCode == 'ar';
    final l10n = AppLocalizations.of(context);

    _pages = _getLocalizedPages(context);

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppUI.primaryWhite,
        body: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: _isImageExpanded
                  ? Image.asset(
                      _pages[_currentPage]['image'] ?? 'assets/1.png',
                      fit: BoxFit.cover,
                    )
                  : Container(color: AppUI.primaryWhite),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _isImageExpanded ? 0.7 : 0.0,
              child: Container(color: Colors.black),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: (_currentPage < _pages.length - 1 &&
                                  !_isImageExpanded)
                              ? 1.0
                              : 0.0,
                          child: TextButton(
                            onPressed: _navigateToLogin,
                            child: Text(
                              l10n?.translate('skip') ?? 'Skip',
                              style: TextStyle(
                                color: AppUI.purplePrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _showLanguageDialog(context),
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppUI.purplePrimary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.translate,
                                  color: AppUI.purplePrimary,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  locale.languageCode.toUpperCase(),
                                  style: TextStyle(
                                    color: AppUI.purplePrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                          _isImageExpanded = false;
                        });
                      },
                      itemCount: _pages.length,
                      itemBuilder: (context, index) {
                        final page = _pages[index];
                        if (page['isVrPage'] == true) {
                          return _buildVrPage(page, context);
                        }
                        return _buildPage(page, context);
                      },
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: _isImageExpanded ? 0 : 150,
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _pages.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                height: 8,
                                width: index == _currentPage ? 24 : 8,
                                decoration: BoxDecoration(
                                  color: index == _currentPage
                                      ? AppUI.purplePrimary
                                      : AppUI.purplePrimary.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          if (_currentPage < _pages.length - 1)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AppUI.primaryButton(
                                  text: l10n?.translate('next') ?? 'Next',
                                  onPressed: () {
                                    _pageController.nextPage(
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  width: 140,
                                  icon: isArabic
                                      ? Icons.arrow_back_rounded
                                      : Icons.arrow_forward_rounded,
                                ),
                              ],
                            )
                          else
                            AppUI.gradientButton(
                              text: l10n?.translate('start_journey') ??
                                  'Start Journey',
                              onPressed: _navigateToLogin,
                              width: 220,
                              icon: Icons.login,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isImageExpanded)
              Positioned(
                top: 50,
                right: isArabic ? null : 20,
                left: isArabic ? 20 : null,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: _toggleImageExpansion,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(Map<String, dynamic> page, BuildContext context) {
    final isArabic =
        Provider.of<LanguageProvider>(context).locale.languageCode == 'ar';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _toggleImageExpansion,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              height: 320,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: _isImageExpanded
                    ? []
                    : [
                        BoxShadow(
                          color:
                              (page['gradient'][0] as Color).withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
              ),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _isImageExpanded ? 0.0 : 1.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    page['image'],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                colors: page['gradient'] as List<Color>,
                begin: isArabic ? Alignment.centerRight : Alignment.centerLeft,
                end: isArabic ? Alignment.centerLeft : Alignment.centerRight,
              ).createShader(bounds);
            },
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 25,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: _isImageExpanded ? Colors.white : Colors.white,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              child: Text(
                page['title'],
                style: TextStyle(
                  color: _isImageExpanded ? Colors.white : Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: _isImageExpanded
                  ? Colors.white.withOpacity(0.9)
                  : const Color(0xFF9098B1),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
            child: Text(page['description']),
          ),
        ],
      ),
    );
  }

  // 👇 الصفحة الرابعة الجديدة مع صورتين لنظارات VR
  // الصفحة الرابعة - فقط عنوان وجملة واحدة
  Widget _buildVrPage(Map<String, dynamic> page, BuildContext context) {
    final isArabic =
        Provider.of<LanguageProvider>(context).locale.languageCode == 'ar';
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // صورتين لنظارات VR جنباً إلى جنب
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _toggleImageExpansion,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: _isImageExpanded
                          ? []
                          : [
                              BoxShadow(
                                color: AppUI.purplePrimary.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/6.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: _toggleImageExpansion,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: _isImageExpanded
                          ? []
                          : [
                              BoxShadow(
                                color: AppUI.purplePrimary.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/7.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          // العنوان فقط - اطلب نظارتك وابدأ رحلتك الافتراضية
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                colors: page['gradient'] as List<Color>,
                begin: isArabic ? Alignment.centerRight : Alignment.centerLeft,
                end: isArabic ? Alignment.centerLeft : Alignment.centerRight,
              ).createShader(bounds);
            },
            child: Text(
              page['title'], // سيأخذ الترجمة من المفتاح vr_equipment_title
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: Colors.white,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
