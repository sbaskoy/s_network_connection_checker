import 'package:flutter/material.dart';

import 'package:s_network_connection_checker/s_checker.dart';

class SNetworkConnectionCheckerWidget extends StatelessWidget {
  final Widget child;
  final Widget Function()? loadingBuilder;
  final Widget Function()? disConnectedBuilder;
  final VoidCallback? onConnected;

  const SNetworkConnectionCheckerWidget(
      {super.key, required this.child, this.loadingBuilder, this.disConnectedBuilder, this.onConnected});

  @override
  Widget build(BuildContext context) {
    SNetworkConnectionChecker.instance.startListen();
    return SNetworkConnectionChecker.instance.isConnected.builder((loading, data, error, context) {
      if (data == false) {
        if (disConnectedBuilder != null) {
          return disConnectedBuilder!();
        } else {
          return const Center(child: Text("No connection"));
        }
      }
      if (data == true) {
        if (onConnected != null) {
          onConnected!();
        }
        return child;
      }
      if (loadingBuilder != null) {
        return loadingBuilder!();
      }
      return const Center(child: CircularProgressIndicator());
    });
  }
}
