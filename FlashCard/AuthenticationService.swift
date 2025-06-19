import Foundation
import FirebaseAuth

@MainActor
class AuthenticationService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var errorMessage = ""
    
    init() {
        // Auth holatini kuzatish
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUser = user
                self?.isAuthenticated = user != nil
            }
        }
    }
    
    // Ro'yxatdan o'tish
    func signUp(email: String, password: String, name: String) async {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            
            // Foydalanuvchi nomini o'rnatish
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = name
            try await changeRequest.commitChanges()
            
            self.errorMessage = ""
        } catch {
            self.errorMessage = getErrorMessage(error)
        }
    }
    
    // Kirish
    func signIn(email: String, password: String) async {
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
            self.errorMessage = ""
        } catch {
            self.errorMessage = getErrorMessage(error)
        }
    }
    
    // Chiqish
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.errorMessage = ""
        } catch {
            self.errorMessage = getErrorMessage(error)
        }
    }
    
    // Parolni tiklash
    func resetPassword(email: String) async {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            self.errorMessage = ""
        } catch {
            self.errorMessage = getErrorMessage(error)
        }
    }
    
    // Xatolik xabarlarini o'zbek tiliga tarjima qilish
    private func getErrorMessage(_ error: Error) -> String {
        let nsError = error as NSError
        
        switch nsError.code {
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return "Bu email manzil allaqachon ishlatilmoqda"
        case AuthErrorCode.weakPassword.rawValue:
            return "Parol juda zaif. Kamida 6 ta belgidan iborat bo'lishi kerak"
        case AuthErrorCode.invalidEmail.rawValue:
            return "Email manzil noto'g'ri formatda"
        case AuthErrorCode.userNotFound.rawValue:
            return "Foydalanuvchi topilmadi"
        case AuthErrorCode.wrongPassword.rawValue:
            return "Parol noto'g'ri"
        case AuthErrorCode.tooManyRequests.rawValue:
            return "Juda ko'p urinish. Biroz kuting"
        case AuthErrorCode.networkError.rawValue:
            return "Internet ulanishida xatolik"
        default:
            return "Noma'lum xatolik yuz berdi: \(error.localizedDescription)"
        }
    }
} 