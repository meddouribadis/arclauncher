import 'package:arclauncher/providers/network_service.dart';
import 'package:arclauncher/widgets/network_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../mocks.mocks.dart';

void main() {
  Future<void> pumpNetworkWidget(WidgetTester tester, {required bool vpn}) async {
    final channel = MockFLauncherChannel();
    when(channel.getActiveNetworkInformation()).thenAnswer(
      (_) async => {
        "networkType": NetworkType.Wifi.index,
        "internetAccess": true,
        "wirelessSignalLevel": 3,
        "vpn": vpn,
      },
    );
    when(channel.checkUsageStatsPermission()).thenAnswer((_) async => false);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => NetworkService(channel),
        child: const MaterialApp(home: NetworkWidget()),
      ),
    );
    await tester.pump();
  }

  testWidgets("shows Wi-Fi icon with a key badge when VPN is active", (tester) async {
    await pumpNetworkWidget(tester, vpn: true);

    expect(find.byIcon(Icons.network_wifi_3_bar), findsOneWidget);
    expect(find.byKey(const Key("vpn_badge")), findsOneWidget);
  });

  testWidgets("shows Wi-Fi icon without badge when VPN is inactive", (tester) async {
    await pumpNetworkWidget(tester, vpn: false);

    expect(find.byIcon(Icons.network_wifi_3_bar), findsOneWidget);
    expect(find.byKey(const Key("vpn_badge")), findsNothing);
  });
}
