import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    BackgroundDartInvoker.shared.startEngine()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

/* class BackgroundDartInvoker {
  static let shared = BackgroundDartInvoker()

  private var engine: FlutterEngine?

  func startEngine() {
    if engine == nil {
      engine = FlutterEngine(name: "background_engine")
      engine?.run(withEntrypoint: "backgroundMain") // Entry point from main.dart
      GeneratedPluginRegistrant.register(with: engine!)
    }

    let channel = FlutterMethodChannel(name: "com.example.background",
                                       binaryMessenger: engine!.binaryMessenger)

    // Wait for 1 second before invoking the backgroundHandler
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      print("📣 invoking backgroundHandler")
      channel.invokeMethod("backgroundHandler", arguments: nil)
    }
  }
} */

class BackgroundDartInvoker {
  static let shared = BackgroundDartInvoker()

  private var engine: FlutterEngine?

  func startEngine() {
    // Protect against restarting the engine
    guard engine == nil else { return }

    let flutterEngine = FlutterEngine(name: "background_engine")
    flutterEngine.run(withEntrypoint: "backgroundMain")
    GeneratedPluginRegistrant.register(with: flutterEngine)

    self.engine = flutterEngine

    // Create a channel
    let channel = FlutterMethodChannel(name: "com.example.background",
                                       binaryMessenger: flutterEngine.binaryMessenger)

    // Weak reference to self to avoid retain cycle
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
      guard let self = self else { return }
      print("📣 invoking backgroundHandler")
      channel.invokeMethod("backgroundHandler", arguments: nil)
    }
  }
}