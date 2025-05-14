import Foundation
import FirebaseDatabase

class GameService: ObservableObject {
    private let db = Database.database().reference()

    @Published var remoteBoard: [[String]] = Array(repeating: Array(repeating: "", count: 15), count: 15)
    @Published var currentTurn: String = "player1"

    func updateBoard(_ board: [[String]], gameId: String) {
        db.child("games/\(gameId)/board").setValue(board)
    }

    func listenToBoard(gameId: String, completion: @escaping ([[String]]) -> Void) {
        db.child("games/\(gameId)/board").observe(.value) { snapshot in
            if let boardData = snapshot.value as? [[String]] {
                DispatchQueue.main.async {
                    completion(boardData)
                }
            }
        }
    }

    func switchTurn(gameId: String, to player: String) {
        db.child("games/\(gameId)/turn").setValue(player)
    }
   
    func updateLetterBag(gameId: String, bag: [String]) {
        let ref = Database.database().reference()
        ref.child("games/\(gameId)/letterBag").setValue(bag)
    }

    func updatePlayerTiles(gameId: String, playerId: String, tiles: [String]) {
        let ref = Database.database().reference()
        ref.child("games/\(gameId)/tiles/\(playerId)").setValue(tiles)
    }
    func listenToLetterBag(gameId: String, completion: @escaping ([String]) -> Void) {
        db.child("games/\(gameId)/letterBag").observe(.value) { snapshot in
            if let bag = snapshot.value as? [String] {
                DispatchQueue.main.async {
                    completion(bag)
                }
            }
        }
    }
    
    func saveLetterBagToDatabase(_ bag: [String], gameId: String) {
        db.child("games/\(gameId)/letterBag").setValue(bag)
    }
    func fetchLetterBag(gameId: String, completion: @escaping ([String]) -> Void) {
        db.child("games/\(gameId)/letterBag").observeSingleEvent(of: .value) { snapshot in
            if let bag = snapshot.value as? [String] {
                completion(bag)
            } else {
                completion([])
            }
        }
    }
    func markGameOver(gameId: String) {
        db.child("games/\(gameId)/isGameOver").setValue(true)
    }

    func listenToGameOver(gameId: String, completion: @escaping (Bool) -> Void) {
        db.child("games/\(gameId)/isGameOver").observe(.value) { snapshot in
            let isOver = snapshot.value as? Bool ?? false
            DispatchQueue.main.async {
                completion(isOver)
            }
        }
    }
    func listenToTurn(gameId: String, completion: @escaping (String) -> Void) {
        db.child("games/\(gameId)/turn").observe(.value) { snapshot in
            if let turn = snapshot.value as? String {
                DispatchQueue.main.async {
                    completion(turn)
                }
            }
        }
    }

    func updateScores(gameId: String, player1Score: Int, player2Score: Int) {
        db.child("games/\(gameId)/scores/player1").setValue(player1Score)
        db.child("games/\(gameId)/scores/player2").setValue(player2Score)
    }

    func listenToScores(gameId: String, completion: @escaping (Int, Int) -> Void) {
        db.child("games/\(gameId)/scores").observe(.value) { snapshot in
            if let scores = snapshot.value as? [String: Int],
               let p1 = scores["player1"],
               let p2 = scores["player2"] {
                DispatchQueue.main.async {
                    completion(p1, p2)
                }
            }
        }
    }
    func savePlayerTilesToDatabase(_ letters: [String], gameId: String, playerId: String) {
        db.child("games/\(gameId)/tiles/\(playerId)").setValue(letters)
    }
    func markFirstMoveDone(gameId: String) {
        db.child("games/\(gameId)/isFirstMoveDone").setValue(true)
    }
   
    func listenToPlayerTiles(gameId: String, playerId: String, completion: @escaping ([String]) -> Void) {
        db.child("games/\(gameId)/tiles/\(playerId)").observe(.value) { snapshot in
            if snapshot.exists(), let letters = snapshot.value as? [String] {
                DispatchQueue.main.async {
                    completion(letters)
                }
            } else {
                // 🔥 Eğer hiç veri yoksa da boş array dön
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }
    func listenToIsFirstMove(gameId: String, completion: @escaping (Bool) -> Void) {
        db.child("games/\(gameId)/isFirstMoveDone").observe(.value) { snapshot in
            let isDone = snapshot.value as? Bool ?? false
            DispatchQueue.main.async {
                completion(isDone)
            }
        }
    }
    func finishGame(gameId: String, winner: String, surrender: Bool = false) {
        let ref = db.child("games/\(gameId)/result")
        let resultData: [String: Any] = [
            "winner": winner,
            "endedBy": surrender ? "surrender" : "normal",
            "timestamp": ServerValue.timestamp()
        ]
        ref.setValue(resultData)
    }
    func incrementPassCount(gameId: String, playerRole: String, completion: @escaping ([String: Int]) -> Void) {
        let ref = Database.database().reference().child("games").child(gameId).child("passCount")

        ref.runTransactionBlock { currentData in
            var value = currentData.value as? [String: Int] ?? [:]
            value[playerRole, default: 0] += 1
            currentData.value = value
            return TransactionResult.success(withValue: currentData)
        } andCompletionBlock: { error, _, snapshot in
            if let data = snapshot?.value as? [String: Int] {
                completion(data)
            }
        }
    }
    func recordPass(gameId: String, playerId: String) {
        let ref = db.child("games/\(gameId)/passHistory")
        ref.observeSingleEvent(of: .value) { snapshot in
            var history: [String: Any] = snapshot.value as? [String: Any] ?? [:]

            let nextIndex = (history.keys.compactMap { Int($0) }.max() ?? -1) + 1
            history["\(nextIndex)"] = playerId
            ref.setValue(history)
        }
    }
    func checkGameShouldEndDueToPasses(gameId: String, completion: @escaping (Bool) -> Void) {
        let ref = db.child("games/\(gameId)/passHistory")
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let dict = snapshot.value as? [String: Any] else {
                completion(false)
                return
            }

            let sorted = dict.sorted { (lhs, rhs) in
                guard let l = Int(lhs.key), let r = Int(rhs.key) else { return false }
                return l < r
            }

            let history = sorted.map { $0.value as? String ?? "" }

            // 🔍 Son 4 geçişi kontrol et
            guard history.count >= 4 else {
                completion(false)
                return
            }

            let lastFour = Array(history.suffix(4))
            if lastFour == ["player1", "player2", "player1", "player2"] ||
               lastFour == ["player2", "player1", "player2", "player1"] {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    func fetchOpponentTiles(gameId: String, currentPlayer: String, completion: @escaping ([String]) -> Void) {
        let opponent = currentPlayer == "player1" ? "player2" : "player1"
        db.child("games/\(gameId)/tiles/\(opponent)").observeSingleEvent(of: .value) { snapshot in
            if let letters = snapshot.value as? [String] {
                completion(letters)
            } else {
                completion([])
            }
        }
    }



    func markGameEnded(gameId: String, winner: String) {
        db.child("games/\(gameId)/status").setValue(["ended": true, "winner": winner])
    }
    func finishGameWithScoreComparison(gameId: String) {
        let gameRef = db.child("games/\(gameId)")
        
        gameRef.observeSingleEvent(of: .value) { snapshot in
            guard let data = snapshot.value as? [String: Any],
                  let scores = data["scores"] as? [String: Int],
                  let p1 = scores["player1"],
                  let p2 = scores["player2"] else {
                return
            }
            
            var winner = "draw"
            if p1 > p2 {
                winner = "player1"
            } else if p2 > p1 {
                winner = "player2"
            }
            
            let resultData: [String: Any] = [
                "winner": winner,
                "endedBy": "doublePass",
                "timestamp": ServerValue.timestamp()
            ]
            
            gameRef.child("result").setValue(resultData)
        }
    }
}
