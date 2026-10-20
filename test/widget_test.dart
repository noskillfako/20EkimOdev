import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arackiralama/core/widgets/app_buttons.dart';
import 'package:arackiralama/core/widgets/rating_stars.dart';
import 'package:arackiralama/core/widgets/user_avatar.dart';

void main() {
  testWidgets('AppPrimaryButton renders text and triggers onPressed', (WidgetTester tester) async {
    bool pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppPrimaryButton(
            text: 'Test Buton',
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );

    expect(find.text('Test Buton'), findsOneWidget);
    await tester.tap(find.text('Test Buton'));
    expect(pressed, isTrue);
  });

  testWidgets('RatingStars renders stars and score text', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RatingStars(
            rating: 4.5,
            count: 24,
            starSize: 20,
          ),
        ),
      ),
    );

    expect(find.text('4.5'), findsOneWidget);
    expect(find.text('(24)'), findsOneWidget);
    expect(find.byType(Icon), findsWidgets);
  });

  testWidgets('UserAvatar displays initials and verified badge', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: UserAvatar(
            name: 'Ali Yılmaz',
            isVerified: true,
          ),
        ),
      ),
    );

    expect(find.text('AY'), findsOneWidget);
    expect(find.byIcon(Icons.verified_rounded), findsOneWidget);
  });
}
