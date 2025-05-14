import SwiftUI

struct ActiveGamesView: View {
    @State private var activeGames: [(id: String, isPlayer1: Bool)] = []
    @State private var selectedGameId = ""
    @State private var selectedPlayerRole = "" // ← EKLENDİ
    @State private var navigateToGame = false

    var body: some View {
        VStack {
            Text("Aktif Oyunlar").font(.largeTitle).bold().padding()

            if activeGames.isEmpty {
                Text("Aktif oyun bulunamadı").foregroundColor(.gray)
            } else {
                List(activeGames, id: \.id) { game in
                    HStack {
                        Text("Oyun Kodu: \(game.id.prefix(6))...")
                        Spacer()
                        Button("Devam Et") {
                            selectedGameId = game.id
                            selectedPlayerRole = game.isPlayer1 ? "player1" : "player2" // ← EKLENDİ
                            navigateToGame = true
                        }
                    }
                }
            }

            NavigationLink(destination: GameBoardView(playerRole: selectedPlayerRole, gameId: selectedGameId), isActive: $navigateToGame) {
                EmptyView()
            }
            .hidden()
        }
        .onAppear {
            GameFetcherService.shared.fetchActiveGames { games in
                self.activeGames = games
            }
        }
    }
}
