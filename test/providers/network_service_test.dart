import 'package:flauncher/providers/network_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks.mocks.dart';

void main() {
  late MockFLauncherChannel mockChannel;
  late NetworkService networkService;

  setUp(() {
    mockChannel = MockFLauncherChannel();
    when(mockChannel.getActiveNetworkInformation())
        .thenAnswer((_) async => <String, dynamic>{});
    when(mockChannel.checkUsageStatsPermission())
        .thenAnswer((_) async => false);
    networkService = NetworkService(mockChannel);
  });

  group('getWifiUsageForPeriod', () {
    test('returns daily usage when period is "daily"', () async {
      when(mockChannel.getDailyWifiUsage()).thenAnswer((_) async => 100);

      final result = await networkService.getWifiUsageForPeriod('daily');

      expect(result, 100);
      verify(mockChannel.getDailyWifiUsage()).called(1);
      verifyNever(mockChannel.getWeeklyWifiUsage());
      verifyNever(mockChannel.getMonthlyWifiUsage());
    });

    test('returns weekly usage when period is "weekly"', () async {
      when(mockChannel.getWeeklyWifiUsage()).thenAnswer((_) async => 500);

      final result = await networkService.getWifiUsageForPeriod('weekly');

      expect(result, 500);
      verify(mockChannel.getWeeklyWifiUsage()).called(1);
      verifyNever(mockChannel.getDailyWifiUsage());
      verifyNever(mockChannel.getMonthlyWifiUsage());
    });

    test('returns monthly usage when period is "monthly"', () async {
      when(mockChannel.getMonthlyWifiUsage()).thenAnswer((_) async => 2000);

      final result = await networkService.getWifiUsageForPeriod('monthly');

      expect(result, 2000);
      verify(mockChannel.getMonthlyWifiUsage()).called(1);
      verifyNever(mockChannel.getDailyWifiUsage());
      verifyNever(mockChannel.getWeeklyWifiUsage());
    });

    test('returns daily usage when period is unknown', () async {
      when(mockChannel.getDailyWifiUsage()).thenAnswer((_) async => 100);

      final result = await networkService.getWifiUsageForPeriod('unknown_period');

      expect(result, 100);
      verify(mockChannel.getDailyWifiUsage()).called(1);
      verifyNever(mockChannel.getWeeklyWifiUsage());
      verifyNever(mockChannel.getMonthlyWifiUsage());
    });
  });
}
