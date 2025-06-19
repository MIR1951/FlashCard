//
//  ContentView.swift
//  FlashCard
//
//  Created by Kenjaboy Xajiyev on 19/06/25.
//

import SwiftUI
import Foundation

// MARK: - Spaced Repetition System Models
enum StudyBox: Int, CaseIterable {
    case new = 0        // Yangi so'zlar
    case box1 = 1       // 1 kun
    case box2 = 2       // 3 kun
    case box3 = 3       // 7 kun
    case box4 = 4       // 14 kun
    case box5 = 5       // 30 kun
    case box6 = 6       // 60 kun
    case box7 = 7       // 120 kun
    case box8 = 8       // 240 kun
    case box9 = 9       // 365 kun
    case mastered = 10  // Doimiy o'rganilgan
    
    var intervalDays: Int {
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
    
    var title: String {
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
        case .new: return .blue
        case .box1: return .orange
        case .box2: return .yellow
        case .box3: return .green
        case .box4: return .teal
        case .box5: return .cyan
        case .box6: return .indigo
        case .box7: return .purple
        case .box8: return .pink
        case .box9: return .brown
        case .mastered: return .mint
        }
    }
}

enum WordFrequency: Int {
    case top500 = 500
    case top1000 = 1000
    case top1500 = 1500
    case top2000 = 2000
    case top2500 = 2500
    case top3000 = 3000
    
    var title: String {
        return "Top \(rawValue)"
    }
}

struct FlashCard: Identifiable {
    let id = UUID()
    let englishWord: String
    let uzbekTranslation: String
    let frequency: WordFrequency
    let partOfSpeech: String
    let example: String?
    
    // Spaced Repetition ma'lumotlari
    var currentBox: StudyBox = .new
    var lastStudied: Date?
    var nextReview: Date?
    var correctCount: Int = 0
    var incorrectCount: Int = 0
    var totalReviews: Int = 0
    
    var successRate: Double {
        guard totalReviews > 0 else { return 0 }
        return Double(correctCount) / Double(totalReviews) * 100
    }
    
    var isDueForReview: Bool {
        guard let nextReview = nextReview else { return currentBox == .new }
        return Date() >= nextReview
    }
    
    mutating func moveToNextBox() {
        let nextBoxValue = min(currentBox.rawValue + 1, StudyBox.mastered.rawValue)
        currentBox = StudyBox(rawValue: nextBoxValue) ?? .mastered
        lastStudied = Date()
        nextReview = Calendar.current.date(byAdding: .day, value: currentBox.intervalDays, to: Date())
        correctCount += 1
        totalReviews += 1
    }
    
    mutating func moveToPreviousBox() {
        let previousBoxValue = max(currentBox.rawValue - 1, StudyBox.new.rawValue)
        currentBox = StudyBox(rawValue: previousBoxValue) ?? .new
        lastStudied = Date()
        nextReview = Calendar.current.date(byAdding: .day, value: currentBox.intervalDays, to: Date())
        incorrectCount += 1
        totalReviews += 1
    }
}

class FlashCardManager: ObservableObject {
    @Published var allCards: [FlashCard] = []
    
    init() {
        loadCards()
    }
    
    private func loadCards() {
        // Top 100 eng muhim so'zlar - qolganlarini asta-sekin qo'shamiz
        allCards = [
            // Top 50 eng muhim so'zlar
            FlashCard(englishWord: "the", uzbekTranslation: "bu, u", frequency: .top500, partOfSpeech: "Article", example: "The book is on the table"),
            FlashCard(englishWord: "be", uzbekTranslation: "bo'lmoq", frequency: .top500, partOfSpeech: "Verb", example: "I want to be happy"),
            FlashCard(englishWord: "to", uzbekTranslation: "ga, -ga", frequency: .top500, partOfSpeech: "Preposition", example: "Go to school"),
            FlashCard(englishWord: "of", uzbekTranslation: "-ning", frequency: .top500, partOfSpeech: "Preposition", example: "Book of science"),
            FlashCard(englishWord: "and", uzbekTranslation: "va", frequency: .top500, partOfSpeech: "Conjunction", example: "You and me"),
            FlashCard(englishWord: "a", uzbekTranslation: "bir", frequency: .top500, partOfSpeech: "Article", example: "A beautiful day"),
            FlashCard(englishWord: "in", uzbekTranslation: "ichida, -da", frequency: .top500, partOfSpeech: "Preposition", example: "In the house"),
            FlashCard(englishWord: "that", uzbekTranslation: "bu, o'sha", frequency: .top500, partOfSpeech: "Pronoun", example: "That is my car"),
            FlashCard(englishWord: "have", uzbekTranslation: "ega bo'lmoq", frequency: .top500, partOfSpeech: "Verb", example: "I have a book"),
            FlashCard(englishWord: "I", uzbekTranslation: "men", frequency: .top500, partOfSpeech: "Pronoun", example: "I am student"),
            
            FlashCard(englishWord: "it", uzbekTranslation: "u (narsa)", frequency: .top500, partOfSpeech: "Pronoun", example: "It is beautiful"),
            FlashCard(englishWord: "for", uzbekTranslation: "uchun", frequency: .top500, partOfSpeech: "Preposition", example: "Gift for you"),
            FlashCard(englishWord: "not", uzbekTranslation: "emas", frequency: .top500, partOfSpeech: "Adverb", example: "It is not good"),
            FlashCard(englishWord: "on", uzbekTranslation: "ustida", frequency: .top500, partOfSpeech: "Preposition", example: "Book on table"),
            FlashCard(englishWord: "with", uzbekTranslation: "bilan", frequency: .top500, partOfSpeech: "Preposition", example: "Come with me"),
            FlashCard(englishWord: "he", uzbekTranslation: "u (erkak)", frequency: .top500, partOfSpeech: "Pronoun", example: "He is teacher"),
            FlashCard(englishWord: "as", uzbekTranslation: "sifatida", frequency: .top500, partOfSpeech: "Conjunction", example: "Work as doctor"),
            FlashCard(englishWord: "you", uzbekTranslation: "siz, sen", frequency: .top500, partOfSpeech: "Pronoun", example: "You are kind"),
            FlashCard(englishWord: "do", uzbekTranslation: "qilmoq", frequency: .top500, partOfSpeech: "Verb", example: "Do your homework"),
            FlashCard(englishWord: "at", uzbekTranslation: "-da", frequency: .top500, partOfSpeech: "Preposition", example: "At home"),
            
            FlashCard(englishWord: "this", uzbekTranslation: "bu", frequency: .top500, partOfSpeech: "Pronoun", example: "This is my house"),
            FlashCard(englishWord: "but", uzbekTranslation: "lekin", frequency: .top500, partOfSpeech: "Conjunction", example: "Good but expensive"),
            FlashCard(englishWord: "his", uzbekTranslation: "uning", frequency: .top500, partOfSpeech: "Pronoun", example: "His book"),
            FlashCard(englishWord: "by", uzbekTranslation: "tomonidan", frequency: .top500, partOfSpeech: "Preposition", example: "Made by hand"),
            FlashCard(englishWord: "from", uzbekTranslation: "-dan", frequency: .top500, partOfSpeech: "Preposition", example: "From school"),
            FlashCard(englishWord: "they", uzbekTranslation: "ular", frequency: .top500, partOfSpeech: "Pronoun", example: "They are students"),
            FlashCard(englishWord: "we", uzbekTranslation: "biz", frequency: .top500, partOfSpeech: "Pronoun", example: "We are friends"),
            FlashCard(englishWord: "say", uzbekTranslation: "demoq", frequency: .top500, partOfSpeech: "Verb", example: "Say hello"),
            FlashCard(englishWord: "her", uzbekTranslation: "uning (ayol)", frequency: .top500, partOfSpeech: "Pronoun", example: "Her name"),
            FlashCard(englishWord: "she", uzbekTranslation: "u (ayol)", frequency: .top500, partOfSpeech: "Pronoun", example: "She is beautiful"),
            
            FlashCard(englishWord: "or", uzbekTranslation: "yoki", frequency: .top500, partOfSpeech: "Conjunction", example: "Tea or coffee"),
            FlashCard(englishWord: "an", uzbekTranslation: "bir", frequency: .top500, partOfSpeech: "Article", example: "An apple"),
            FlashCard(englishWord: "will", uzbekTranslation: "bo'ladi", frequency: .top500, partOfSpeech: "Modal", example: "I will come"),
            FlashCard(englishWord: "my", uzbekTranslation: "mening", frequency: .top500, partOfSpeech: "Pronoun", example: "My friend"),
            FlashCard(englishWord: "one", uzbekTranslation: "bir", frequency: .top500, partOfSpeech: "Number", example: "One book"),
            FlashCard(englishWord: "all", uzbekTranslation: "hammasi", frequency: .top500, partOfSpeech: "Pronoun", example: "All students"),
            FlashCard(englishWord: "would", uzbekTranslation: "edi", frequency: .top500, partOfSpeech: "Modal", example: "I would like"),
            FlashCard(englishWord: "there", uzbekTranslation: "u yerda", frequency: .top500, partOfSpeech: "Adverb", example: "There is book"),
            FlashCard(englishWord: "their", uzbekTranslation: "ularning", frequency: .top500, partOfSpeech: "Pronoun", example: "Their house")
        ]
        
        // Yangi so'zlar uchun next review o'rnatish
        for index in allCards.indices {
            if allCards[index].currentBox == .new {
                allCards[index].nextReview = Date()
            }
        }
    }
    
    func getDueCards() -> [FlashCard] {
        return allCards.filter { $0.isDueForReview }
    }
    
    func getCardsByBox(_ box: StudyBox) -> [FlashCard] {
        return allCards.filter { $0.currentBox == box }
    }
    
    func markCorrect(cardId: UUID) {
        if let index = allCards.firstIndex(where: { $0.id == cardId }) {
            allCards[index].moveToNextBox()
        }
    }
    
    func markIncorrect(cardId: UUID) {
        if let index = allCards.firstIndex(where: { $0.id == cardId }) {
            allCards[index].moveToPreviousBox()
        }
    }
}

struct ContentView: View {
    @StateObject private var cardManager = FlashCardManager()
    @State private var currentCardIndex = 0
    @State private var showTranslation = false
    @State private var showingStatistics = false
    @State private var showingBoxes = false
    @State private var studyMode: StudyMode = .dueCards
    @State private var selectedBox: StudyBox = .new
    
    enum StudyMode: CaseIterable {
        case dueCards, specificBox, allCards
        
        var title: String {
            switch self {
            case .dueCards: return "Takrorlash kerak"
            case .specificBox: return "Quti bo'yicha"
            case .allCards: return "Barcha so'zlar"
            }
        }
    }
    
    var currentCards: [FlashCard] {
        switch studyMode {
        case .dueCards:
            return cardManager.getDueCards()
        case .specificBox:
            return cardManager.getCardsByBox(selectedBox)
        case .allCards:
            return cardManager.allCards
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Top Statistics Bar
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Bugun")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(cardManager.getDueCards().count)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .center, spacing: 4) {
                        Text("Jami so'zlar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(cardManager.allCards.count)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("O'rganilgan")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(cardManager.getCardsByBox(.mastered).count)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Study Mode Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(StudyMode.allCases, id: \.self) { mode in
                            Button(action: {
                                studyMode = mode
                                currentCardIndex = 0
                                showTranslation = false
                            }) {
                                VStack(spacing: 4) {
                                    Text(mode.title)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(studyMode == mode ? .white : .blue)
                                    
                                    if mode == .dueCards {
                                        Text("\(cardManager.getDueCards().count)")
                                            .font(.caption)
                                            .foregroundColor(studyMode == mode ? .white : .red)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(studyMode == mode ? Color.blue : Color.blue.opacity(0.1))
                                .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Box Selector (when specific box mode)
                if studyMode == .specificBox {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(StudyBox.allCases, id: \.self) { box in
                                Button(action: {
                                    selectedBox = box
                                    currentCardIndex = 0
                                    showTranslation = false
                                }) {
                                    VStack(spacing: 2) {
                                        Text(box.title)
                                            .font(.system(size: 10, weight: .medium))
                                            .foregroundColor(selectedBox == box ? .white : box.color)
                                        
                                        Text("\(cardManager.getCardsByBox(box).count)")
                                            .font(.caption2)
                                            .foregroundColor(selectedBox == box ? .white : .secondary)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(selectedBox == box ? box.color : box.color.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Flash Card
                if !currentCards.isEmpty && currentCardIndex < currentCards.count {
                                         FlashCardView(
                         card: currentCards[currentCardIndex],
                         cardIndex: currentCardIndex,
                         totalCards: currentCards.count,
                         showTranslation: $showTranslation,
                         onCorrect: { cardManager.markCorrect(cardId: currentCards[currentCardIndex].id); nextCard() },
                         onIncorrect: { cardManager.markIncorrect(cardId: currentCards[currentCardIndex].id); nextCard() }
                     )
                } else {
                    // Empty State
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Ajoyib!")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Hozircha takrorlash uchun so'z yo'q")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(height: 300)
                }
                
                Spacer()
                
                // Bottom Buttons
                HStack(spacing: 15) {
                    Button(action: {
                        showingBoxes = true
                    }) {
                        HStack {
                            Image(systemName: "tray.2.fill")
                            Text("Qutilar")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        showingStatistics = true
                    }) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                            Text("Statistika")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(10)
                    }
                }
            }
            .padding()
            .navigationTitle("Smart Flashcards")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingStatistics) {
            StatisticsView(cardManager: cardManager)
        }
        .sheet(isPresented: $showingBoxes) {
            BoxesView(cardManager: cardManager)
        }
    }
    
    private func nextCard() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showTranslation = false
            if currentCardIndex < currentCards.count - 1 {
                currentCardIndex += 1
            } else {
                // Kartalar tugadi, boshqa rejimga o'tish
                studyMode = .dueCards
                currentCardIndex = 0
            }
        }
    }
}

struct FlashCardView: View {
    let card: FlashCard
    let cardIndex: Int
    let totalCards: Int
    @Binding var showTranslation: Bool
    let onCorrect: () -> Void
    let onIncorrect: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            // Card Info
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(cardIndex + 1) / \(totalCards)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(card.currentBox.title)
                        .font(.caption2)
                        .foregroundColor(card.currentBox.color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(card.currentBox.color.opacity(0.1))
                        .cornerRadius(6)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(card.frequency.title)
                        .font(.caption2)
                        .foregroundColor(.orange)
                    
                    if card.totalReviews > 0 {
                        Text("\(Int(card.successRate))%")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                }
            }
            
            // Main Card
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(card.currentBox.color.opacity(0.1))
                    .stroke(card.currentBox.color, lineWidth: 2)
                    .frame(height: 250)
                
                VStack(spacing: 20) {
                    Text(card.englishWord)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(card.partOfSpeech)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                    
                    if showTranslation {
                        VStack(spacing: 8) {
                            Text(card.uzbekTranslation)
                                .font(.title2)
                                .foregroundColor(.secondary)
                                .transition(.opacity)
                            
                            if let example = card.example {
                                Text("\"" + example + "\"")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .italic()
                                    .multilineTextAlignment(.center)
                                    .transition(.opacity)
                            }
                        }
                    }
                }
                .padding()
            }
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showTranslation.toggle()
                }
            }
            
            // Action Buttons
            if showTranslation {
                HStack(spacing: 20) {
                    Button(action: onIncorrect) {
                        VStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.red)
                            Text("Bilmadim")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    Button(action: onCorrect) {
                        VStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.green)
                            Text("Bildim")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
                .transition(.opacity)
            }
        }
    }
}

struct StatisticsView: View {
    @ObservedObject var cardManager: FlashCardManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Overall Stats
                    VStack(spacing: 15) {
                        Text("Umumiy statistika")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                            StatCard(title: "Jami so'zlar", value: "\(cardManager.allCards.count)", color: .blue)
                            StatCard(title: "Bugun", value: "\(cardManager.getDueCards().count)", color: .red)
                            StatCard(title: "O'rganilgan", value: "\(cardManager.getCardsByBox(.mastered).count)", color: .green)
                            StatCard(title: "O'rtacha %", value: "\(Int(averageSuccessRate))%", color: .orange)
                        }
                    }
                    
                    // Box Statistics
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Qutilar bo'yicha")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        ForEach(StudyBox.allCases, id: \.self) { box in
                            let count = cardManager.getCardsByBox(box).count
                            if count > 0 {
                                HStack {
                                    Circle()
                                        .fill(box.color)
                                        .frame(width: 12, height: 12)
                                    
                                    Text(box.title)
                                        .font(.body)
                                    
                                    Spacer()
                                    
                                    Text("\(count)")
                                        .font(.body)
                                        .fontWeight(.semibold)
                                        .foregroundColor(box.color)
                                }
                                .padding()
                                .background(box.color.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Statistika")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Yopish") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private var averageSuccessRate: Double {
        let cardsWithReviews = cardManager.allCards.filter { $0.totalReviews > 0 }
        guard !cardsWithReviews.isEmpty else { return 0 }
        return cardsWithReviews.map { $0.successRate }.reduce(0, +) / Double(cardsWithReviews.count)
    }
}

struct BoxesView: View {
    @ObservedObject var cardManager: FlashCardManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                ForEach(StudyBox.allCases, id: \.self) { box in
                    let cards = cardManager.getCardsByBox(box)
                    
                    NavigationLink(destination: BoxDetailView(box: box, cards: cards)) {
                        HStack {
                            Circle()
                                .fill(box.color)
                                .frame(width: 20, height: 20)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(box.title)
                                    .font(.headline)
                                
                                if box.intervalDays < 9999 {
                                    Text("Keyingi takror: \(box.intervalDays) kun")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("O'rganib bo'lingan")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                }
                            }
                            
                            Spacer()
                            
                            Text("\(cards.count)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(box.color)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Spaced Repetition Qutilar")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Yopish") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct BoxDetailView: View {
    let box: StudyBox
    let cards: [FlashCard]
    
    var body: some View {
        List {
            ForEach(cards) { card in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(card.englishWord)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(card.partOfSpeech)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color(.systemGray5))
                            .cornerRadius(6)
                    }
                    
                    Text(card.uzbekTranslation)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let example = card.example {
                        Text("\"" + example + "\"")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                    
                    HStack {
                        Text(card.frequency.title)
                            .font(.caption2)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(4)
                        
                        if card.totalReviews > 0 {
                            Text("\(Int(card.successRate))% (\(card.totalReviews) marta)")
                                .font(.caption2)
                                .foregroundColor(.green)
                        }
                        
                        Spacer()
                        
//                        if let nextReview = card.nextReview, nextReview > Date() {
//                            let formatter = DateFormatter()
//                            formatter.dateStyle = .short
//                            Text("Keyingi: \(formatter.string(from: nextReview))")
//                                .font(.caption2)
//                                .foregroundColor(.blue)
//                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle(box.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    ContentView()
}

                                  
