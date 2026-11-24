import 'package:arclauncher/providers/network_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NetworkWidget extends StatelessWidget
{
  final bool interactive;

  const NetworkWidget({super.key, this.interactive = false});

  @override
  Widget build(BuildContext context) {
    return Selector<NetworkService, (NetworkType, CellularNetworkType, int)>(
      selector: (_, ns) => (ns.networkType, ns.cellularNetworkType, ns.wirelessNetworkSignalLevel),
      builder: (context, state, _) {
        final (networkType, cellularNetworkType, wirelessSignalLevel) = state;
        final networkService = context.read<NetworkService>();
        IconData iconData;
        Color? iconColor;

        switch (networkType)
        {
          case NetworkType.Cellular:
            switch (cellularNetworkType)
            {
              case CellularNetworkType.Cdma || CellularNetworkType.Gsm || CellularNetworkType.Gprs:
                iconData = Icons.g_mobiledata;

              case CellularNetworkType.Edge: iconData = Icons.e_mobiledata;

              case CellularNetworkType.Hspa || CellularNetworkType.Hsdpa || CellularNetworkType.Hsupa:
                iconData = Icons.h_mobiledata;

              case CellularNetworkType.Hspap: iconData = Icons.h_plus_mobiledata;

              case CellularNetworkType.Umts || CellularNetworkType.TdScdma:
                iconData = Icons.three_g_mobiledata; break;

              case CellularNetworkType.Lte: iconData = Icons.four_g_mobiledata_outlined; break;
              case CellularNetworkType.Nr: iconData = Icons.five_g;

              default: iconData = Icons.question_mark; break;
            }
            break;
          case NetworkType.Wifi:
            if (wirelessSignalLevel == 0) {
              iconData = Icons.signal_wifi_0_bar;
            }
            else if (wirelessSignalLevel == 1) {
              iconData = Icons.network_wifi_1_bar;
            }
            else if (wirelessSignalLevel == 2) {
              iconData = Icons.network_wifi_2_bar;
            }
            else if (wirelessSignalLevel == 3) {
              iconData = Icons.network_wifi_3_bar;
            }
            else {
              iconData = Icons.signal_wifi_4_bar;
            }
            break;
          case NetworkType.Vpn: iconData = Icons.vpn_key; break;
          case NetworkType.Wired: iconData = Icons.lan; break;
          case NetworkType.Unknown: 
            iconData = Icons.link_off;
            iconColor = Colors.red; // Make no connection icon red
            break;
        }

        final iconWidget = Padding(
          padding: const EdgeInsets.all(4.0),
          child: Icon(
            iconData,
            size: 20,
            color: iconColor,
            shadows: const [
              Shadow(
                color: Colors.black54,
                offset: Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
        );

        if (!interactive) {
          return iconWidget;
        }

        return InkWell(
          onTap: () => networkService.openWifiSettings(),
          borderRadius: BorderRadius.circular(8),
          child: iconWidget,
        );
      },
    );
  }
}
