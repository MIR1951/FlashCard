import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = FlashCardViewModel()
    @EnvironmentObject var authService: AuthenticationService
    @State private var showingProfile = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if viewModel.isLoading {
                    LoadingView()
                } else if viewModel.isStudySessionActive {
                    StudySessionView(viewModel: viewModel)
                } else {
                    MainDashboardView(viewModel: viewModel)
                }
            }
            .navigationTitle("FlashCard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingProfile = true
                    }) {
                        Image(systemName: "person.circle")
                            .font(.title2)
                    }
                    
                    Button("Statistika") {
                        viewModel.showingStatistics = true
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showingStatistics) {
            StatisticsView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showingSettings) {
            SettingsView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showingBoxes) {
            BoxesView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showingAllWords) {
            AllWordsView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingProfile) {
            ProfileView()
                .environmentObject(authService)
        }
        .alert("Xatolik", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }
}

// MARK: - Main Dashboard
struct MainDashboardView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Quick Stats
                QuickStatsView(viewModel: viewModel)
                
                // Study Modes
                StudyModesView(viewModel: viewModel)
                
                // Search Bar
                SearchBar(text: $viewModel.searchText)
                
                // Word List
                WordListView(viewModel: viewModel)
            }
            .padding()
        }
    }
}

// MARK: - Quick Stats
struct QuickStatsView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Tezkor ko'rsatkichlar")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Jami so'zlar",
                    value: "\(viewModel.getTotalWords())",
                    color: .blue,
                    icon: "book.fill"
                )
                
                StatCard(
                    title: "O'rganilgan",
                    value: "\(viewModel.getMasteredWords())",
                    color: .green,
                    icon: "checkmark.circle.fill"
                )
                
                StatCard(
                    title: "Takrorlash",
                    value: "\(viewModel.getDueCards().count)",
                    color: .orange,
                    icon: "clock.fill"
                )
            }
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
        .shadow(radius: 4)
    }
}

// MARK: - Study Modes
struct StudyModesView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text("O'qish rejimlari")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StudyModeButton(
                    title: "Takrorlash vaqti kelgan",
                    subtitle: "\(viewModel.getDueCards().count) ta karta",
                    color: .orange,
                    icon: "clock.fill"
                ) {
                    viewModel.startStudySession(mode: .dueCards)
                }
                
                StudyModeButton(
                    title: "Barcha kartalar",
                    subtitle: "\(viewModel.getTotalWords()) ta karta",
                    color: .blue,
                    icon: "rectangle.stack.fill"
                ) {
                    viewModel.startStudySession(mode: .allCards)
                }
                
                StudyModeButton(
                    title: "Top 500 so'zlar",
                    subtitle: "\(viewModel.getWordsByFrequency(.top500).count) ta",
                    color: .red,
                    icon: "star.fill"
                ) {
                    viewModel.startStudySession(mode: .frequencyLevel(.top500))
                }
                
                StudyModeButton(
                    title: "Qutilar bo'yicha",
                    subtitle: "Spaced Repetition",
                    color: .purple,
                    icon: "archivebox.fill"
                ) {
                    viewModel.showingBoxes = true
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
        .shadow(radius: 4)
    }
}

// MARK: - Study Mode Button
struct StudyModeButton: View {
    let title: String
    let subtitle: String
    let color: Color
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 100)
            .background(color.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Word List
struct WordListView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("So'zlar ro'yxati")
                .font(.title2)
                .fontWeight(.bold)
            
            let currentCards = viewModel.getCurrentCards()
            
            HStack {
                Text("Ko'rsatilmoqda: \(currentCards.count)/\(viewModel.getTotalWords())")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("Barchasi") {
                    viewModel.showingAllWords = true
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            .padding(.bottom, 8)
            
            if currentCards.isEmpty {
                EmptyStateView()
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(currentCards.prefix(20)) { card in
                        WordRowView(card: card)
                    }
                    
                    if currentCards.count > 20 {
                        Text("Va yana \(currentCards.count - 20) ta so'z...")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
        .shadow(radius: 4)
    }
}

// MARK: - Word Row
struct WordRowView: View {
    let card: FlashCard
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(card.englishWord)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(card.uzbekTranslation)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text(card.partOfSpeech)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(4)
                    
                    if card.successRate > 0 {
                        Text("\(Int(card.successRate))% muvaffaqiyat")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Circle()
                    .fill(card.currentBox.color)
                    .frame(width: 12, height: 12)
                
                Text("Box \(card.currentBox.rawValue)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 1)
    }
}

// MARK: - Supporting Views
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("So'zlar yuklanmoqda...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("Hech qanday so'z topilmadi")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Qidiruv so'zini o'zgartiring yoki boshqa rejimni tanlang")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("So'z qidirish...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
        .shadow(radius: 4)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
} 