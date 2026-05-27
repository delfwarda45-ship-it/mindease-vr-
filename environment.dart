import 'package:flutter/material.dart';

class VREnvironment {
  final String id;
  final String title;
  final String description;
  final String type;
  final String category;
  final String videoAssetPath;
  final String imageAssetPath;
  final int duration;
  final double rating;
  final int views;
  final Map<String, String> localizedTitles;
  final Map<String, String> localizedDescriptions;

  VREnvironment({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.videoAssetPath,
    required this.imageAssetPath,
    required this.duration,
    this.rating = 4.0,
    this.views = 0,
    required this.localizedTitles,
    required this.localizedDescriptions,
  });

  // Helper methods
  String get durationText {
    return '$duration min';
  }

  Color get typeColor {
    switch (type.toLowerCase()) {
      case 'exposure':
        return Colors.red;
      case 'relaxation':
        return Colors.teal;
      case 'mindfulness':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String getTranslatedTitle(String languageCode) {
    return localizedTitles[languageCode] ?? title;
  }

  String getTranslatedType(String languageCode) {
    final typeMap = {
      'en': {
        'relaxation': 'Relaxation',
        'exposure': 'Exposure',
        'mindfulness': 'Mindfulness'
      },
      'ar': {
        'relaxation': 'استرخاء',
        'exposure': 'تعريض',
        'mindfulness': 'يقظة ذهنية'
      },
      'fr': {
        'relaxation': 'Relaxation',
        'exposure': 'Exposition',
        'mindfulness': 'Pleine conscience'
      },
    };

    final normalizedType = type.toLowerCase();
    return typeMap[languageCode]?[normalizedType] ?? type;
  }

  // Get translated duration text based on language code
  String getTranslatedDuration(String languageCode, BuildContext context) {
    final minText = languageCode == 'ar'
        ? 'دقيقة'
        : languageCode == 'fr'
            ? 'min'
            : 'min';
    return '$duration $minText';
  }
}
