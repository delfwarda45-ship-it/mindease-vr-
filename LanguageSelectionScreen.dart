// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../backend/app_localizations.dart';
import '../backend/language_provider.dart';
import '../frontend/ui.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final locale = languageProvider.locale;

    return Directionality(
      textDirection:
          locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppUI.appBar(
          title: AppLocalizations.of(context)?.translate('language') ?? 'اللغة',
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // بطاقة إرشادية
              AppUI.card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.translate, color: AppUI.purplePrimary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)
                                  ?.translate('choose_language') ??
                              'اختر اللغة المناسبة لك',
                          style: AppUI.bodyText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: ListView(
                  children: [
                    _buildLanguageOption(
                      context,
                      AppLocalizations.of(context)?.translate('arabic') ??
                          'العربية',
                      'ar',
                      '🇸🇦',
                      'العربية',
                    ),
                    const Divider(height: 1),
                    _buildLanguageOption(
                      context,
                      AppLocalizations.of(context)?.translate('english') ??
                          'English',
                      'en',
                      '🇺🇸',
                      'English',
                    ),
                    const Divider(height: 1),
                    _buildLanguageOption(
                      context,
                      AppLocalizations.of(context)?.translate('french') ??
                          'Français',
                      'fr',
                      '🇫🇷',
                      'Français',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String name,
    String languageCode,
    String flag,
    String nativeName,
  ) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: true);
    final currentLocale = languageProvider.locale;
    final isSelected = currentLocale.languageCode == languageCode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          languageProvider.setLocale(Locale(languageCode));
          Navigator.pop(context);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            children: [
              // العلم
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppUI.borderColor),
                ),
                child: Center(
                  child: Text(
                    flag,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppUI.bodyText.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nativeName,
                      style: AppUI.captionText.copyWith(
                        color: AppUI.hintColor,
                      ),
                    ),
                  ],
                ),
              ),

              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppUI.primaryWhite,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
