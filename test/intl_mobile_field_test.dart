import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl_mobile_field/countries.dart';
import 'package:intl_mobile_field/flags_drop_down.dart';
import 'package:intl_mobile_field/intl_mobile_field.dart';

class TestWidget extends StatelessWidget {
  const TestWidget({super.key, required this.mobileNumber, this.countryCode});

  final String mobileNumber;
  final String? countryCode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Test Intl Mobile Field',
        home: Scaffold(
          appBar: AppBar(title: const Text("")),
          body: IntlMobileField(
            initialValue: mobileNumber,
          ),
        ));
  }
}

class CountryPickerTestWidget extends StatelessWidget {
  const CountryPickerTestWidget({
    super.key,
    required this.showField,
    this.onCountryChanged,
  });

  final ValueNotifier<bool> showField;
  final ValueChanged<Country>? onCountryChanged;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ValueListenableBuilder<bool>(
          valueListenable: showField,
          builder: (context, isVisible, child) {
            if (!isVisible) {
              return const SizedBox(key: ValueKey('removed-field'));
            }

            return IntlMobileField(
              flagsButtonKey: const ValueKey('flags-button'),
              initialCountryCode: 'BD',
              onCountryChanged: onCountryChanged,
            );
          },
        ),
      ),
    );
  }
}

class FlagsDropDownTestWidget extends StatelessWidget {
  const FlagsDropDownTestWidget({
    super.key,
    required this.showDropDown,
    this.onCountryChanged,
  });

  final ValueNotifier<bool> showDropDown;
  final ValueChanged<Country>? onCountryChanged;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ValueListenableBuilder<bool>(
          valueListenable: showDropDown,
          builder: (context, isVisible, child) {
            if (!isVisible) {
              return const SizedBox(key: ValueKey('removed-dropdown'));
            }

            return FlagsDropDown(
              countries: countries,
              initialCountryCode: 'BD',
              onCountryChanged: onCountryChanged,
            );
          },
        ),
      ),
    );
  }
}

Future<void> chooseCountry(
  WidgetTester tester, {
  required String countryName,
}) async {
  await tester.tap(find.text('+880'));
  await tester.pumpAndSettle();

  expect(find.text('Search Country'), findsOneWidget);
  await tester.enterText(
    find.descendant(of: find.byType(Dialog), matching: find.byType(TextField)),
    countryName,
  );
  await tester.pump();
  await tester.tap(find.widgetWithText(ListTile, countryName));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Test intl_mobile_field setup with completeNumber',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TestWidget(
      mobileNumber: '+447891234467',
    ));

    final countryCodeFinder = find.text('+44');
    final numberFinder = find.text('7891234467');

    expect(countryCodeFinder, findsOneWidget);
    expect(numberFinder, findsOneWidget);
  });

  testWidgets('Test intl_mobile_field setup with Guernsey number: +44960194',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TestWidget(
      mobileNumber: '+44960194',
      countryCode: 'GG',
    ));

    final countryCodeFinder = find.text('+44');
    final numberFinder = find.text('960194');

    expect(countryCodeFinder, findsOneWidget);
    expect(numberFinder, findsOneWidget);
  });

  testWidgets('Test intl_mobile_field setup with UK number: +447891244567',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TestWidget(
      mobileNumber: '+447891244567',
      countryCode: 'GB',
    ));

    final countryCodeFinder = find.text('+44');
    final numberFinder = find.text('7891244567');

    expect(countryCodeFinder, findsOneWidget);
    expect(numberFinder, findsOneWidget);
  });

  testWidgets('Country selection does not notify a disposed IntlMobileField',
      (WidgetTester tester) async {
    final showField = ValueNotifier<bool>(true);
    final changedCountries = <String>[];

    await tester.pumpWidget(
      CountryPickerTestWidget(
        showField: showField,
        onCountryChanged: (country) => changedCountries.add(country.code),
      ),
    );

    await tester.tap(find.text('+880'));
    await tester.pumpAndSettle();
    expect(find.text('Search Country'), findsOneWidget);

    showField.value = false;
    await tester.pump();
    expect(find.byKey(const ValueKey('removed-field')), findsOneWidget);
    expect(find.text('Search Country'), findsOneWidget);

    await tester.enterText(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.byType(TextField),
      ),
      'Japan',
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(ListTile, 'Japan'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(changedCountries, isEmpty);

    showField.dispose();
  });

  testWidgets('Country selection does not notify a disposed FlagsDropDown',
      (WidgetTester tester) async {
    final showDropDown = ValueNotifier<bool>(true);
    final changedCountries = <String>[];

    await tester.pumpWidget(
      FlagsDropDownTestWidget(
        showDropDown: showDropDown,
        onCountryChanged: (country) => changedCountries.add(country.code),
      ),
    );

    await tester.tap(find.text('+880'));
    await tester.pumpAndSettle();
    expect(find.text('Search Country'), findsOneWidget);

    showDropDown.value = false;
    await tester.pump();
    expect(find.byKey(const ValueKey('removed-dropdown')), findsOneWidget);
    expect(find.text('Search Country'), findsOneWidget);

    await tester.enterText(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.byType(TextField),
      ),
      'Japan',
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(ListTile, 'Japan'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(changedCountries, isEmpty);

    showDropDown.dispose();
  });

  testWidgets('Country selection updates the field and notifies once',
      (WidgetTester tester) async {
    final showField = ValueNotifier<bool>(true);
    final changedCountries = <String>[];

    await tester.pumpWidget(
      CountryPickerTestWidget(
        showField: showField,
        onCountryChanged: (country) => changedCountries.add(country.code),
      ),
    );

    expect(find.text('+880'), findsOneWidget);

    await chooseCountry(tester, countryName: 'Japan');

    expect(tester.takeException(), isNull);
    expect(changedCountries, ['JP']);
    expect(find.text('+81'), findsOneWidget);
    expect(find.text('+880'), findsNothing);

    showField.dispose();
  });

  testWidgets('Country callback can remove the field without an exception',
      (WidgetTester tester) async {
    final showField = ValueNotifier<bool>(true);
    final changedCountries = <String>[];

    await tester.pumpWidget(
      CountryPickerTestWidget(
        showField: showField,
        onCountryChanged: (country) {
          changedCountries.add(country.code);
          showField.value = false;
        },
      ),
    );

    await chooseCountry(tester, countryName: 'Japan');

    expect(tester.takeException(), isNull);
    expect(changedCountries, ['JP']);
    expect(find.byKey(const ValueKey('removed-field')), findsOneWidget);

    showField.dispose();
  });
}
