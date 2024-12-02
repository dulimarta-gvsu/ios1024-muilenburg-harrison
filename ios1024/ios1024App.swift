import Foundation
import SwiftUI
import Firebase
import FirebaseAuth // <-- Properly added FirebaseAuth to resolve all Auth usage

@main
struct ios1024App: App {
    @StateObject private var appState = AppState() // Create the shared instance

    init() {
        FirebaseApp.configure() // Configure Firebase on initialization
    }

    var body: some Scene {
        WindowGroup {
            if appState.isLoggedIn {
                GameView() // Show GameView if user is logged in
                    .environmentObject(appState) // Inject appState
            } else {
                LoginView() // Show LoginView if user is not logged in
                    .environmentObject(appState) // Inject appState
            }
        }
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

