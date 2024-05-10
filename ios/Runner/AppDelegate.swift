import UIKit
import Flutter
import GoogleMaps
import Firebase
import workmanager

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()

    if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    GMSServices.provideAPIKey("AIzaSyC5szIWBSfTg3SzJPkTPU7DPfZcdkvFd4A")
    GeneratedPluginRegistrant.register(with: self)
    UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(60*15))
    WorkmanagerPlugin.registerBGProcessingTask(withIdentifier: "trackingTask")
    WorkmanagerPlugin.registerBGProcessingTask(withIdentifier: "scheduleDailyTasks")
    // Register a periodic task in iOS 13+
    WorkmanagerPlugin.registerPeriodicTask(withIdentifier: "be.tramckrijte.workmanagerExample.iOSBackgroundAppRefresh", frequency: NSNumber(value: 86400))
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
