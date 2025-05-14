import SwiftUI

struct ContentView: View {
    
    @StateObject private var loginViewModel = LoginViewModel()
    
    var body: some View {
        NavigationStack {
            if loginViewModel.isLoggedIn {
                GameLobbyView()
            } else {
                LoginView()
                    .environmentObject(loginViewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}
