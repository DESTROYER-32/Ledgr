import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:budgetly/core/database/app_database.dart';
import 'package:budgetly/core/database/repositories/settings_repository.dart';
import 'package:budgetly/core/services/exchange_rate_service.dart';

void main() {
  const rateUrl = 'https://example.test/usd.json';
  const rateBody = '{"date":"2026-06-06","usd":{"usd":1,"eur":0.91,"jpy":150}}';

  late AppDatabase db;
  late SettingsRepository settings;

  ExchangeRateService buildService(http.Client client) {
    return ExchangeRateService(settings, client: client, apiUrls: [rateUrl]);
  }

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    settings = SettingsRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('successful fetch saves and returns rates', () async {
    final service = buildService(
      MockClient((_) async => http.Response(rateBody, 200)),
    );

    final rates = await service.fetchRates();
    expect(rates['usd'], 1.0);
    expect(rates['eur'], 0.91);
    expect(rates['jpy'], 150.0);

    final cachedService = buildService(
      MockClient((_) async => throw Exception('offline')),
    );
    final cachedRates = await cachedService.fetchRates();
    expect(cachedRates['eur'], 0.91);
  });

  test('network failure uses cached rates', () async {
    var calls = 0;
    final service = buildService(
      MockClient((_) async {
        calls += 1;
        if (calls == 1) return http.Response(rateBody, 200);
        throw Exception('offline');
      }),
    );

    expect((await service.fetchRates())['eur'], 0.91);
    expect((await service.fetchRates())['eur'], 0.91);
    expect(calls, 2);
  });

  test('network failure with no cache reports failure', () async {
    final service = buildService(
      MockClient((_) async => throw Exception('offline')),
    );

    await expectLater(
      service.fetchRates(),
      throwsA(isA<ExchangeRateException>()),
    );
    await expectLater(
      service.getAllRates(refresh: true),
      throwsA(isA<ExchangeRateException>()),
    );
  });

  test('custom rates override fetched rates in settings data', () async {
    final service = buildService(
      MockClient((_) async => http.Response(rateBody, 200)),
    );

    await service.setCustomRate('EUR', 0.95);
    final rates = await service.getAllRates(refresh: true);

    expect(rates['eur'], 0.95);
    expect(rates['jpy'], 150.0);
  });

  test('removing a custom rate restores fetched rate on refresh', () async {
    final service = buildService(
      MockClient((_) async => http.Response(rateBody, 200)),
    );

    await service.setCustomRate('EUR', 0.95);
    expect((await service.getAllRates(refresh: true))['eur'], 0.95);

    await service.removeCustomRate('EUR');
    expect((await service.getAllRates(refresh: true))['eur'], 0.91);
  });

  test('conversion fetches rates when cache is empty', () async {
    var calls = 0;
    final service = buildService(
      MockClient((_) async {
        calls += 1;
        return http.Response(rateBody, 200);
      }),
    );

    final eur = await service.convert(10000, 'USD', 'EUR');
    final jpy = await service.convert(10000, 'USD', 'JPY');

    expect(eur, 9100);
    expect(jpy, 15000);
    expect(calls, 1);
  });

  test('dated conversion uses cached snapshot for transaction date', () async {
    var calls = 0;
    final service = buildService(
      MockClient((_) async {
        calls += 1;
        if (calls == 1) return http.Response(rateBody, 200);
        return http.Response(
          '{"date":"2026-06-07","usd":{"usd":1,"eur":0.8,"jpy":140}}',
          200,
        );
      }),
    );

    await service.fetchRates();
    await service.fetchRates();

    expect(
      await service.convert(10000, 'USD', 'EUR', onDate: DateTime(2026, 6, 6)),
      9100,
    );
    expect(
      await service.convert(10000, 'USD', 'EUR', onDate: DateTime(2026, 6, 7)),
      8000,
    );
  });
}
