import SwiftUI

struct AllWordsView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var sortOption: SortOption = .frequency
    @State private var filterOption: FilterOption = .all
    
    enum SortOption: String, CaseIterable {
        case frequency = "Chastotlik bo'yicha"
        case alphabetical = "Alifbo bo'yicha"
        case successRate = "Muvaffaqiyat bo'yicha"
        case boxLevel = "Quti darajasi bo'yicha"
    }
    
    enum FilterOption: String, CaseIterable {
        case all = "Barcha so'zlar"
        case new = "Yangi so'zlar"
        case learning = "O'rganilayotgan"
        case mastered = "O'rganilgan"
        case top500 = "Top 500"
        case top1000 = "Top 1000"
    }
    
    private var filteredAndSortedWords: [FlashCard] {
        var words = viewModel.allCards
        
        // Filter
        switch filterOption {
        case .all:
            break
        case .new:
            words = words.filter { $0.currentBox == .new }
        case .learning:
            words = words.filter { $0.currentBox != .new && $0.currentBox != .mastered }
        case .mastered:
            words = words.filter { $0.currentBox == .mastered }
        case .top500:
            words = words.filter { $0.frequency == .top500 }
        case .top1000:
            words = words.filter { $0.frequency == .top1000 }
        }
        
        // Sort
        switch sortOption {
        case .frequency:
            words = words.sorted { $0.frequency.rawValue < $1.frequency.rawValue }
        case .alphabetical:
            words = words.sorted { $0.englishWord.lowercased() < $1.englishWord.lowercased() }
        case .successRate:
            words = words.sorted { $0.successRate > $1.successRate }
        case .boxLevel:
            words = words.sorted { $0.currentBox.rawValue > $1.currentBox.rawValue }
        }
        
        // Search filter
        if !viewModel.searchText.isEmpty {
            words = words.filter { card in
                card.englishWord.lowercased().contains(viewModel.searchText.lowercased()) ||
                card.uzbekTranslation.lowercased().contains(viewModel.searchText.lowercased())
            }
        }
        
        return words
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with stats
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Jami so'zlar")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(viewModel.getTotalWords())")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Ko'rsatilmoqda")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(filteredAndSortedWords.count)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    // Search bar
                    SearchBar(text: $viewModel.searchText)
                }
                .padding()
                .background(Color.white.opacity(0.8))
                
                // Filter and Sort options
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        // Filter picker
                        Menu {
                            ForEach(FilterOption.allCases, id: \.rawValue) { option in
                                Button(option.rawValue) {
                                    filterOption = option
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "line.horizontal.3.decrease.circle")
                                Text(filterOption.rawValue)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                        }
                        
                        // Sort picker
                        Menu {
                            ForEach(SortOption.allCases, id: \.rawValue) { option in
                                Button(option.rawValue) {
                                    sortOption = option
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "arrow.up.arrow.down")
                                Text(sortOption.rawValue)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.green.opacity(0.1))
                            .foregroundColor(.green)
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                // Words list
                if filteredAndSortedWords.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("Hech qanday so'z topilmadi")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Filter yoki qidiruv shartlarini o'zgartiring")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(filteredAndSortedWords) { card in
                            DetailedWordRowView(card: card)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Barcha so'zlar")
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

// MARK: - Detailed Word Row
struct DetailedWordRowView: View {
    let card: FlashCard
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    // English word with frequency
                    HStack {
                        Text(card.englishWord)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Circle()
                            .fill(card.frequency.color)
                            .frame(width: 8, height: 8)
                        
                        Text("№\(card.frequency.rawValue)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Uzbek translation
                    Text(card.uzbekTranslation)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Part of speech and example
                    if !card.example.isEmpty {
                        Text("📝 \(card.example)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
            }
            
            // Stats row
            HStack {
                // Part of speech
                Text(card.partOfSpeech)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(4)
                
                Spacer()
                
                // Current box
                HStack(spacing: 4) {
                    Circle()
                        .fill(card.currentBox.color)
                        .frame(width: 8, height: 8)
                    
                    Text("Box \(card.currentBox.rawValue)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Success rate
                if card.correctCount + card.incorrectCount > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(.green)
                        
                        Text("\(Int(card.successRate))%")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                
                // Review count
                if card.correctCount + card.incorrectCount > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "repeat")
                            .foregroundColor(.orange)
                        
                        Text("\(card.correctCount + card.incorrectCount)")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
} 