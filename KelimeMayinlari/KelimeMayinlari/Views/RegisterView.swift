import SwiftUI

struct RegisterView: View {
    
    @StateObject private var viewModel = RegisterViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Kayıt Ol")
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
                viewModel.register()
            }) {
                Text("Kayıt Ol")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
        }
    }
}

#Preview {
    RegisterView()
}
