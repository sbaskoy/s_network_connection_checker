<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

# SNetwork Connection Checker

## Screenshots

|                                                                                                     |                                                                                                      |
| :-------------------------------------------------------------------------------------------------: | :--------------------------------------------------------------------------------------------------: |
| ![poc](https://github.com/sbaskoy/s_network_connection_checker/blob/main/images/basic.gif?raw=true) | ![poc](https://github.com/sbaskoy/s_network_connection_checker/blob/main/images/bottom.gif?raw=true) |

|                                                                                                           |     |
| :-------------------------------------------------------------------------------------------------------: | :-: |
| ![poc](https://github.com/sbaskoy/s_network_connection_checker/blob/main/images/full_screen.png?raw=true) |     |

### Configs

[`failedPingCount`] -> a failed `ping` up to this parameter is considered a lost connection

[`reTryDuration`] -> throws a `ping` during this duration

[`pingTimeout`] -> If there is no response to the `ping` in this time, it is considered **unsuccessful**

[`urls`] -> links to `ping`, As default, the first element of the list is taken

`SNetworkConnectionChecker.instance.selectedIp.setState(SIpModel("Google 1", "8.8.8.8", 53));`

```dart

  SNetworkConnectionChecker.instance.setConfig(
    failedPingCount: 2,
    pingTimeout: const Duration(seconds: 2),
    reTryDuration: const Duration(seconds: 3),
    urls: [
      SIpModel("Google 1", "8.8.8.8", 53),
      SIpModel("Google 2", "8.8.4.4", 53),
    ],
  );
```

## Usage

### Check if you have internet connection

```dart
  var hasConnection = await SNetworkConnectionChecker.instance.hasConnection();

  print("Has connection $hasConnection");
  runApp(const FullScreenWarningWithOpacity());

```

### Listen to the status of your internet connection

```dart

void main() async {
    // IMPORTANT
    // You can call anywhere you want
    SNetworkConnectionChecker.instance.startListen();
    runApp(const FullScreenWarningWithOpacity());
}
// ..........

SNetworkConnectionChecker.instance.isConnected.listen(
      (value) {
        // true connected, false not connected, null loading
        print("Connection status changed $value");
      },
    );

/// .........

```

### Use in UI

- Basic usage 

```dart
MaterialApp(
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

```

- other usage

```dart

MaterialApp(
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


```
