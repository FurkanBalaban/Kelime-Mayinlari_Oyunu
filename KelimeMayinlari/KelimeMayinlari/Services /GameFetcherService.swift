import Foundation
import FirebaseDatabase
import FirebaseAuth

class GameFetcherService {
    
    static let shared = GameFetcherService()
    private let db = Database.database().reference()
    
    func fetchActiveGames(completion: @escaping ([(id: String, isPlayer1: Bool)]) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }

        db.child("games").observeSingleEvent(of: .value) { snapshot in
            var games: [(id: String, isPlayer1: Bool)] = []

            for child in snapshot.children {
                if let gameSnap = child as? DataSnapshot,
                   let gameData = gameSnap.value as? [String: Any] {
                    
                    if let player1 = gameData["player1"] as? String, player1 == currentUserId {
                        games.append((id: gameSnap.key, isPlayer1: true))
                    } else if let player2 = gameData["player2"] as? String, player2 == currentUserId {
                        games.append((id: gameSnap.key, isPlayer1: false))
                    }
                }
            }

            completion(games)
        }
    }
}
