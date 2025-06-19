import SwiftUI
import Foundation

// MARK: - Models
struct WordData: Codable {
    let english: String
    let uzbek: String
    let partOfSpeech: String
    let frequency: Int
    let example: String?
}

enum WordFrequency: Int, CaseIterable {
    case top500 = 500
    case top1000 = 1000
    case top1500 = 1500
    case top2000 = 2000
    case top2500 = 2500
    case top3000 = 3000
    
    var title: String {
        return "Top \(rawValue)"
    }
    
    var color: Color {
        switch self {
        case .top500: return .red
        case .top1000: return .orange
        case .top1500: return .yellow
        case .top2000: return .green
        case .top2500: return .blue
        case .top3000: return .purple
        }
    }
}

enum StudyBox: Int, CaseIterable {
    case new = 0
    case box1 = 1
    case box2 = 2
    case box3 = 3
    case box4 = 4
    case box5 = 5
    case box6 = 6
    case box7 = 7
    case box8 = 8
    case box9 = 9
    case mastered = 10
    
    var daysToNextReview: Int {
        switch self {
        case .new: return 0
        case .box1: return 1
        case .box2: return 2
        case .box3: return 3
        case .box4: return 5
        case .box5: return 8
        case .box6: return 13
        case .box7: return 21
        case .box8: return 34
        case .box9: return 55
        case .mastered: return 89
        }
    }
    
    var displayName: String {
        switch self {
        case .new: return "Yangi so'zlar"
        case .box1: return "1-quti (1 kun)"
        case .box2: return "2-quti (2 kun)"
        case .box3: return "3-quti (3 kun)"
        case .box4: return "4-quti (5 kun)"
        case .box5: return "5-quti (8 kun)"
        case .box6: return "6-quti (13 kun)"
        case .box7: return "7-quti (21 kun)"
        case .box8: return "8-quti (34 kun)"
        case .box9: return "9-quti (55 kun)"
        case .mastered: return "O'rganilgan"
        }
    }
    
    var color: Color {
        switch self {
        case .new: return .gray
        case .box1: return .red
        case .box2: return .orange
        case .box3: return .yellow
        case .box4: return .green
        case .box5: return .blue
        case .box6: return .indigo
        case .box7: return .purple
        case .box8: return .pink
        case .box9: return .cyan
        case .mastered: return .mint
        }
    }
}

enum StudyMode: CaseIterable {
    case dueCards
    case allCards
    case specificBox(StudyBox)
    case frequencyLevel(WordFrequency)
    
    static var allCases: [StudyMode] {
        return [.dueCards, .allCards]
    }
    
    var displayName: String {
        switch self {
        case .dueCards: return "Takrorlash vaqti kelgan kartalar"
        case .allCards: return "Barcha kartalar"
        case .specificBox(let box): return box.displayName
        case .frequencyLevel(let freq): return freq.title
        }
    }
}

struct FlashCard: Identifiable {
    let id = UUID()
    let englishWord: String
    let uzbekTranslation: String
    let frequency: WordFrequency
    let partOfSpeech: String
    let example: String
    
    var currentBox: StudyBox = .new
    var correctCount: Int = 0
    var incorrectCount: Int = 0
    var lastReviewDate: Date?
    var nextReview: Date?
    var createdAt: Date = Date()
    
    var successRate: Double {
        let total = correctCount + incorrectCount
        guard total > 0 else { return 0.0 }
        return Double(correctCount) / Double(total) * 100
    }
    
    var isDue: Bool {
        guard let nextReview = nextReview else { return currentBox == .new }
        return nextReview <= Date()
    }
    
    mutating func markCorrect() {
        correctCount += 1
        lastReviewDate = Date()
        
        // Move to next box (Fibonacci SRS)
        if currentBox != .mastered {
            let nextBoxValue = min(currentBox.rawValue + 1, StudyBox.mastered.rawValue)
            currentBox = StudyBox(rawValue: nextBoxValue) ?? .mastered
        }
        
        // Set next review date
        updateNextReviewDate()
    }
    
    mutating func markIncorrect() {
        incorrectCount += 1
        lastReviewDate = Date()
        
        // Move back to previous box
        let previousBoxValue = max(currentBox.rawValue - 1, StudyBox.new.rawValue)
        currentBox = StudyBox(rawValue: previousBoxValue) ?? .new
        
        // Set next review date
        updateNextReviewDate()
    }
    
    private mutating func updateNextReviewDate() {
        let daysToAdd = currentBox.daysToNextReview
        nextReview = Calendar.current.date(byAdding: .day, value: daysToAdd, to: Date())
    }
}

// MARK: - ViewModel
class FlashCardViewModel: ObservableObject {
    @Published var allCards: [FlashCard] = []
    @Published var currentStudyMode: StudyMode = .dueCards
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var showingStatistics = false
    @Published var showingSettings = false
    @Published var showingBoxes = false
    @Published var showingAllWords = false
    
    // Study Session
    @Published var currentCardIndex = 0
    @Published var showingAnswer = false
    @Published var isStudySessionActive = false
    
    init() {
        loadCards()
    }
    
    // MARK: - Data Loading
    func loadCards() {
        isLoading = true
        allCards = loadWordsFromJSON()
        
        // Initialize new cards with review dates
        for index in allCards.indices {
            if allCards[index].currentBox == .new {
                allCards[index].nextReview = Date()
            }
        }
        
        isLoading = false
    }
    
    private func loadWordsFromJSON() -> [FlashCard] {
        guard let url = Bundle.main.url(forResource: "words3000", withExtension: "json") else {
            errorMessage = "words3000.json fayli topilmadi"
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let wordData = try JSONDecoder().decode([WordData].self, from: data)
            
            return wordData.map { word in
                let frequency: WordFrequency
                if word.frequency <= 500 {
                    frequency = .top500
                } else if word.frequency <= 1000 {
                    frequency = .top1000
                } else if word.frequency <= 1500 {
                    frequency = .top1500
                } else if word.frequency <= 2000 {
                    frequency = .top2000
                } else if word.frequency <= 2500 {
                    frequency = .top2500
                } else {
                    frequency = .top3000
                }
                
                return FlashCard(
                    englishWord: word.english,
                    uzbekTranslation: word.uzbek,
                    frequency: frequency,
                    partOfSpeech: word.partOfSpeech,
                    example: word.example ?? ""
                )
            }
        } catch {
            errorMessage = "JSON o'qishda xatolik: \(error.localizedDescription)"
            return []
        }
    }
    
    // MARK: - Study Session Management
    func startStudySession(mode: StudyMode) {
        currentStudyMode = mode
        currentCardIndex = 0
        showingAnswer = false
        isStudySessionActive = true
    }
    
    func endStudySession() {
        isStudySessionActive = false
        currentCardIndex = 0
        showingAnswer = false
    }
    
    func nextCard() {
        let cards = getCurrentCards()
        if currentCardIndex < cards.count - 1 {
            currentCardIndex += 1
            showingAnswer = false
        } else {
            endStudySession()
        }
    }
    
    func markCurrentCardCorrect() {
        let cards = getCurrentCards()
        guard currentCardIndex < cards.count else { return }
        
        let cardId = cards[currentCardIndex].id
        if let index = allCards.firstIndex(where: { $0.id == cardId }) {
            allCards[index].markCorrect()
        }
        nextCard()
    }
    
    func markCurrentCardIncorrect() {
        let cards = getCurrentCards()
        guard currentCardIndex < cards.count else { return }
        
        let cardId = cards[currentCardIndex].id
        if let index = allCards.firstIndex(where: { $0.id == cardId }) {
            allCards[index].markIncorrect()
        }
        nextCard()
    }
    
    // MARK: - Data Filtering
    func getCurrentCards() -> [FlashCard] {
        let filtered = getFilteredCards()
        
        if searchText.isEmpty {
            return filtered
        } else {
            return filtered.filter { card in
                card.englishWord.lowercased().contains(searchText.lowercased()) ||
                card.uzbekTranslation.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    private func getFilteredCards() -> [FlashCard] {
        switch currentStudyMode {
        case .dueCards:
            return getDueCards()
        case .allCards:
            return allCards
        case .specificBox(let box):
            return allCards.filter { $0.currentBox == box }
        case .frequencyLevel(let freq):
            return allCards.filter { $0.frequency == freq }
        }
    }
    
    func getDueCards() -> [FlashCard] {
        return allCards.filter { $0.isDue }
    }
    
    func getCardsInBox(_ box: StudyBox) -> [FlashCard] {
        return allCards.filter { $0.currentBox == box }
    }
    
    // MARK: - Statistics
    func getTotalWords() -> Int {
        return allCards.count
    }
    
    func getMasteredWords() -> Int {
        return allCards.filter { $0.currentBox == .mastered }.count
    }
    
    func getAverageSuccessRate() -> Double {
        guard !allCards.isEmpty else { return 0.0 }
        let total = allCards.reduce(0.0) { $0 + $1.successRate }
        return total / Double(allCards.count)
    }
    
    func getWordsByFrequency(_ frequency: WordFrequency) -> [FlashCard] {
        return allCards.filter { $0.frequency == frequency }
    }
    
    func getStatsByBox() -> [(StudyBox, Int)] {
        return StudyBox.allCases.map { box in
            (box, getCardsInBox(box).count)
        }
    }
} 
