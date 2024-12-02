import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false
    @State private var isNavigatingToNewAccount: Bool = false
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.password)

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }

                if isLoading {
                    ProgressView()
                } else {
                    Button(action: login) {
                        Text("Login")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(email.isEmpty || password.isEmpty)

                    NavigationLink(destination: NewAccountView(), isActive: $isNavigatingToNewAccount) {
                        EmptyView()
                    }
                    Button(action: {
                        isNavigatingToNewAccount = true
                    }) {
                        Text("Create New Account")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            .navigationTitle("Login to 1024 Game!")
        }
    }

    // Function to handle login using Firebase Authentication
    private func login() {
        isLoading = true
        errorMessage = nil

        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            isLoading = false

            if let error = error {
                errorMessage = "Failed to login: \(error.localizedDescription)"
            } else {
                // Successful login, navigate to the next view (e.g., GameView)
                appState.isLoggedIn = true
            }
        }
    }
}

