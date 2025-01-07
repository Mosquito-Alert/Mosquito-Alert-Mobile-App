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
    application.registerForRemoteNotifications()
    if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self
    }
    GMSServices.provideAPIKey("AIzaSyC5szIWBSfTg3SzJPkTPU7DPfZcdkvFd4A")

    GeneratedPluginRegistrant.register(with: self)
    UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(60*15))
 
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
