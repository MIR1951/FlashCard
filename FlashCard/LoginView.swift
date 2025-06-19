import SwiftUI

struct LoginView: View {
    @StateObject private var authService = AuthenticationService()
    @State private var email = ""
    @State private var password = ""
    @State private var isShowingSignUp = false
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Gradient fon
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Logo va sarlavha
                    VStack(spacing: 20) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        Text("FlashCard")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Ingliz tilini o'rganing")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 30)
                    
                    // Kirish formi
                    VStack(spacing: 20) {
                        // Email
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            TextField("Email manzilingizni kiriting", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                        
                        // Parol
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Parol")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            SecureField("Parolingizni kiriting", text: $password)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                        
                        // Xatolik xabari
                        if !authService.errorMessage.isEmpty {
                            Text(authService.errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Kirish tugmasi
                        Button(action: {
                            Task {
                                isLoading = true
                                await authService.signIn(email: email, password: password)
                                isLoading = false
                            }
                        }) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("Kirish")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(email.isEmpty || password.isEmpty || isLoading)
                    }
                    .padding(.horizontal, 40)
                    
                    // Ro'yxatdan o'tish va parolni tiklash
                    VStack(spacing: 15) {
                        Button("Parolni unutdingizmi?") {
                            Task {
                                await authService.resetPassword(email: email)
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .disabled(email.isEmpty)
                        
                        HStack {
                            Text("Hisobingiz yo'qmi?")
                                .foregroundColor(.secondary)
                            
                            Button("Ro'yxatdan o'ting") {
                                isShowingSignUp = true
                            }
                            .foregroundColor(.blue)
                            .fontWeight(.medium)
                        }
                        .font(.subheadline)
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $isShowingSignUp) {
            SignUpView()
        }
    }
} 