import SwiftUI

struct SignUpView: View {
    @StateObject private var authService = AuthenticationService()
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    
    var isFormValid: Bool {
        !name.isEmpty && 
        !email.isEmpty && 
        !password.isEmpty && 
        password == confirmPassword && 
        password.count >= 6
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Gradient fon
                LinearGradient(
                    gradient: Gradient(colors: [Color.green.opacity(0.3), Color.blue.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Sarlavha
                        VStack(spacing: 15) {
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                            
                            Text("Ro'yxatdan o'tish")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Yangi hisob yarating")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 20)
                        
                        // Forma
                        VStack(spacing: 20) {
                            // Ism
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Ism")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                
                                TextField("Ismingizni kiriting", text: $name)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                            }
                            
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
                                
                                Text("Kamida 6 ta belgidan iborat bo'lishi kerak")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            // Parolni tasdiqlash
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Parolni tasdiqlang")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                
                                SecureField("Parolni qayta kiriting", text: $confirmPassword)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                
                                if !confirmPassword.isEmpty && password != confirmPassword {
                                    Text("Parollar mos kelmaydi")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                            
                            // Xatolik xabari
                            if !authService.errorMessage.isEmpty {
                                Text(authService.errorMessage)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            
                            // Ro'yxatdan o'tish tugmasi
                            Button(action: {
                                Task {
                                    isLoading = true
                                    await authService.signUp(email: email, password: password, name: name)
                                    isLoading = false
                                    
                                    if authService.isAuthenticated {
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }
                            }) {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Text("Ro'yxatdan o'tish")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isFormValid ? Color.green : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .disabled(!isFormValid || isLoading)
                        }
                        .padding(.horizontal, 30)
                        
                        // Kirish sahifasiga o'tish
                        HStack {
                            Text("Hisobingiz bormi?")
                                .foregroundColor(.secondary)
                            
                            Button("Kirish") {
                                presentationMode.wrappedValue.dismiss()
                            }
                            .foregroundColor(.green)
                            .fontWeight(.medium)
                        }
                        .font(.subheadline)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Bekor qilish") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.secondary)
            )
        }
    }
} 