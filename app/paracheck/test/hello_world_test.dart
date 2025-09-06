import 'package:flutter_test/flutter_test.dart';
import 'package:paracheck/main.dart'; // adapte si ton entrypoint a un autre chemin

void main() {
  testWidgets('Affiche "Hello World" et pas un autre texte', (tester) async {
    await tester.pumpWidget(const MyApp());

    // Présence exacte de "Hello World"
    expect(find.text('Hello World'), findsOneWidget);

    // Absence d’un texte non attendu
    expect(find.text('Goodbye World'), findsNothing);
    expect(find.text('Bonjour le monde'), findsNothing);
  });
}
