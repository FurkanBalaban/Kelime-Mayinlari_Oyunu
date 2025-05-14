import Foundation

class RegisterViewModel: ObservableObject {
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String?
    @Published var isRegistered: Bool = false
    
    func register() {
        AuthService.shared.register(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    self?.isRegistered = true
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
