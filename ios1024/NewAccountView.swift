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

                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .navigationTitle("Create New Account")
    }

    // Function to create a new account using Firebase Authentication
    private func createAccount() {
        isLoading = true
        errorMessage = nil

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            isLoading = false

            if let error = error {
                errorMessage = "Failed to create account: \(error.localizedDescription)"
            } else if let user = result?.user {
                saveUserNameToFirestore(userId: user.uid)
            }
        }
    }

    // Function to save the user's real name to Firestore
    private func saveUserNameToFirestore(userId: String) {
        let db = Firestore.firestore()
        db.collection("players").document(userId).setData(["realName": realName]) { error in
            if let error = error {
                errorMessage = "Failed to save user data: \(error.localizedDescription)"
            } else {
                // Successfully created account and saved user data
                proceedToGameView()
            }
        }
    }

    // Function to navigate to the GameView after successful account creation
    private func proceedToGameView() {
        // If login is invalid, show an error message
        if Auth.auth().currentUser == nil {
            errorMessage = "Login invalid. Please try again."
        } else {
            // Navigate to the GameView by updating the app state
            appState.isLoggedIn = true
        }
    }
}


