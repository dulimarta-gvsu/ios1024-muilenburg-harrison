import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct NewAccountView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppState  // Assuming an environment object for navigation
    @State private var email: String = ""
    @State private var realName: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            TextField("Real Name", text: $realName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textContentType(.password)
            
            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textContentType(.password)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            if isLoading {
                ProgressView()
            } else {
                Button(action: createAccount) {
                    Text("Create Account")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(email.isEmpty || password.isEmpty || password != confirmPassword)
            }
        }
        .padding()
        .navigationTitle("Create Account")
    }

    // Function to create a new user account
    private func createAccount() {
        isLoading = true
        errorMessage = nil

        // Use Firebase Authentication to create a user with email and password
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    // Handle specific errors that can arise during account creation
                    self.errorMessage = "Failed to create account: \(error.localizedDescription)"
                    print("Authentication error: \(error.localizedDescription)")
                    return
                }

                // If user creation succeeded, save user data to Firestore
                if let user = result?.user {
                    saveUserData(user: user)
                }
            }
        }
    }

    // Function to save the user's additional information to Firestore
    private func saveUserData(user: User) {
        let db = Firestore.firestore()
        let userData: [String: Any] = [
            "email": email,
            "realName": realName
        ]

        db.collection("users").document(user.uid).setData(userData) { error in
            if let error = error {
                self.errorMessage = "Failed to save user data: \(error.localizedDescription)"
                print("Firestore error: \(error.localizedDescription)")
            } else {
                // Successfully created account and saved user data
                proceedToGameView()
            }
        }
    }

    // Function to navigate to GameView after successful account creation
    private func proceedToGameView() {
        if Auth.auth().currentUser == nil {
            errorMessage = "Login invalid. Please try again."
        } else {
            appState.isLoggedIn = true
        }
    }
}

