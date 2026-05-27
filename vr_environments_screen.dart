import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../frontend/ui.dart';
import 'environment.dart';
import 'video_player_screen.dart';
import '../backend/app_localizations.dart';
import '../backend/language_provider.dart';

class VREnvironmentsScreen extends StatefulWidget {
  const VREnvironmentsScreen({Key? key}) : super(key: key);

  @override
  State<VREnvironmentsScreen> createState() => _VREnvironmentsScreenState();
}

class _VREnvironmentsScreenState extends State<VREnvironmentsScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  List<String> get _categories {
    final l10n = AppLocalizations.of(context);
    return [
      l10n?.translate('all') ?? 'All',
      l10n?.translate('relaxation') ?? 'Relaxation',
      l10n?.translate('exposure') ?? 'Exposure',
      l10n?.translate('mindfulness') ?? 'Mindfulness'
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getEnglishCategory(String localizedCategory, BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (localizedCategory == (l10n?.translate('all') ?? 'All')) return 'All';
    if (localizedCategory == (l10n?.translate('relaxation') ?? 'Relaxation'))
      return 'Relaxation';
    if (localizedCategory == (l10n?.translate('exposure') ?? 'Exposure'))
      return 'Exposure';
    if (localizedCategory == (l10n?.translate('mindfulness') ?? 'Mindfulness'))
      return 'Mindfulness';

    return 'All';
  }

  String _normalizeType(String type) {
    return type.toLowerCase();
  }

  List<VREnvironment> get _filteredEnvironments {
    final englishCategory = _getEnglishCategory(_selectedCategory, context);

    return sampleEnvironments.where((env) {
      final matchesSearch = env.title
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          env.description.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = englishCategory == 'All' ||
          _normalizeType(env.type) == _normalizeType(englishCategory);

      return matchesSearch && matchesCategory;
    }).toList();
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
        appBar: AppUI.appBar(
          title: l10n?.translate('vr_environments') ?? 'VR Environments',
          useGradient: true,
        ),
        body: Column(
          children: [
            _buildHeaderAndSearch(context),
            _buildCategoryFilter(context),
            Expanded(
              child: _filteredEnvironments.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: _filteredEnvironments.length,
                      itemBuilder: (context, index) {
                        return _buildImmersiveCard(
                            _filteredEnvironments[index], context);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderAndSearch(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppUI.purplePrimary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              textDirection:
                  AppLocalizations.of(context)?.locale.languageCode == 'ar'
                      ? TextDirection.rtl
                      : TextDirection.ltr,
              decoration: InputDecoration(
                hintText: l10n?.translate('search_environments') ??
                    'Search for an environment...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon:
                    const Icon(Icons.search, color: AppUI.purplePrimary),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    AppLocalizations.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: _categories.map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [AppUI.purplePrimary, AppUI.purpleSecondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected ? null : Colors.white,
                  border: Border.all(
                    color: isSelected ? Colors.transparent : Colors.grey[300]!,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildImmersiveCard(VREnvironment environment, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    final languageCode = languageProvider.locale.languageCode;

    final translatedType = environment.getTranslatedType(languageCode);
    final translatedDuration =
        environment.getTranslatedDuration(languageCode, context);

    return Container(
      height: 220,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                environment.imageAssetPath,
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: const [0.5, 0.7, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppUI.purplePrimary.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  translatedType.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment:
                      AppLocalizations.of(context)?.locale.languageCode == 'ar'
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                  children: [
                    Text(
                      environment.getTranslatedTitle(languageCode),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(blurRadius: 4, color: Colors.black45)],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(Icons.timer_outlined,
                            color: Colors.white70, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          translatedDuration,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          environment.rating.toString(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          '${environment.views} ${l10n?.translate('views') ?? 'views'}',
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoPlayerScreen(
                          environment: environment,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            l10n?.translate('no_environment_found') ?? 'No environment found',
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }
}

List<VREnvironment> sampleEnvironments = [
  VREnvironment(
    id: 'intro_video',
    title: 'الفيديو التعريفي بالتطبيق',
    description: 'تعريف بتقنية العلاج بالواقع الافتراضي',
    type: 'Relaxation',
    category: 'intro',
    videoAssetPath: 'assets/videos/6.mp4',
    imageAssetPath: 'assets/4.png', //
    duration: 5,
    rating: 5.0,
    views: 0,
    localizedTitles: {
      'ar': 'الفيديو التعريفي بالتطبيق',
      'en': 'App Introduction Video',
      'fr': 'Vidéo d\'introduction'
    },
    localizedDescriptions: {
      'ar': 'تعريف بتقنية العلاج بالواقع الافتراضي',
      'en': 'Introduction to VR therapy',
      'fr': 'Introduction à la thérapie VR'
    },
  ),
  VREnvironment(
    id: 'beach',
    title: 'Relaxation', // تم التعديل: أصبح مطابقاً للعربية
    description: 'Calm environment for relaxation', // تم التعديل: وصف عام
    type: 'Relaxation',
    category: 'stress',
    videoAssetPath: 'assets/videos/1.mp4',
    imageAssetPath: 'assets/1.png',
    duration: 15,
    rating: 4.5,
    views: 1250,
    localizedTitles: {
      'ar': 'استرخاء',
      'en': 'Relaxation',
      'fr': 'Relaxation',
    },
    localizedDescriptions: {
      'ar': 'بيئة هادئة للاسترخاء',
      'en': 'Calm environment for relaxation',
      'fr': 'Environnement calme pour la relaxation',
    },
  ),
  VREnvironment(
    id: 'exposure_open',
    title: 'Exposure', // تم التعديل
    description: 'Progressive exposure therapy',
    type: 'Exposure',
    category: 'anxiety',
    videoAssetPath: 'assets/videos/2.mp4',
    imageAssetPath: 'assets/2.png',
    duration: 25,
    rating: 4.2,
    views: 980,
    localizedTitles: {'ar': 'التعرض', 'en': 'Exposure', 'fr': 'Exposition'},
    localizedDescriptions: {
      'ar': 'علاج التعرض التدريجي',
      'en': 'Progressive exposure therapy',
      'fr': 'Thérapie d\'exposition progressive'
    },
  ),
];
