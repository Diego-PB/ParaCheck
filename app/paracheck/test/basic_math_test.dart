import 'package:flutter_test/flutter_test.dart';

// Diego : "C'est jute un test de base pour faire des tests avec la ci etc, n'a pas d'impacte si suprimé"

void main() {
  group('Math', () {
    test('5 + 5 = 10', () {
      expect(5 + 5, 10);
      // équivalent : expect(5 + 5, equals(10));
    });
  });
}
