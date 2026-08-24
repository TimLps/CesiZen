import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/emotion.dart';

/// Émotion saisie par un visiteur anonyme : conservée en mémoire seulement,
/// jamais persistée. Effacée au redémarrage de l'app, conformément au sujet
/// CESIZen (« le visiteur peut renseigner son émotion mais elle n'est pas
/// enregistrée »).
class TransientEmotion {
  final Emotion emotion;
  final EmotionCategory category;
  final DateTime createdAt;

  const TransientEmotion({
    required this.emotion,
    required this.category,
    required this.createdAt,
  });
}

final transientEmotionProvider =
    StateProvider<TransientEmotion?>((ref) => null);
