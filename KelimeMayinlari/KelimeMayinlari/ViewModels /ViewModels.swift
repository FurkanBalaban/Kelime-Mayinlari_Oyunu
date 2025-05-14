import Foundation

class HomeViewModel: ObservableObject {
    
    @Published var isLoggedOut = false
    
    func signOut() {
        do {
            try AuthService.shared.signOut()
            isLoggedOut = true
        } catch {
            print("Çıkış sırasında hata oluştu: \(error.localizedDescription)")
        }
    }
}
