import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @ObservedObject var viewModel: GameViewModel  // Assuming you have a GameViewModel

    var body: some View {
        NavigationView {
            VStack {
                TextField("Email", text: $email)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                SecureField("Password", text: $password)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: {
                    viewModel.signIn(email: email, password: password) { error in
                        if let error = error {
                            errorMessage = error.localizedDescription
                        } else {
                            // Navigate to the main game view upon successful login
                        }
                    }
                }) {
                    Text("Login")
                }
                .padding()

                NavigationLink(destination: NewAccountView(viewModel: viewModel)) {
                    Text("Create New Account")
                }
                .padding()

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .padding()
            .navigationTitle("Login")
        }
    }
}
