import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:loggy/loggy.dart';
import 'package:shake_gesture/shake_gesture.dart';
import 'package:sigma_detector/services/detection_service.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:sigma_detector/utils/crashlytics_printer.dart';
import 'package:sigma_detector/utils/custom_loggy.dart';
import 'package:sigma_detector/utils/file_printer.dart';
import 'package:sigma_detector/utils/multi_printer.dart';
import 'firebase_options.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_loggy/flutter_loggy.dart';

void main() {
  runZonedGuarded<Future<void>>(() async {
    // Ensure that plugin services are initialized so that `availableCameras()`
    // can be called before `runApp()`
    WidgetsFlutterBinding.ensureInitialized();

    Loggy.initLoggy(
      logPrinter: StreamPrinter(
        MultiPrinter({
          PrettyDeveloperPrinter(),
          const CrashlyticsPrinter(),
          FilePrinter(),
        }),
      ),
    );

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Catch Fatal errors thrown by the flutter framework itself
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    //Catch errors outside Flutter's context
    Isolate.current.addErrorListener(RawReceivePort((List<String> pair) async {
      final List<dynamic> errorAndStacktrace = pair;
      await FirebaseCrashlytics.instance.recordError(
        errorAndStacktrace.first,
        StackTrace.fromString(errorAndStacktrace.last),
      );
    }).sendPort);

    // Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();

    // Get a specific camera from the list of available cameras.
    final firstCamera = cameras.first;

    runApp(
      MaterialApp(
        title: 'Sigma Detector',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a purple toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
          useMaterial3: true,
        ),
        home: DevApp(
          child: MyHomePage(camera: firstCamera),
        ),
      ),
    );
  },
      (error, stack) =>
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true));
}

class DevApp extends StatefulWidget with UiLoggy {
  final Widget? child;
  const DevApp({super.key, this.child});

  @override
  State<DevApp> createState() => _DevAppState();
}

class _DevAppState extends State<DevApp> with UiLoggy {
  @override
  void initState() {
    super.initState();
    loggy.warning("You are using a non production build");
    loggy.warning(
      "If you see this message for the love of everything holy (or unholy if you're satanic. I don't discriminate) DO NOT release this build into production",
    );
  }

  @override
  Widget build(BuildContext context) {
    return ShakeGesture(
      onShake: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => const LoggyStreamScreen(),
            fullscreenDialog: true,
          ),
        );
      },
      child: widget.child ?? Container(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with UiLoggy {
  late final Future<List<CameraDescription>> camerasFuture = availableCameras();
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Sigma Detector"),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const LoggyStreamScreen(),
                  fullscreenDialog: true,
                ),
              );
            },
          ),
        ],
      ),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // If the Future is complete, display the preview.
              return CameraPreview(_controller);
            } else {
              // Otherwise, display a loading indicator.
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _controller.takePicture();

            if (!context.mounted) return;

            // If the picture was taken, display it on a new screen.
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  // Pass the automatically generated path to
                  // the DisplayPictureScreen widget.
                  imagePath: image.path,
                ),
              ),
            );
          } catch (e, s) {
            // If an error occurs, log the error to the console.
            loggy.error("Error taking image", e, s);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget with UiLoggy {
  final String imagePath;
  late final File image;
  final detector = DetectionService();

  DisplayPictureScreen({super.key, required this.imagePath}) {
    image = File(imagePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analysis')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 16,
          children: [
            FutureBuilder(
                future: detector.analyse(image),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text(
                      "Analysing image...",
                      style: Theme.of(context).textTheme.headlineMedium,
                    );
                  }

                  if (snapshot.hasError) {
                    loggy.error("Error analysing image", snapshot.error,
                        snapshot.stackTrace);

                    return Text(
                      "Error: ${snapshot.error}",
                      style: Theme.of(context).textTheme.headlineMedium,
                    );
                  }

                  if (!snapshot.hasData) {
                    loggy.warning("No data from analysis");

                    return Text(
                      "Damn you broke the app",
                      style: Theme.of(context).textTheme.headlineMedium,
                    );
                  }

                  loggy.debug("Result: ${snapshot.data}");

                  return Text(
                    snapshot.data! ? "Sigma detected" : "No Sigma detected",
                    style: Theme.of(context).textTheme.headlineMedium,
                  );
                }),
            Image.file(image),
          ],
        ),
      ),
    );
  }
}
