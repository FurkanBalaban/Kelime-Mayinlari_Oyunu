import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct GameLobbyView: View {
    @State private var isNewGame = false
    @State private var enteredGameId = ""
    @State private var navigateToGame = false
    @State private var gameId = ""
    @State private var playerRole: String = ""
    @State private var isLoggedOut = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Kelime Oyunu")
                    .font(.largeTitle)
                    .bold()

                Text("Yeni Oyun Başlat").font(.headline)

                ForEach(GameTimeOption.allCases, id: \.self) { option in
                    Button(option.rawValue) {
                        MatchService.shared.findMatch(for: option) { result in
                            DispatchQueue.main.async {
                                switch result {
                                case .success(let foundGameId):
                                    let currentUserId = Auth.auth().currentUser?.uid ?? ""
                                    fetchPlayerRoleFromRealtimeDB(gameId: foundGameId, currentUserId: currentUserId) { role in
                                        if let role = role {
                                            self.playerRole = role
                                            self.gameId = foundGameId
                                            self.navigateToGame = true
                                        }
                                    }

                                case .failure(let error):
                                    print("Eşleşme başarısız: \(error.localizedDescription)")
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(option == .twoMinutes || option == .fiveMinutes ? Color.orange : Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }

                Text("veya").foregroundColor(.gray)

                TextField("Oyun Kodu Gir", text: $enteredGameId)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Button("Oyuna Katıl") {
                    let trimmedId = enteredGameId.trimmingCharacters(in: .whitespacesAndNewlines)
                    let currentUserId = Auth.auth().currentUser?.uid ?? ""
                    fetchPlayerRoleFromRealtimeDB(gameId: trimmedId, currentUserId: currentUserId) { role in
                        if let role = role {
                            self.playerRole = role
                            self.gameId = trimmedId
                            self.navigateToGame = true
                        }
                    }
                }
                .disabled(enteredGameId.isEmpty)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                NavigationLink(destination: ActiveGamesView()) {
                    Text("Aktif Oyunlar")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }

                NavigationLink(destination: GameBoardView(playerRole: playerRole, gameId: gameId), isActive: $navigateToGame) {
                    EmptyView()
                }
                .hidden()

                Spacer()

                Button("Çıkış Yap") {
                    do {
                        try Auth.auth().signOut()
                        isLoggedOut = true
                    } catch {
                        print("Çıkış hatası: \(error.localizedDescription)")
                    }
                }
                .foregroundColor(.red)
                .fullScreenCover(isPresented: $isLoggedOut) {
                    ContentView()
                }
            }
            .padding()
        }
    }
}
func fetchPlayerRoleFromRealtimeDB(gameId: String, currentUserId: String, completion: @escaping (String?) -> Void) {
    let dbRef = Database.database().reference()
    dbRef.child("games/\(gameId)").observeSingleEvent(of: .value) { snapshot in
        if let value = snapshot.value as? [String: Any] {
            if value["player1"] as? String == currentUserId {
                completion("player1")
            } else if value["player2"] as? String == currentUserId {
                completion("player2")
            } else {
                completion(nil)
            }
        } else {
            completion(nil)
        }
    }
}
