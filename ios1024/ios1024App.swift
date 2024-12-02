import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseAppCheck
import Firebase


@main
struct ios1024App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            if appState.isLoggedIn {
                GameView()
                    .environmentObject(appState)
            } else {
                LoginView()
                    .environmentObject(appState)
            }
        }
    }
}

// AppDelegate to handle Firebase initialization
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        
        // Set up App Check Debug Provider for development
        let providerFactory = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        
        return true
    }
}

// AppState to manage navigation and user authentication status
class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false

    init() {
        // Set up listener for authentication state changes to handle real-time updates
        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            if let user = user {
                print("User logged in: \(user.email ?? "Unknown")")
                self?.isLoggedIn = true
            } else {
                print("User logged out or no user logged in.")
                self?.isLoggedIn = false
            }
        }
    }
}

