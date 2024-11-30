import SwiftUI
import FirebaseAuth

struct NewAccountView: View {
    @Environment(\.dismiss) var dismiss // Add this line for dismissing the view
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var realName = ""
    @State private var errorMessage = ""
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Real Name", text: $realName)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Password", text: $password)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Confirm Password", text: $confirmPassword)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button(action: {
                // Basic input validation
                guard !email.isEmpty && !password.isEmpty && !realName.isEmpty else {
                    errorMessage = "Please fill in all fields."
                    return
                }

                guard password == confirmPassword else {
                    errorMessage = "Passwords do not match."
                    return
                }

                viewModel.signUp(email: email, password: password, realName: realName) { error in
                    if let error = error {
                        errorMessage = error.localizedDescription
                    } else {
                        // Navigate to the main game view upon successful login
                        dismiss() // Dismiss the NewAccountView after successful signup
                    }
                }
            }) {
                Text("Create Account")
            }
            .padding()
            .disabled(email.isEmpty || password.isEmpty || realName.isEmpty || password != confirmPassword) // Disable if required fields are empty or passwords don't match

            Button("Cancel") {
                dismiss()
            }
            .padding()

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
        .navigationTitle("New Account")
    }
}
