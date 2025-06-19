import SwiftUI

struct StatisticsView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Overall Stats
                    OverallStatsSection(viewModel: viewModel)
                    
                    // Box Distribution
                    BoxDistributionSection(viewModel: viewModel)
                    
                    // Frequency Distribution
                    FrequencyDistributionSection(viewModel: viewModel)
                    
                    // Performance Stats
                    PerformanceStatsSection(viewModel: viewModel)
                }
                .padding()
            }
            .navigationTitle("Statistika")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Yopish") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Overall Stats Section
struct OverallStatsSection: View {
    @ObservedObject var viewModel: FlashCardViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Umumiy ko'rsatkichlar")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
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
                    title: "Takrorlash kerak",
                    value: "\(viewModel.getDueCards().count)",
                    color: .orange,
                    icon: "clock.fill"
                )
                
                StatCard(
                    title: "O'rtacha muvaffaqiyat",
                    value: "\(Int(viewModel.getAverageSuccessRate()))%",
                    color: .purple,
                    icon: "chart.line.uptrend.xyaxis"
                )
            }
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
        .shadow(radius: 4)
    }
}

// MARK: - Box Distribution Section
struct BoxDistributionSection: View {
    @ObservedObject var viewModel: FlashCardViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Qutilardagi taqsimot")
                .font(.title2)
                .fontWeight(.bold)
            
            let boxStats = viewModel.getStatsByBox()
            
            VStack(spacing: 8) {
                ForEach(boxStats, id: \.0.rawValue) { box, count in
                    BoxStatRow(box: box, count: count, total: viewModel.getTotalWords())
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
        .shadow(radius: 4)
    }
}

// MARK: - Box Stat Row
struct BoxStatRow: View {
    let box: StudyBox
    let count: Int
    let total: Int
    
    private var percentage: Double {
        guard total > 0 else { return 0.0 }
        return Double(count) / Double(total)
    }
    
    var body: some View {
        HStack {
            Circle()
                .fill(box.color)
                .frame(width: 12, height: 12)
            
            Text(box.displayName)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("\(count)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(box.color)
            
            // Progress bar
            ProgressView(value: percentage)
                .progressViewStyle(LinearProgressViewStyle(tint: box.color))
                .frame(width: 60)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Frequency Distribution Section
struct FrequencyDistributionSection: View {
    @ObservedObject var viewModel: FlashCardViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Chastotlik bo'yicha taqsimot")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 8) {
                ForEach(WordFrequency.allCases, id: \.rawValue) { frequency in
                    let words = viewModel.getWordsByFrequency(frequency)
                    let masteredWords = words.filter { $0.currentBox == .mastered }
                    
                    FrequencyStatRow(
                        frequency: frequency,
                        totalCount: words.count,
                        masteredCount: masteredWords.count
                    )
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
        .shadow(radius: 4)
    }
}

// MARK: - Frequency Stat Row
struct FrequencyStatRow: View {
    let frequency: WordFrequency
    let totalCount: Int
    let masteredCount: Int
    
    private var masteryPercentage: Double {
        guard totalCount > 0 else { return 0.0 }
        return Double(masteredCount) / Double(totalCount)
    }
    
    var body: some View {
        HStack {
            Circle()
                .fill(frequency.color)
                .frame(width: 12, height: 12)
            
            Text(frequency.title)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(masteredCount)/\(totalCount)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                if totalCount > 0 {
                    Text("\(Int(masteryPercentage * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Progress bar
            ProgressView(value: masteryPercentage)
                .progressViewStyle(LinearProgressViewStyle(tint: frequency.color))
                .frame(width: 60)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Performance Stats Section
struct PerformanceStatsSection: View {
    @ObservedObject var viewModel: FlashCardViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Performance ko'rsatkichlari")
                .font(.title2)
                .fontWeight(.bold)
            
            let allCards = viewModel.allCards
            let studiedCards = allCards.filter { $0.correctCount + $0.incorrectCount > 0 }
            
            if !studiedCards.isEmpty {
                let totalCorrect = studiedCards.reduce(0) { $0 + $1.correctCount }
                let totalIncorrect = studiedCards.reduce(0) { $0 + $1.incorrectCount }
                let totalReviews = totalCorrect + totalIncorrect
                
                VStack(spacing: 12) {
                    HStack {
                        VStack {
                            Text("\(totalCorrect)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            Text("To'g'ri javoblar")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack {
                            Text("\(totalIncorrect)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                            Text("Noto'g'ri javoblar")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    if totalReviews > 0 {
                        let successRate = Double(totalCorrect) / Double(totalReviews)
                        
                        VStack(spacing: 8) {
                            Text("Umumiy muvaffaqiyat darajasi")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("\(Int(successRate * 100))%")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(successRate > 0.7 ? .green : successRate > 0.5 ? .orange : .red)
                            
                            ProgressView(value: successRate)
                                .progressViewStyle(LinearProgressViewStyle(tint: successRate > 0.7 ? .green : successRate > 0.5 ? .orange : .red))
                        }
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "chart.bar")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    
                    Text("Hali statistika mavjud emas")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("So'zlarni o'rganishni boshlang")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(20)
            }
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
        .shadow(radius: 4)
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Qo'shimcha imkoniyatlar") {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Ma'lumotlarni qayta yuklash")
                        Spacer()
                        Button("Yuklash") {
                            viewModel.loadCards()
                        }
                    }
                    
                    HStack {
                        Image(systemName: "trash")
                        Text("Statistikani tozalash")
                        Spacer()
                        Button("Tozalash") {
                            // Reset all progress
                        }
                        .foregroundColor(.red)
                    }
                }
                
                Section("Ma'lumot") {
                    HStack {
                        Text("Versiya")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("So'zlar bazasi")
                        Spacer()
                        Text("\(viewModel.getTotalWords()) ta so'z")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Sozlamalar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Yopish") {
                        dismiss()
                    }
                }
            }
        }
    }
} 