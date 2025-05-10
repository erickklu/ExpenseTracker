import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_expense_tracker/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen has a title and a list of expenses', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: HomeScreen()));

    expect(find.text('Expense Tracker'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('Add Expense button is present', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: HomeScreen()));

    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}