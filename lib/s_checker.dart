import 'dart:async';
import 'dart:io';

import 'package:s_network_connection_checker/models/ip_model.dart';
import 'package:s_state/s_state.dart';

import 'models/checker_model.dart';
import 'models/failed_model.dart';

class SNetworkConnectionChecker {
  static SNetworkConnectionChecker? _instance;
  static SNetworkConnectionChecker get instance {
    _instance ??= SNetworkConnectionChecker._init();
    return _instance!;
  }

  SNetworkConnectionChecker._init();
  List<SIpModel> _defaultUrls = [
    SIpModel("Google 1", "8.8.8.8", 53),
    SIpModel("Google 2", "8.8.4.4", 53),
  ];
  final isConnected = SState<bool>();
  late final selectedIp = SState(_defaultUrls.first); //  BehaviorSubject<IpModel>.seeded(defaultUrls.first);
  final failedPings = SState<List<SIpFailedModel>>([]);

  Timer? _timer;
  Duration _reTryDuration = const Duration(seconds: 3);
  Duration _pingTimeout = const Duration(seconds: 2);
  int _failedPingCount = 2;
  bool _isListened = false;

  void setConfig({Duration? reTryDuration, List<SIpModel>? urls, int? failedPingCount, Duration? pingTimeout}) {
    _reTryDuration = reTryDuration ?? const Duration(seconds: 3);
    _defaultUrls = urls ?? _defaultUrls;
    _failedPingCount = failedPingCount ?? 2;
    _pingTimeout = pingTimeout ?? const Duration(seconds: 2);
  }

  Future<bool> hasConnection() async {
    var res = await _checkNetwork();
    return res.isSuccess;
  }

  void startListen() async {
    if (_isListened) return;
    isConnected.setState(await hasConnection());
    _timer = Timer.periodic(_reTryDuration, (timer) {
      listen();
    });
    _isListened = true;
  }

  Future<SCheckerModel> _checkNetwork() async {
    try {
      var socket = await Socket.connect(
        selectedIp.valueOrNull!.ip,
        selectedIp.valueOrNull!.port,
        timeout: _pingTimeout,
      );
      socket.destroy();
      return SCheckerModel(true, null);
    } catch (e) {
      return SCheckerModel(false, e.toString());
    }
  }

  void listen() async {
    var response = await _checkNetwork();
    if (isConnected.valueOrNull != response.isSuccess) {
      if (response.isSuccess && (isConnected.valueOrNull == false || isConnected.valueOrNull == null)) {
        failedPings.setState([]);
        isConnected.setState(true);
      }
    }
    if (!response.isSuccess) {
      var pings = failedPings.valueOrNull ?? [];
      pings.insert(0, SIpFailedModel(selectedIp.valueOrNull!, DateTime.now().toIso8601String(), response.error));
      if (pings.length > 20) {
        pings.removeLast();
      }
      if (pings.length > _failedPingCount && (isConnected.valueOrNull == true || isConnected.valueOrNull == null)) {
        isConnected.setState(false);
      }
      failedPings.setState(pings);
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}
