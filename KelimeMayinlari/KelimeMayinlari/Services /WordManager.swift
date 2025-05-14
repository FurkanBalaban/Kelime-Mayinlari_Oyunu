import Foundation

class WordManager {
    
    static let shared = WordManager()
    
    private(set) var wordList: [String] = []
    
    private init() {
        loadWords()
    }
    
    private func loadWords() {
        if let url = Bundle.main.url(forResource: "kelimeler", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decodedWords = try JSONDecoder().decode([String].self, from: data)
                // 🔥 Türkçe uppercased
                wordList = decodedWords.map { $0.uppercased(with: Locale(identifier: "tr_TR")) }
            } catch {
                print("Kelime listesi yüklenemedi: \(error.localizedDescription)")
            }
        } else {
            print("kelimeler.json dosyası bulunamadı!")
        }
    }
    
    func isValidWord(_ word: String) -> Bool {
        // 🔥 Kullanıcının yazdığı kelimeyi de Türkçe uppercased yapıyoruz
        return wordList.contains(word.uppercased(with: Locale(identifier: "tr_TR")))
    }
}
