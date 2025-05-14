import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var viewModel: LoginViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Giriş Yap")
                .font(.largeTitle)
                .bold()
            
            TextField("E-posta", text: $viewModel.email)
                .autocapitalization(.none)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            SecureField("Şifre", text: $viewModel.password)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
            
            Button(action: {
                viewModel.login()
            }) {
                Text("Giriş Yap")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            
            NavigationLink(destination: RegisterView()) {
                Text("Hesabın yok mu? Kayıt Ol")
                    .foregroundColor(.blue)
            }
            .padding()
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(LoginViewModel())
}
