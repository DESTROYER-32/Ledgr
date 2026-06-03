import 'package:csv/csv.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for CSV parsing logic
/// These test the CSV parsing math used in backup_screen.
void main() {
  group('CSV Parsing', () {
    test('parses valid CSV header + data rows', () {
      const csv = 'Date,Type,Amount,Title\n'
          '2024-06-01,expense,25.50,Groceries\n'
          '2024-06-02,income,1000.00,Salary\n';
      final rows = const CsvToListConverter(eol: '\n').convert(csv);
      expect(rows.length, 3);
      expect(rows[1][0], '2024-06-01');
      expect(rows[1][1], 'expense');
      expect(rows[1][3], 'Groceries');
    });

    test('handles empty CSV', () {
      const csv = 'Date,Type,Amount,Title\n';
      final rows = const CsvToListConverter(eol: '\n').convert(csv);
      expect(rows.length, 1);
    });

    test('handles CSV with extra columns', () {
      const csv = 'Date,Type,Amount,Title,Note,Tags\n'
          '2024-06-01,expense,25.50,Groceries,Weekly shopping,food\n';
      final rows = const CsvToListConverter(eol: '\n').convert(csv);
      expect(rows[1].length, 6);
    });

    test('handles CSV with quoted fields containing commas', () {
      const csv =
          'Date,Type,Amount,Title\n2024-06-01,expense,25.50,"Groceries, weekly"\n';
      final rows = const CsvToListConverter(eol: '\n').convert(csv);
      expect(rows[1][3], 'Groceries, weekly');
    });

    test('parses dates correctly from CSV', () {
      const csv = 'Date,Type,Amount,Title\n2024-06-01,expense,25.50,Test\n';
      final rows = const CsvToListConverter(eol: '\n').convert(csv);
      final dateStr = rows[1][0].toString();
      final date = DateTime.parse(dateStr);
      expect(date.year, 2024);
      expect(date.month, 6);
      expect(date.day, 1);
    });

    test('parses amounts correctly from CSV', () {
      const csv = 'Date,Type,Amount,Title\n2024-06-01,expense,25.50,Test\n';
      final rows = const CsvToListConverter(eol: '\n').convert(csv);
      final amount = double.tryParse(rows[1][2].toString()) ?? 0;
      expect(amount, 25.50);
    });

    test('skips invalid data rows gracefully', () {
      const csv = 'Date,Type,Amount,Title\n'
          'invalid-date,expense,abc,Test\n'
          '2024-06-01,expense,50.00,Valid\n';
      final rows = const CsvToListConverter(eol: '\n').convert(csv);
      var validCount = 0;
      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.length < 4) continue;
        final date = DateTime.tryParse(row[0].toString());
        final amount = double.tryParse(row[2].toString());
        if (date != null && amount != null) validCount++;
      }
      expect(validCount, 1);
    });
  });
}
