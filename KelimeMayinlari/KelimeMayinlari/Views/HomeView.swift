import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("Ana Menü")
                .font(.largeTitle)
                .bold()

            NavigationLink(destination: GameLobbyView()) {
                Text("Yeni Oyun")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }

            NavigationLink(destination: ActiveGamesView()) {
                Text("Aktif Oyunlar")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }

            NavigationLink(destination: Text("Biten Oyunlar")) {
                Text("Biten Oyunlar")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }

            Spacer()

            Button(action: {
                viewModel.signOut()
            }) {
                Text("Çıkış Yap")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
        }
        .navigationTitle("Kelime Mayınları")
        .fullScreenCover(isPresented: $viewModel.isLoggedOut) {
            ContentView()
        }
    }
}
