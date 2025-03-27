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

class BackgroundDartInvoker {
  static let shared = BackgroundDartInvoker()

  private var engine: FlutterEngine?

  func startEngine() {
    if engine == nil {
      engine = FlutterEngine(name: "background_engine")
      engine?.run(withEntrypoint: "backgroundMain") // 👈 твой entrypoint из Dart
      GeneratedPluginRegistrant.register(with: engine!)
    }

    let channel = FlutterMethodChannel(name: "com.example.background",
                                       binaryMessenger: engine!.binaryMessenger)

    // Вызываем после 1 секунды, чтобы Dart успел подняться
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      print("📣 invoking backgroundHandler")
      channel.invokeMethod("backgroundHandler", arguments: nil)
    }
  }
}