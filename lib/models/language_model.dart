import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LanguageModel {
  final String code;
  final String name;
  final String nativeName;
  final String flag;
  final String speakers;
  final bool isRtl;
  final Color accentColor;
  final Color bgColor;
  final String funFact;

  const LanguageModel({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
    required this.speakers,
    required this.isRtl,
    required this.accentColor,
    required this.bgColor,
    required this.funFact,
  });
}

const kLanguages = [
  LanguageModel(
    code: 'es',
    name: 'Spanish',
    nativeName: 'Español',
    flag: '🇪🇸',
    speakers: '485M+ speakers',
    isRtl: false,
    accentColor: Color(0xFFC60B1E),
    bgColor: Color(0xFFFFF3F3),
    funFact: '21 countries speak it as their official language',
  ),
  LanguageModel(
    code: 'fr',
    name: 'French',
    nativeName: 'Français',
    flag: '🇫🇷',
    speakers: '280M+ speakers',
    isRtl: false,
    accentColor: Color(0xFF0055A4),
    bgColor: Color(0xFFF0F4FF),
    funFact: 'The language of diplomacy for 300 years',
  ),
  LanguageModel(
    code: 'ar',
    name: 'Arabic',
    nativeName: 'العربية',
    flag: '🇦🇪',
    speakers: '310M+ speakers',
    isRtl: true,
    accentColor: Color(0xFF009640),
    bgColor: Color(0xFFEFF8F2),
    funFact: 'Written right-to-left — we handle this for you',
  ),
  LanguageModel(
    code: 'ur',
    name: 'Urdu',
    nativeName: 'اردو',
    flag: '🇵🇰',
    speakers: '230M+ speakers',
    isRtl: true,
    accentColor: AppColors.teal,
    bgColor: AppColors.lTeal,
    funFact: 'One of the most poetic languages in the world',
  ),
  LanguageModel(
    code: 'en',
    name: 'English',
    nativeName: 'English',
    flag: '🇬🇧',
    speakers: '1.5B+ speakers',
    isRtl: false,
    accentColor: Color(0xFF012169),
    bgColor: Color(0xFFF0F4FF),
    funFact: 'The global language of business and travel',
  ),
];
