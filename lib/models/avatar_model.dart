// ─────────────────────────────────────────────────────────────────────────────
// Avatar Model
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AvatarModel {
  final String id;
  final String name;
  final String emoji;         // placeholder until real SVG assets added
  final String personality;   // shown as a tag under the avatar
  final String tagline;       // one-liner that sets the vibe
  final Color accentColor;
  final Color bgColor;

  const AvatarModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.personality,
    required this.tagline,
    required this.accentColor,
    required this.bgColor,
  });
}

const kAvatars = [
  AvatarModel(
    id: 'mia',
    name: 'Mia',
    emoji: '👩‍🏫',
    personality: 'Friendly',
    tagline: 'Patient and encouraging',
    accentColor: AppColors.primary,
    bgColor: AppColors.lBlue,
  ),
  AvatarModel(
    id: 'kai',
    name: 'Kai',
    emoji: '🧑‍💻',
    personality: 'Hype',
    tagline: 'Keeps energy high',
    accentColor: AppColors.purple,
    bgColor: AppColors.lPurple,
  ),
  AvatarModel(
    id: 'zara',
    name: 'Zara',
    emoji: '👩‍🎤',
    personality: 'Playful',
    tagline: 'Makes it fun',
    accentColor: AppColors.pink,
    bgColor: AppColors.lPink,
  ),
  AvatarModel(
    id: 'leo',
    name: 'Leo',
    emoji: '🦁',
    personality: 'Strict',
    tagline: 'No excuses, all results',
    accentColor: AppColors.orange,
    bgColor: AppColors.lOrange,
  ),
  AvatarModel(
    id: 'nova',
    name: 'Nova',
    emoji: '🚀',
    personality: 'Wise',
    tagline: 'Deep insights, calm pace',
    accentColor: AppColors.teal,
    bgColor: AppColors.lTeal,
  ),
  AvatarModel(
    id: 'remy',
    name: 'Remy',
    emoji: '🎸',
    personality: 'Chill',
    tagline: 'Low pressure, high vibes',
    accentColor: AppColors.tealLight,
    bgColor: AppColors.lTeal,
  ),
  AvatarModel(
    id: 'atlas',
    name: 'Atlas',
    emoji: '🌍',
    personality: 'Explorer',
    tagline: 'Loves cultural deep-dives',
    accentColor: AppColors.primaryLight,
    bgColor: AppColors.lBlue,
  ),
  AvatarModel(
    id: 'luna',
    name: 'Luna',
    emoji: '🌙',
    personality: 'Calm',
    tagline: 'Gentle and reflective',
    accentColor: AppColors.purpleLight,
    bgColor: AppColors.lPurple,
  ),
  AvatarModel(
    id: 'rio',
    name: 'Rio',
    emoji: '🏄',
    personality: 'Active',
    tagline: 'Keeps lessons short and sharp',
    accentColor: AppColors.orangeLight,
    bgColor: AppColors.lOrange,
  ),
  AvatarModel(
    id: 'sage',
    name: 'Sage',
    emoji: '🌿',
    personality: 'Mindful',
    tagline: 'Steady progress every day',
    accentColor: AppColors.teal,
    bgColor: AppColors.lTeal,
  ),
];
