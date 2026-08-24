import 'package:flutter_test/flutter_test.dart';

import 'package:cesizen_app/widgets/cesi_emoji.dart';

void main() {
  test('cesiEmotionFromCategoryName mappe les 6 émotions de base', () {
    expect(cesiEmotionFromCategoryName('Joie'),      CesiEmotion.joy);
    expect(cesiEmotionFromCategoryName('Colère'),    CesiEmotion.anger);
    expect(cesiEmotionFromCategoryName('Peur'),      CesiEmotion.fear);
    expect(cesiEmotionFromCategoryName('Tristesse'), CesiEmotion.sadness);
    expect(cesiEmotionFromCategoryName('Surprise'),  CesiEmotion.surprise);
    expect(cesiEmotionFromCategoryName('Dégoût'),    CesiEmotion.disgust);
    expect(cesiEmotionFromCategoryName(null),        CesiEmotion.neutral);
    expect(cesiEmotionFromCategoryName('Inconnue'),  CesiEmotion.neutral);
  });
}
