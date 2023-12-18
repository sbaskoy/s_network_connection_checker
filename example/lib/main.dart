import 'package:flutter/material.dart';
import 'package:s_network_connection_checker/s_network_connection_checker.dart';


void main() async {
  var hasConnection = await SNetworkConnectionChecker.instance.hasConnection();
  SNetworkConnectionChecker.instance.selectedIp.setState(SIpModel("Google 1", "8.8.8.8", 53));
  SNetworkConnectionChecker.instance.setConfig(
    failedPingCount: 2,
    pingTimeout: const Duration(seconds: 2),
    reTryDuration: const Duration(seconds: 3),
    urls: [
      SIpModel("Google 1", "8.8.8.8", 53),
      SIpModel("Google 2", "8.8.4.4", 53),
    ],
  );

  print("Has connection $hasConnection");
  runApp(const FullScreenWarningWithOpacity());
}

class BasicExample extends StatelessWidget {
  const BasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    // listen
    SNetworkConnectionChecker.instance.isConnected.listen(
      (value) {
        print("Connection status changed");
      },
    );
    return MaterialApp(
      title: 'SNetwork connection checker example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return Scaffold(
          body: SNetworkConnectionCheckerWidget(
            loadingBuilder: () {
              return const Center(child: Text("Loading"));
            },
            disConnectedBuilder: () {
              return const Center(child: Text("Custom disconnected page"));
            },
            child: child!,
          ),
        );
      },
      home: const Scaffold(
        body: Center(
          child: Text("Connected"),
        ),
      ),
    );
  }
}

class FullScreenWarningWithOpacity extends StatelessWidget {
  const FullScreenWarningWithOpacity({super.key});

  @override
  Widget build(BuildContext context) {
    // IMPORTANT
    SNetworkConnectionChecker.instance.startListen();
    return MaterialApp(
      title: 'SNetwork connection checker example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return Scaffold(
          body: SNetworkConnectionChecker.instance.isConnected.builder((loading, isConnected, error, context) {
            if (isConnected == null) {
              return const Center(
                child: Text("Loading"),
              );
            }
            return Stack(
              children: [
                AnimatedOpacity(
                  opacity: isConnected ? 1 : 0.1,
                  duration: const Duration(milliseconds: 100),
                  child: IgnorePointer(
                    ignoring: isConnected == false,
                    child: child,
                  ),
                ),
                if (!isConnected)
                  const Align(
                    alignment: Alignment.center,
                    child: Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("No connection"),
                        Text("Please check your network connection"),
                      ],
                    )),
                  )
              ],
            );
          }),
        );
      },
      home: const Scaffold(
        body: Center(
          child: Text("Home page"),
        ),
      ),
    );
  }
}

class WarningWithBottomToast extends StatelessWidget {
  const WarningWithBottomToast({super.key});

  @override
  Widget build(BuildContext context) {
    // IMPORTANT
    SNetworkConnectionChecker.instance.startListen();
    return MaterialApp(
      title: 'SNetwork connection checker example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return Scaffold(
          body: SNetworkConnectionChecker.instance.isConnected.builder((loading, isConnected, error, context) {
            if (isConnected == null) {
              return const Center(
                child: Text("Loading"),
              );
            }
            return Column(
              children: [
                Expanded(child: child!),
                AnimatedContainer(
                    height: !isConnected ? 100 : 0,
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    duration: const Duration(milliseconds: 500),
                    child: const SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("No connection"),
                          Text("Please check your network connection"),
                        ],
                      ),
                    )),
              ],
            );
          }),
        );
      },
      home: const Scaffold(
        body: Center(
          child: Text("Home page"),
        ),
      ),
    );
  }
}
