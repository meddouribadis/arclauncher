import 'dart:async';

import 'package:flauncher/providers/network_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks.mocks.dart';

void main() {
  test("notifies listeners once the initial network information is loaded", () async {
    final channel = MockFLauncherChannel();
    final networkInfo = Completer<Map<String, dynamic>>();
    when(channel.getActiveNetworkInformation()).thenAnswer((_) => networkInfo.future);
    when(channel.checkUsageStatsPermission()).thenAnswer((_) async => false);

    final service = NetworkService(channel);
    await Future<void>.delayed(Duration.zero);

    int notifications = 0;
    service.addListener(() => notifications++);

    networkInfo.complete({"networkType": NetworkType.Wifi.index, "internetAccess": true, "wirelessSignalLevel": 3});
    await Future<void>.delayed(Duration.zero);

    expect(service.hasInternetAccess, isTrue);
    expect(service.networkType, NetworkType.Wifi);
    expect(service.wirelessNetworkSignalLevel, 3);
    expect(notifications, 1);
  });
}
