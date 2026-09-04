import 'package:flutter_test/flutter_test.dart';

import 'package:pdf_maker/main.dart';

void main() {
  testWidgets('home page opens the exam setup flow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PdfMakerApp());

    expect(find.text('Maker'), findsOneWidget);
    expect(find.text('Belge oluştur'), findsOneWidget);
    expect(find.text('Henüz belgen yok'), findsOneWidget);

    await tester.tap(find.text('Belge oluştur'));
    await tester.pumpAndSettle();

    expect(find.text('Ne hazırlıyorsun?'), findsOneWidget);
    expect(find.text('Sınav'), findsOneWidget);

    await tester.tap(find.text('Sınav'));
    await tester.pumpAndSettle();

    expect(find.text('Yeni sınav'), findsOneWidget);
    expect(find.text('Sınav başlığı'), findsOneWidget);

    await tester.tap(find.text('İçerik eklemeye geç'));
    await tester.pumpAndSettle();

    expect(find.text('Sınav içeriği'), findsOneWidget);
    expect(find.text('İlk sayfanı ekle'), findsOneWidget);
    expect(find.text('Kamerayla çek'), findsOneWidget);
    expect(find.text('Galeriden seç'), findsOneWidget);
  });
}
