import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @StateObject private var authService = AuthenticationService()
    @State private var showingSignOut = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Gradient fon
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.pink.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Foydalanuvchi ma'lumotlari
                    VStack(spacing: 20) {
                        // Avatar
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 120, height: 120)
                            .overlay(
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 80))
                                    .foregroundColor(.blue)
                            )
                        
                        // Ism
                        if let user = authService.currentUser {
                            Text(user.displayName ?? "Foydalanuvchi")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text(user.email ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 40)
                    
                    // Statistika kartlari
                    VStack(spacing: 15) {
                        ProfileStatCard(
                            icon: "calendar",
                            title: "Ro'yxatdan o'tgan sana",
                            value: formatDate(authService.currentUser?.metadata.creationDate)
                        )
                        
                        ProfileStatCard(
                            icon: "clock",
                            title: "So'nggi kirish",
                            value: formatDate(authService.currentUser?.metadata.lastSignInDate)
                        )
                        
                        ProfileStatCard(
                            icon: "checkmark.shield",
                            title: "Email tasdiqlandi",
                            value: authService.currentUser?.isEmailVerified == true ? "Ha" : "Yo'q"
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Chiqish tugmasi
                    VStack(spacing: 15) {
                        Button(action: {
                            showingSignOut = true
                        }) {
                            HStack {
                                Image(systemName: "arrow.right.square")
                                Text("Chiqish")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 40)
                        
                        if !authService.errorMessage.isEmpty {
                            Text(authService.errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert("Chiqish", isPresented: $showingSignOut) {
            Button("Bekor qilish", role: .cancel) { }
            Button("Chiqish", role: .destructive) {
                authService.signOut()
            }
        } message: {
            Text("Hisobingizdan chiqishni xohlaysizmi?")
        }
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Noma'lum" }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "uz_UZ")
        
        return formatter.string(from: date)
    }
}

struct ProfileStatCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
} 