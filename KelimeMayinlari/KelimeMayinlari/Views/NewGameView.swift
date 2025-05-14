import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct NewGameView: View {

    @Binding var gameId: String?
    @Binding var playerRole: String?
    @Binding var navigateToGame: Bool

    @State private var selectedTime: GameTimeOption?
    @State private var isGameStarted = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            Text("Süre Seçimi")
                .font(.largeTitle)
                .bold()

            ForEach(GameTimeOption.allCases, id: \.self) { option in
                Button(action: {
                    selectedTime = option
                    startMatching(for: option)
                }) {
                    Text(option.rawValue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedTime == option ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }

            if isGameStarted {
                ProgressView("Rakip aranıyor...")
                    .padding()
            }

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .navigationTitle("Yeni Oyun")
    }

    private func startMatching(for option: GameTimeOption) {
        isGameStarted = true
        errorMessage = nil

        guard let userId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "Kullanıcı bulunamadı."
            self.isGameStarted = false
            return
        }

        let db = Database.database().reference()
        let roomRef = db.child("waitingRooms").child(option.rawValue)

        roomRef.observeSingleEvent(of: .value) { snapshot in
            var matched = false

            for child in snapshot.children {
                if let snap = child as? DataSnapshot,
                   let opponentId = snap.key as String?,
                   opponentId != userId {

                    // Rakip bulundu: eşleşmeyi oluştur
                    let newGameId = UUID().uuidString
                    let gameRef = db.child("games").child(newGameId)
                    let gameData = [
                        "player1": opponentId,
                        "player2": userId,
                        "turn": "player1",
                        "isFirstMoveDone": false
                    ] as [String: Any]

                    gameRef.setValue(gameData)
                    roomRef.child(opponentId).removeValue()

                    self.gameId = newGameId
                    self.playerRole = "player2"
                    self.navigateToGame = true
                    matched = true
                    break
                }
            }

            if !matched {
                // Rakip yok, kendini listeye ekle
                roomRef.child(userId).setValue(["timestamp": Date().timeIntervalSince1970])
                self.errorMessage = "Rakip bekleniyor..."
                self.isGameStarted = false
            }
        }
    }
}
