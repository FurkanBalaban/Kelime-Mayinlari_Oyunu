import SwiftUI


struct GameBoardView: View {

    @State private var board: [[Tile]] = Array(
        repeating: Array(repeating: Tile(letter: "", multiplier: .none), count: 15),
        count: 15
    )
    struct Tile {
        var letter: String
        var multiplier: MultiplierType
        var mine: MineType? = nil

    }
    let boardTemplate: [[MultiplierType]] = [
        [.tripleWord, .none, .none, .doubleLetter, .none, .none, .none, .tripleWord, .none, .none, .none, .doubleLetter, .none, .none, .tripleWord],
        [.none, .doubleWord, .none, .none, .none, .tripleLetter, .none, .none, .none, .tripleLetter, .none, .none, .none, .doubleWord, .none],
        [.none, .none, .doubleWord, .none, .none, .none, .doubleLetter, .none, .doubleLetter, .none, .none, .none, .doubleWord, .none, .none],
        [.doubleLetter, .none, .none, .doubleWord, .none, .none, .none, .doubleLetter, .none, .none, .none, .doubleWord, .none, .none, .doubleLetter],
        [.none, .none, .none, .none, .doubleWord, .none, .none, .none, .none, .none, .doubleWord, .none, .none, .none, .none],
        [.none, .tripleLetter, .none, .none, .none, .tripleLetter, .none, .none, .none, .tripleLetter, .none, .none, .none, .tripleLetter, .none],
        [.none, .none, .doubleLetter, .none, .none, .none, .doubleLetter, .none, .doubleLetter, .none, .none, .none, .doubleLetter, .none, .none],
        [.tripleWord, .none, .none, .doubleLetter, .none, .none, .none, .doubleWord, .none, .none, .none, .doubleLetter, .none, .none, .tripleWord],
        [.none, .none, .doubleLetter, .none, .none, .none, .doubleLetter, .none, .doubleLetter, .none, .none, .none, .doubleLetter, .none, .none],
        [.none, .tripleLetter, .none, .none, .none, .tripleLetter, .none, .none, .none, .tripleLetter, .none, .none, .none, .tripleLetter, .none],
        [.none, .none, .none, .none, .doubleWord, .none, .none, .none, .none, .none, .doubleWord, .none, .none, .none, .none],
        [.doubleLetter, .none, .none, .doubleWord, .none, .none, .none, .doubleLetter, .none, .none, .none, .doubleWord, .none, .none, .doubleLetter],
        [.none, .none, .doubleWord, .none, .none, .none, .doubleLetter, .none, .doubleLetter, .none, .none, .none, .doubleWord, .none, .none],
        [.none, .doubleWord, .none, .none, .none, .tripleLetter, .none, .none, .none, .tripleLetter, .none, .none, .none, .doubleWord, .none],
        [.tripleWord, .none, .none, .doubleLetter, .none, .none, .none, .tripleWord, .none, .none, .none, .doubleLetter, .none, .none, .tripleWord]
    ]
    enum PlayerTurn {
        case player1
        case player2
    }
    struct TileCoordinate: Hashable {
        var row: Int
        var col: Int
    }
    enum MineType {
        case puanBol
        case puanTransfer
        case harfKaybı
        case ekstraHamleEngeli
        case kelimeIptali
    }
    @State private var hasDrawnInitialLetters = false
    @State private var isBoardInitialized = false
    var playerRole: String // "player1" veya "player2"
    var gameId: String  // ← bunu ekle
    @StateObject private var gameService = GameService()
    @State private var currentWordPath: [TileCoordinate] = []
    @State private var extraTurnGranted = false
    @State private var triggeredMine: MineType? = nil
    @State private var showMineAlert: Bool = false
    @State private var confirmedTiles: [TileCoordinate] = []
    @State private var movedTiles: [TileCoordinate] = []
    @State private var selectedOldTile: TileCoordinate? = nil
    @State private var isMoveMode: Bool = false
    @State private var player1Score: Int = 0
    @State private var player2Score: Int = 0
    @State private var letterBag: [String] = []
    @State private var currentPlayer: PlayerTurn = .player1
    @State private var placedTiles: [TileCoordinate] = []
    @State private var letterRack: [String] = []
    @State private var selectedLetter: String? = nil
    @State private var isFirstMove = true
    @State private var currentWord: String = ""
    @State private var isWordValid: Bool? = nil
    @State private var totalPoints: Int = 0
    @State private var isMyTurn: Bool = true
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 10) {
                    Text("Oyun ID: \(gameId)")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 5)
                    // 🔥 OYUN BAŞLIĞI
                    Text("Sıra: \(currentPlayer == .player1 ? "Oyuncu 1" : "Oyuncu 2")")
                        .foregroundColor(
                            (currentPlayer == .player1 && playerRole == "player1") ||
                            (currentPlayer == .player2 && playerRole == "player2") ? .green : .gray
                        )
                        .font(.headline)
                        .padding(.top, 10)
                    
                    
                    // 🔥 MATRIS
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 15), spacing: 2) {
                        ForEach(0..<15, id: \.self) { row in
                            ForEach(0..<15, id: \.self) { col in
                                ZStack {
                                    let isConfirmed = !placedTiles.contains(where: { $0.row == row && $0.col == col }) && !board[row][col].letter.isEmpty;                                    let isPlaced = placedTiles.contains { $0.row == row && $0.col == col }
                                    let multiplier = board[row][col].multiplier
                                    let currentMultiplier = board[row][col].multiplier
                                    let baseColor: Color = {
                                        switch currentMultiplier {
                                        case .doubleLetter: return Color.blue.opacity(0.3)
                                        case .tripleLetter: return Color.pink.opacity(0.3)
                                        case .doubleWord: return Color.green.opacity(0.3)
                                        case .tripleWord: return Color.brown.opacity(0.3)
                                        case .none: return Color.white
                                        }
                                    }()
                                    let backgroundColor = isConfirmed ? Color.orange : baseColor
                                    ZStack {
                                        Rectangle()
                                            .fill(baseColor)
                                            .border(Color.gray, width: 1)
                                        if isConfirmed {
                                            Rectangle()
                                                .fill(Color.orange.opacity(0.7))
                                        }
                                    }
                                    if !board[row][col].letter.isEmpty {
                                        Text(board[row][col].letter)
                                            .font(.headline)
                                            .foregroundColor(.black)
                                    } else {
                                        switch currentMultiplier {
                                        case .doubleLetter:
                                            Text("H²").font(.caption).bold().foregroundColor(.blue)
                                        case .tripleLetter:
                                            Text("H³").font(.caption).bold().foregroundColor(.pink)
                                        case .doubleWord:
                                            Text("K²").font(.caption).bold().foregroundColor(.green)
                                        case .tripleWord:
                                            Text("K³").font(.caption).bold().foregroundColor(.brown)
                                        default:
                                            EmptyView()
                                        }
                                    }
                                }
                                .frame(width: 24, height: 24)
                                .onTapGesture {
                                    if isMoveMode {
                                        moveSelectedOldTile(toRow: row, toCol: col)
                                    } else if board[row][col].letter.isEmpty {
                                        placeLetter(row: row, col: col)
                                    } else {
                                        // Eğer dolu bir hücreye tıklıyorsak ve yeni taş değilse
                                        if !placedTiles.contains(where: { $0.row == row && $0.col == col }) {
                                            // 🔥 Eğer bu taş daha önce taşınmadıysa seçime izin ver
                                            if !movedTiles.contains(where: { $0.row == row && $0.col == col }) {
                                                selectedOldTile = TileCoordinate(row: row, col: col)
                                                isMoveMode = true
                                            } else {
                                                print("Bu taş zaten bir kez taşındı, tekrar taşınamaz!")
                                            }
                                        }
                                    }
                                }
                                .id(row * 15 + col)
                            }
                        }
                    }
                    .padding()
                    
                    Divider()
                    
                    // 🔥 PAS / TESLİM OL BUTONLARI
                    HStack(spacing: 20) {
                        Button(action: {
                            undoLastMove()
                        }) {
                            Text("Geri Al")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        Button(action: {
                            passTurn()
                        }) {
                            Text("Pas Geç")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isMyTurn ? Color.orange : Color.gray)
                                .cornerRadius(10)
                        }
                        .disabled(!isMyTurn)
                        
                        Button(action: {
                            surrender()
                        }) {
                            Text("Teslim Ol")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    
                    // 🔥 HARF HAVUZU
                    HStack {
                        ForEach(letterRack, id: \.self) { letter in
                            Text(letter)
                                .font(.title)
                                .frame(width: 40, height: 40)
                                .background(selectedLetter == letter ? Color.blue : Color.yellow)
                                .cornerRadius(5)
                                .padding(4)
                                .onTapGesture {
                                    selectedLetter = letter
                                }
                        }
                    }
                    .padding()
                    
                    // 🔥 SEÇİLEN KELİME VE PUAN
                    if !currentWord.isEmpty {
                        Text(currentWord)
                            .foregroundColor(isWordValid == true ? .green : .red)
                            .font(.title2)
                            .padding()
                        
                        if isWordValid == true {
                            Text("Bu kelimenin puanı: \(totalPoints)")
                                .font(.headline)
                                .padding()
                        }
                    }
                    
                    // 🔥 ONAYLA BUTONU
                    Button(action: {
                        confirmMove()
                    }) {
                        Text("Onayla")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isWordValid == true ? Color.green : Color.gray)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    .disabled(isWordValid != true)
                    .padding(.bottom, 20)
                }
                .padding(.horizontal)
            }
            .navigationBarTitle("Oyun Tahtası", displayMode: .inline)
            .navigationBarItems(
                leading: VStack {
                    Text("Oyuncu 1")
                        .font(.caption)
                    Text("\(player1Score) Puan")
                        .bold()
                },
                trailing: VStack {
                    Text("Oyuncu 2")
                        .font(.caption)
                    Text("\(player2Score) Puan")
                        .bold()
                }
            )
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("Kalan Harf")
                            .font(.caption)
                        Text("\(letterBag.count)")
                            .bold()
                    }
                }
            }
            
            .alert(isPresented: $showMineAlert) {
                Alert(
                    title: Text("Mayın Etkisi!"),
                    message: Text(mineDescription(triggeredMine)),
                    dismissButton: .default(Text("Tamam"))
                )
            }
            
            .onAppear {
                gameService.listenToIsFirstMove(gameId: gameId) { isDone in
                    self.isFirstMove = !isDone
                    
                    if self.isFirstMove && self.playerRole == "player1" {
                        setupBoard()
                        setupLetterBag()
                        drawInitialLetters()
                    }
                }
                
                gameService.listenToLetterBag(gameId: gameId) { bag in
                    self.letterBag = bag
                }
                
                gameService.listenToPlayerTiles(gameId: gameId, playerId: playerRole) { letters in
                    self.letterRack = letters
                    
                    if letters.isEmpty && !self.hasDrawnInitialLetters && self.letterBag.count >= 7 {
                        print("🎯 Harf çekiliyor: \(playerRole)")
                        drawInitialLetters()
                    }
                }
                
                gameService.listenToBoard(gameId: gameId) { newBoard in
                    for row in 0..<15 {
                        for col in 0..<15 {
                            let letter = newBoard[row][col]
                            let multiplier = boardTemplate[row][col]
                            let mine = board[row][col].mine
                            board[row][col] = Tile(letter: letter, multiplier: multiplier, mine: mine)
                        }
                    }
                }
                
                gameService.listenToTurn(gameId: gameId) { turn in
                    self.currentPlayer = (turn == "player1") ? .player1 : .player2
                    self.isMyTurn = (turn == playerRole)
                }
                
                gameService.listenToScores(gameId: gameId) { p1, p2 in
                    self.player1Score = p1
                    self.player2Score = p2
                }
            }
        }
    }
    private func setupLetterBag() {
        letterBag = []
        
        let letterDistribution: [String: Int] = [
            "A": 12, "B": 2, "C": 2, "Ç": 2, "D": 2, "E": 8, "F": 1, "G": 1, "Ğ": 1,
            "H": 1, "I": 4, "İ": 7, "J": 1, "K": 7, "L": 7, "M": 4, "N": 5, "O": 3,
            "Ö": 1, "P": 1, "R": 6, "S": 3, "Ş": 2, "T": 5, "U": 3, "Ü": 2, "V": 1,
            "Y": 2, "Z": 2, "JOKER": 2
        ]
        
        for (letter, count) in letterDistribution {
            for _ in 0..<count {
                letterBag.append(letter)
            }
        }
        
        letterBag.shuffle()
        
        // ✅ Firebase'e kaydet
        gameService.updateLetterBag(gameId: gameId, bag: letterBag)
    }
    private func drawInitialLetters() {
        guard !hasDrawnInitialLetters else {
            print("⛔ Zaten harf çekildi, tekrar çekilmeyecek.")
            return
        }
        hasDrawnInitialLetters = true
        
        gameService.fetchLetterBag(gameId: gameId) { fetchedBag in
            var updatedBag = fetchedBag
            var newLetters: [String] = []

            for _ in 0..<7 {
                if let letter = updatedBag.popLast() {
                    newLetters.append(letter)
                }
            }

            gameService.updatePlayerTiles(gameId: gameId, playerId: playerRole, tiles: newLetters)
            gameService.updateLetterBag(gameId: gameId, bag: updatedBag)

            DispatchQueue.main.async {
                self.letterBag = updatedBag
                self.letterRack = newLetters
            }
        }
    }
    private func refillLetters() {
        gameService.fetchLetterBag(gameId: gameId) { fetchedBag in
            var updatedBag = fetchedBag
            var newLetters = self.letterRack

            while newLetters.count < 7 {
                if let newLetter = updatedBag.popLast() {
                    newLetters.append(newLetter)
                } else {
                    break
                }
            }

            gameService.updatePlayerTiles(gameId: gameId, playerId: playerRole, tiles: newLetters)
            gameService.updateLetterBag(gameId: gameId, bag: updatedBag)

            DispatchQueue.main.async {
                self.letterRack = newLetters
                self.letterBag = updatedBag
            }
        }
    }
    private func passTurn() {
        guard isMyTurn else { return }

        // 🔁 Yerleştirilen harfleri geri al
        for tile in placedTiles {
            let row = tile.row
            let col = tile.col
            let letter = board[row][col].letter
            if !letter.isEmpty {
                board[row][col].letter = ""
                letterRack.append(letter)
            }
        }

        placedTiles.removeAll()
        currentWord = ""
        isWordValid = nil
        totalPoints = 0
        selectedLetter = nil
        movedTiles.removeAll()

        // 🔴 1️⃣ Pas geçmiş oyuncuyu kayıt et
        gameService.recordPass(gameId: gameId, playerId: playerRole)

        // 🔴 2️⃣ Oyun bitmeli mi kontrol et
        gameService.checkGameShouldEndDueToPasses(gameId: gameId) { shouldEnd in
            if shouldEnd {
                gameService.finishGameWithScoreComparison(gameId: gameId)
            } else {
                // 🔄 Sıra değiştir
                let nextPlayer = currentPlayer == .player1 ? "player2" : "player1"
                currentPlayer = currentPlayer == .player1 ? .player2 : .player1
                gameService.switchTurn(gameId: gameId, to: nextPlayer)
            }
        }
    }
    private func surrender() {
        print("\(currentPlayer == .player1 ? "Oyuncu 1" : "Oyuncu 2") oyunu teslim oldu.")

        // 🔁 Oyunu Firebase üzerinde bitir
        gameService.markGameOver(gameId: gameId)

        // İsteğe bağlı: Alert veya yönlendirme ekleyebilirsin
        // Örn: showGameOverAlert = true
    }
    
    private func generateRandomLetters() {
        letterRack = []
        
        let vowels = ["A", "E", "İ", "O", "U", "Ö", "Ü", "I"]
        let consonants = ["B", "C", "Ç", "D", "F", "G", "Ğ", "H", "J", "K", "L", "M", "N", "P", "R", "S", "Ş", "T", "V", "Y", "Z"]
        
        // 3 ünlü, 4 sessiz seçelim
        for _ in 0..<3 {
            if let randomVowel = vowels.randomElement() {
                letterRack.append(randomVowel)
            }
        }
        
        for _ in 0..<4 {
            if let randomConsonant = consonants.randomElement() {
                letterRack.append(randomConsonant)
            }
        }
        
        // Sonra karıştıralım
        letterRack.shuffle()
    }
    private func moveSelectedOldTile(toRow: Int, toCol: Int) {
        guard let selected = selectedOldTile else { return }
        
        // Sadece 1 birim uzaklıktaki boş yerlere taşıyabilirsin
        let rowDiff = abs(selected.row - toRow)
        let colDiff = abs(selected.col - toCol)
        
        if (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1) {
            if board[toRow][toCol].letter.isEmpty {
                // Taşı
                board[toRow][toCol].letter = board[selected.row][selected.col].letter
                board[selected.row][selected.col].letter = ""
                
                // 🔥 Taşıma kaydı
                movedTiles.append(TileCoordinate(row: toRow, col: toCol))
                
                selectedOldTile = nil
                isMoveMode = false
                
                generateCurrentWord()
            }else {
                // Seçilen yer doluysa taşıma iptal
                print("Seçilen yer dolu, taşıma yapılamaz.")
                selectedOldTile = nil
                isMoveMode = false
            }
        } else {
            // Seçilen yer komşu değilse taşıma iptal
            print("Sadece 1 birim komşuya taşıyabilirsin.")
            selectedOldTile = nil
            isMoveMode = false
        }
    }
    private func calculatePoints(for word: String, startingRow: Int, startingCol: Int, direction: (row: Int, col: Int)) -> Int {
        var points = 0
        var wordMultiplier = 1
        
        var row = startingRow
        var col = startingCol
        
        for letter in word {
            guard row >= 0, row < 15, col >= 0, col < 15 else { break }

            let tile = board[row][col]
            let basePoint = letterPoint(for: letter)
            let coord = TileCoordinate(row: row, col: col)

            if placedTiles.contains(coord) {
                switch tile.multiplier {
                case .doubleLetter:
                    points += basePoint * 2
                case .tripleLetter:
                    points += basePoint * 3
                case .doubleWord:
                    points += basePoint
                    wordMultiplier *= 2
                case .tripleWord:
                    points += basePoint
                    wordMultiplier *= 3
                case .none:
                    points += basePoint
                }
            } else {
                points += basePoint
            }

            row += direction.row
            col += direction.col
        }
        
        return points * wordMultiplier
    }
    private func arePlacedTilesConnected() -> Bool {
        guard let firstTile = placedTiles.first else { return false }
        
        var visited = Set<TileCoordinate>()
        var stack = [firstTile]
        
        while !stack.isEmpty {
            let current = stack.removeLast()
            visited.insert(current)
            
            let neighbors = getNeighbors(of: current)
            
            for neighbor in neighbors {
                let row = neighbor.row
                let col = neighbor.col
                
                if row >= 0 && row < 15 && col >= 0 && col < 15 {
                    if (!visited.contains(neighbor)) {
                        if placedTiles.contains(where: { $0.row == row && $0.col == col }) || !board[row][col].letter.isEmpty {
                            stack.append(neighbor)
                        }
                    }
                }
            }
        }
        
        // 🔥 Yalnızca yeni koyulan taşların hepsine ulaşabiliyor muyuz?
        return placedTiles.allSatisfy { visited.contains($0) }
    }
    private func getNeighbors(of tile: TileCoordinate) -> [TileCoordinate] {
        let directions = [
            (-1, 0), (1, 0), (0, -1), (0, 1),    // Dikey ve yatay
            (-1, -1), (-1, 1), (1, -1), (1, 1)    // Çapraz
        ]
        
        return directions.map { TileCoordinate(row: tile.row + $0.0, col: tile.col + $0.1) }
    }
    private func hasPlacedTileTouchingOldTile() -> Bool {
        for placed in placedTiles {
            let neighbors = getNeighbors(of: placed)
            
            for neighbor in neighbors {
                let row = neighbor.row
                let col = neighbor.col
                
                if row >= 0 && row < 15 && col >= 0 && col < 15 {
                    // placedTiles içinde yoksa ve board doluysa eski taş var demektir
                    if !placedTiles.contains(where: { $0.row == row && $0.col == col }) && !board[row][col].letter.isEmpty {
                        return true
                    }
                }
            }
        }
        return false
    }
   
    private func letterPoint(for letter: Character) -> Int {
        switch letter {
        case "A", "E", "İ", "K", "L", "N", "R", "T": return 1
        case "B", "D", "M", "O", "S", "U": return 2
        case "C", "Ç", "P", "Y", "Ü": return 3
        case "G", "H", "Ş", "Z": return 4
        case "F": return 7
        case "J", "V", "Ö": return 8
        case "Ğ": return 10
        default: return 0
        }
    }
    private func generateCurrentWord() {
        guard !placedTiles.isEmpty else { return }
        
        // Debug: Yerleştirilen taşları loglama
        print("DEBUG: Placed tiles:")
        for tile in placedTiles {
            print("Position: (\(tile.row), \(tile.col)), Letter: \(board[tile.row][tile.col].letter)")
        }
        
        // Yerleştirilen taşların bağlantılı olduğunu kontrol et
        guard arePlacedTilesConnected() else {
            currentWord = ""
            isWordValid = nil
            totalPoints = 0
            return
        }
        
        // İlk hamle değilse ve eski taşlara temas etmiyorsa çık
        if !isFirstMove && !hasPlacedTileTouchingOldTile() {
            currentWord = ""
            isWordValid = nil
            totalPoints = 0
            return
        }
        
        // Kelime yönleri: (Yatay ve dikey yönler)
        let mainDirections = [
            (0, 1),    // yatay (soldan sağa)
            (1, 0)     // dikey (yukarıdan aşağıya)
        ]
        
        // Tüm olası kelimeler için
        var possibleWords: [(word: String, startRow: Int, startCol: Int, direction: (Int, Int), points: Int)] = []
        
        // Önce yerleştirilen taşlardan başlayarak kelime arıyoruz
        for placedTile in placedTiles {
            let row = placedTile.row
            let col = placedTile.col
            
            for direction in mainDirections {
                // İleri ve geri yönde taşları kontrol ediyoruz
                var positions: [(row: Int, col: Int)] = []
                
                // Önce kelimenin başlangıcını bul (geriye doğru giderek)
                var currentRow = row
                var currentCol = col
                
                // Geriye doğru giderek başlangıcı bul
                while currentRow >= 0 && currentRow < 15 &&
                      currentCol >= 0 && currentCol < 15 &&
                      !board[currentRow][currentCol].letter.isEmpty {
                    positions.insert((currentRow, currentCol), at: 0) // Başa ekliyoruz
                    
                    // Bir adım geriye git
                    currentRow -= direction.0
                    currentCol -= direction.1
                }
                
                // Başlangıcı düzelt - bir fazla geriye gittiğimiz için
                currentRow += direction.0
                currentCol += direction.1
                
                // Şimdi ileri doğru giderek kelimenin geri kalanını bul (başlangıçtaki harf dahil edilmemeli)
                currentRow = row + direction.0
                currentCol = col + direction.1
                
                while currentRow >= 0 && currentRow < 15 &&
                      currentCol >= 0 && currentCol < 15 &&
                      !board[currentRow][currentCol].letter.isEmpty {
                    positions.append((currentRow, currentCol))
                    
                    // Bir adım ileriye git
                    currentRow += direction.0
                    currentCol += direction.1
                }
                
                // Pozisyonlar boşsa, sadece mevcut taşı ekle
                if positions.isEmpty {
                    positions = [(row, col)]
                }
                
                // Pozisyonlar doğru sırayla olmalı (geriden ileriye)
                var forwardDirection = direction
                var startingPosition = positions.first!
                
                // Kelimeyi oluştur
                var word = ""
                for pos in positions {
                    word += board[pos.row][pos.col].letter
                }
                
                // Debug log
                print("DEBUG: Found potential word: \(word) in direction \(direction)")
                
                // Kelimeyi doğrula
                if word.count >= 2 && WordManager.shared.isValidWord(word.uppercased(with: Locale(identifier: "tr_TR"))) {
                    let points = calculatePoints(for: word, startingRow: startingPosition.row, startingCol: startingPosition.col, direction: forwardDirection)
                    
                    print("Detected word: \(word) at (\(startingPosition.row), \(startingPosition.col)) direction: \(forwardDirection)")
                    
                    possibleWords.append((word, startingPosition.row, startingPosition.col, forwardDirection, points))
                }
            }
        }
        
        // Tüm tahtayı tara (yerleştirilen taşları içeren kelimeleri bulmak için)
        for row in 0..<15 {
            for col in 0..<15 {
                // Sadece harf olan hücreleri kontrol et
                if !board[row][col].letter.isEmpty {
                    for direction in mainDirections {
                        // Her yönde mümkün olduğu kadar ilerle ve kelime oluştur
                        if row + direction.0 >= 0 && row + direction.0 < 15 &&
                           col + direction.1 >= 0 && col + direction.1 < 15 &&
                           !board[row + direction.0][col + direction.1].letter.isEmpty {
                            
                            // Kelimenin pozisyonlarını topla
                            var positions: [(row: Int, col: Int)] = [(row, col)]
                            var currentRow = row + direction.0
                            var currentCol = col + direction.1
                            var containsPlacedTile = placedTiles.contains { $0.row == row && $0.col == col }
                            
                            while currentRow >= 0 && currentRow < 15 &&
                                  currentCol >= 0 && currentCol < 15 &&
                                  !board[currentRow][currentCol].letter.isEmpty {
                                positions.append((currentRow, currentCol))
                                
                                // Yerleştirilen taşlardan birini içeriyor mu kontrol et
                                if placedTiles.contains(where: { $0.row == currentRow && $0.col == currentCol }) {
                                    containsPlacedTile = true
                                }
                                
                                currentRow += direction.0
                                currentCol += direction.1
                            }
                            
                            // En az bir yerleştirilen taşı içermeli ve en az 2 harf olmalı
                            if containsPlacedTile && positions.count >= 2 {
                                // Kelimeyi oluştur
                                var word = ""
                                for pos in positions {
                                    word += board[pos.row][pos.col].letter
                                }
                                
                                // Kelimeyi doğrula
                                if WordManager.shared.isValidWord(word.uppercased(with: Locale(identifier: "tr_TR"))) {
                                    // Tüm harfler bu pozisyonda mı?
                                    let placedTilePositions = placedTiles.map { ($0.row, $0.col) }

                                    let placedSequenceIsContiguous = placedTilePositions.allSatisfy { tilePos in
                                        positions.contains(where: { $0.row == tilePos.0 && $0.col == tilePos.1 })
                                    }

                                    // Eğer tüm placedTiles kelimenin içinde değilse => geçersiz
                                    if !placedSequenceIsContiguous {
                                        continue
                                    }
                                    let points = calculatePoints(for: word, startingRow: row, startingCol: col, direction: direction)
                                    
                                    print("Detected board word: \(word) at (\(row), \(col)) direction: \(direction)")
                                    
                                    possibleWords.append((word, row, col, direction, points))
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Çapraz kelime kontrolü için ayrı bir bölüm ekleyelim
        // Yerleştirilen taşların oluşturduğu çapraz kelimeleri kontrol et
        let diagonalDirections = [
            (-1, -1), (-1, 1),  // çapraz
            (1, -1), (1, 1)     // çapraz
        ]
        
        for placedTile in placedTiles {
            let row = placedTile.row
            let col = placedTile.col
            
            for direction in diagonalDirections {
                var positions: [(row: Int, col: Int)] = []
                
                // Geriye doğru giderek başlangıcı bul
                var currentRow = row
                var currentCol = col
                
                while currentRow >= 0 && currentRow < 15 &&
                      currentCol >= 0 && currentCol < 15 &&
                      !board[currentRow][currentCol].letter.isEmpty {
                    positions.insert((currentRow, currentCol), at: 0)
                    
                    currentRow -= direction.0
                    currentCol -= direction.1
                }
                
                // Başlangıcı düzelt
                currentRow += direction.0
                currentCol += direction.1
                
                // İleri doğru giderek devamını bul
                currentRow = row + direction.0
                currentCol = col + direction.1
                
                while currentRow >= 0 && currentRow < 15 &&
                      currentCol >= 0 && currentCol < 15 &&
                      !board[currentRow][currentCol].letter.isEmpty {
                    positions.append((currentRow, currentCol))
                    
                    currentRow += direction.0
                    currentCol += direction.1
                }
                
                // Pozisyonlar boşsa, sadece mevcut taşı ekle
                if positions.isEmpty {
                    positions = [(row, col)]
                }
                
                // Kelimeyi oluştur
                var word = ""
                for pos in positions {
                    word += board[pos.row][pos.col].letter
                }
                
                // Kelimeyi doğrula
                if word.count >= 2 && WordManager.shared.isValidWord(word.uppercased(with: Locale(identifier: "tr_TR"))) {
                    let startingPosition = positions.first!
                    let points = calculatePoints(for: word, startingRow: startingPosition.row, startingCol: startingPosition.col, direction: direction)
                    
                    print("Detected diagonal word: \(word) at (\(startingPosition.row), \(startingPosition.col)) direction: \(direction)")
                    
                    possibleWords.append((word, startingPosition.row, startingPosition.col, direction, points))
                }
            }
        }
        
        print("🏁 ConfirmedTiles: \(confirmedTiles.map { "(\($0.row), \($0.col))" })")
        // En iyi kelimeyi seç
        if let bestWord = possibleWords.max(by: { $0.points < $1.points }) {
            currentWord = bestWord.word
            isWordValid = true
            totalPoints = bestWord.points
            
            // Debug: En iyi kelime seçimi
            print("SELECTED BEST WORD: \(bestWord.word) with \(bestWord.points) points")
            currentWordPath = []
            var r = bestWord.startRow
            var c = bestWord.startCol
            for _ in 0..<bestWord.word.count {
                currentWordPath.append(TileCoordinate(row: r, col: c))
                r += bestWord.direction.0
                c += bestWord.direction.1
            }
        } else {
            // Geçerli kelime bulunamadı
            currentWord = getFormedLetters()
            isWordValid = false
            totalPoints = 0
            
            // Debug: Kelime bulunamadı
            print("NO VALID WORD FOUND. Raw letters: \(currentWord)")
        }
    }
    // Kullanıcının yerleştirdiği harfleri sırayla birleştir
    private func getFormedLetters() -> String {
        let letters = placedTiles.map { tile in
            return board[tile.row][tile.col].letter
        }
        return letters.joined()
    }
    private func setupBoard() {
        for row in 0..<15 {
            for col in 0..<15 {
                board[row][col] = Tile(letter: "", multiplier: boardTemplate[row][col])
            }
        }
        distributeMines()

        // 🔐 Sadece player1 Firebase'e yazar (çift yazımı engelle)
            if playerRole == "player1" {
                let boardLetters = board.map { row in row.map { $0.letter } }
                gameService.updateBoard(boardLetters, gameId: gameId)
            }
    }
    private func undoLastMove() {
        guard let lastTile = placedTiles.popLast() else { return }
        
        let row = lastTile.row
        let col = lastTile.col
        let letter = board[row][col].letter
        
        // Harfi board'dan sil
        board[row][col].letter = ""
        
        // Harfi tekrar eldeki harf havuzuna ekle
        letterRack.append(letter)
        
        // Seçili harfi sıfırla
        selectedLetter = nil
        
        // Eğer artık hiç yeni harf kalmadıysa ➔ currentWord'u ve skorları sıfırla
        if placedTiles.isEmpty {
            currentWord = ""
            isWordValid = nil
            totalPoints = 0
        } else {
            // Değilse, yeni duruma göre kelimeyi güncelle
            generateCurrentWord()
        }
    }
    
    private func confirmMove() {
        guard isMyTurn else {
            print("Sıra sende değil! Onaylayamazsın.")
            return
        }
        guard isWordValid == true else {
            print("Geçersiz kelime! Onaylanamaz.")
            return
        }

        for coord in placedTiles {
            if let mine = board[coord.row][coord.col].mine {
                handleMineEffect(mine)
                break
            }
        }

        confirmedTiles.append(contentsOf: placedTiles)

        switch currentPlayer {
        case .player1:
            player1Score += totalPoints
        case .player2:
            player2Score += totalPoints
        }
        gameService.updateScores(gameId: gameId, player1Score: player1Score, player2Score: player2Score)
        refillLetters()

        placedTiles.removeAll()
        currentWord = ""
        isWordValid = nil
        totalPoints = 0
        selectedLetter = nil
        movedTiles.removeAll()

        if isFirstMove {
            isFirstMove = false
            gameService.markFirstMoveDone(gameId: gameId)
        }

        let boardLetters = board.map { row in row.map { $0.letter } }
        gameService.updateBoard(boardLetters, gameId: gameId)
        gameService.switchTurn(gameId: gameId, to: currentPlayer == .player1 ? "player2" : "player1")
        // ✅ Eğer elde hiç harf kalmadıysa (taşlar bitti)
        if letterRack.isEmpty {
            // Karşı oyuncunun harflerini al
            gameService.fetchOpponentTiles(gameId: gameId, currentPlayer: playerRole) { opponentTiles in
                let opponentPenalty = opponentTiles.reduce(0) { $0 + letterPoint(for: Character($1)) }
                if playerRole == "player1" {
                    self.player1Score += opponentPenalty
                    self.player2Score -= opponentPenalty
                } else {
                    self.player2Score += opponentPenalty
                    self.player1Score -= opponentPenalty
                }
                
                // Skorları güncelle ve oyunu bitir
                gameService.updateScores(gameId: gameId, player1Score: self.player1Score, player2Score: self.player2Score)
                gameService.finishGame(gameId: gameId, winner: playerRole)
            }
        }
    }
    private func mineDescription(_ mine: MineType?) -> String {
        switch mine {
        case .puanBol: return "Bu harf bir Puan Bölünmesi mayınına denk geldi. Puanının %30'unu aldın!"
        case .puanTransfer: return "Bu harf Puan Transferi mayınına denk geldi. Puan rakibe verildi!"
        case .harfKaybı: return "Bu harf Harf Kaybı mayınına denk geldi. Elindeki harfler değiştirildi!"
        case .ekstraHamleEngeli: return "Ekstra Hamle Engeli mayınına denk geldin. Çarpan etkileri iptal!"
        case .kelimeIptali: return "Kelime İptali mayınına denk geldin. Bu kelimeden puan alamazsın!"
        default: return "Bilinmeyen mayın."
        }
    }
    private func handleMineEffect(_ mine: MineType) {
        triggeredMine = mine
        showMineAlert = true
        switch mine {
        case .puanBol:
            totalPoints = Int(Double(totalPoints) * 0.3)
        case .puanTransfer:
            switch currentPlayer {
            case .player1:
                player2Score += totalPoints
            case .player2:
                player1Score += totalPoints
            }
            totalPoints = 0
        case .harfKaybı:
            letterRack.removeAll()
            refillLetters()
        case .ekstraHamleEngeli:
            // Bu durumda çarpanlar etkisizleştirilebilir (detaylı implementasyon için ayrı yapı gerekir)
            print("Ekstra hamle engeli etkisi aktif (çarpanlar etkisiz)")
        case .kelimeIptali:
            totalPoints = 0
        }
    }
    private func getFullWord(at row: Int, col: Int, dx: Int, dy: Int) -> (String, [TileCoordinate]) {
        var startRow = row
        var startCol = col

        // Başlangıç noktası: mevcut harfin başına git
        while startRow - dx >= 0, startRow - dx < 15,
              startCol - dy >= 0, startCol - dy < 15,
              !board[startRow - dx][startCol - dy].letter.isEmpty {
            startRow -= dx
            startCol -= dy
        }

        var word = ""
        var tiles: [TileCoordinate] = []
        var r = startRow
        var c = startCol

        while r >= 0, r < 15, c >= 0, c < 15, !board[r][c].letter.isEmpty {
            word += board[r][c].letter
            tiles.append(TileCoordinate(row: r, col: c))
            r += dx
            c += dy
        }

        return (word, tiles)
    }
    private func distributeMines() {
        var flatCoordinates: [TileCoordinate] = []

        for row in 0..<15 {
            for col in 0..<15 {
                let tile = board[row][col]
                if tile.multiplier == .none && board[row][col].mine == nil {
                    flatCoordinates.append(TileCoordinate(row: row, col: col))
                }
            }
        }

        flatCoordinates.shuffle()

        let mineCounts: [(MineType, Int)] = [
            (.puanBol, 5),
            (.puanTransfer, 4),
            (.harfKaybı, 3),
            (.ekstraHamleEngeli, 2),
            (.kelimeIptali, 2)
        ]

        var index = 0
        for (type, count) in mineCounts {
            for _ in 0..<count {
                if index < flatCoordinates.count {
                    let coord = flatCoordinates[index]
                    board[coord.row][coord.col].mine = type
                    index += 1
                }
            }
        }
    }
   
    private func placeLetter(row: Int, col: Int) {
        guard isMyTurn else {
            print("Sıra sende değil! Hamle yapamazsın.")
            return
        }
        guard let selected = selectedLetter else { return }
        if board[row][col].letter.isEmpty {
            if isFirstMove && placedTiles.isEmpty {
                if !(row == 7 && col == 7) {
                    print("İlk hamlede ortadan başlamak zorundasın!")
                    return
                }
            }

            board[row][col].letter = selected
            placedTiles.append(TileCoordinate(row: row, col: col))
            if let index = letterRack.firstIndex(of: selected) {
                letterRack.remove(at: index)
            }

            selectedLetter = nil
            generateCurrentWord()
        }
    }
}
