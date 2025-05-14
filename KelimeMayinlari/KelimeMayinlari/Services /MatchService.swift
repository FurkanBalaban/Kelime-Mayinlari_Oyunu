import Foundation
import FirebaseDatabase
import FirebaseAuth

class MatchService {
    
    static let shared = MatchService()
    private let db = Database.database().reference()

    private init() {}

    func findMatch(for timeOption: GameTimeOption, completion: @escaping (Result<String, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "Auth Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı bulunamadı."])))
            return
        }

        let waitingRoomRef = db.child("waitingRooms/\(timeOption.rawValue)/users")

        waitingRoomRef.observeSingleEvent(of: .value) { snapshot in
            var opponentId: String?

            for child in snapshot.children {
                if let snap = child as? DataSnapshot {
                    if snap.key != userId {
                        opponentId = snap.key
                        break
                    }
                }
            }

            if let opponentId = opponentId {
                // ✅ Rakip bulundu: onu bekleme listesinden sil
                waitingRoomRef.child(opponentId).removeValue()

                // ✅ Yeni oyun oluştur
                let gameId = UUID().uuidString
                let gameRef = self.db.child("games").child(gameId)
                let gameData: [String: Any] = [
                    "player1": userId,
                    "player2": opponentId,
                    "createdAt": ServerValue.timestamp(),
                    "turn": "player1",
                    "isFirstMoveDone": false,
                    "scores": [
                        "player1": 0,
                        "player2": 0
                    ]
                ]

                gameRef.setValue(gameData) { error, _ in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(gameId))
                    }
                }

            } else {
                // ✅ Henüz rakip yoksa bekleme odasına kendini ekle
                waitingRoomRef.child(userId).setValue(["timestamp": Date().timeIntervalSince1970]) { error, _ in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.failure(NSError(domain: "Waiting", code: 0, userInfo: [NSLocalizedDescriptionKey: "Bekliyor..."])))
                    }
                }
            }
        }
    }
}
