import SwiftUI

struct StudySessionView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    
    var body: some View {
        let currentCards = viewModel.getCurrentCards()
        
        if currentCards.isEmpty {
            EmptyStudySessionView {
                viewModel.endStudySession()
            }
        } else if viewModel.currentCardIndex < currentCards.count {
            let card = currentCards[viewModel.currentCardIndex]
            
            VStack(spacing: 20) {
                // Progress indicator
                ProgressIndicator(
                    current: viewModel.currentCardIndex + 1,
                    total: currentCards.count
                )
                
                // Card View
                FlashCardView(
                    card: card,
                    showingAnswer: viewModel.showingAnswer
                ) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.showingAnswer.toggle()
                    }
                }
                
                // Action Buttons
                if viewModel.showingAnswer {
                    AnswerButtonsView(viewModel: viewModel)
                } else {
                    ShowAnswerButton {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.showingAnswer = true
                        }
                    }
                }
                
                // Exit Button
                ExitStudyButton {
                    viewModel.endStudySession()
                }
            }
            .padding()
        } else {
            StudyCompletionView {
                viewModel.endStudySession()
            }
        }
    }
}

// MARK: - Progress Indicator
struct ProgressIndicator: View {
    let current: Int
    let total: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Text("\(current) / \(total)")
                .font(.headline)
                .fontWeight(.semibold)
            
            ProgressView(value: Double(current), total: Double(total))
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .frame(height: 8)
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - Flash Card View
struct FlashCardView: View {
    let card: FlashCard
    let showingAnswer: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 20) {
                // Card content
                if showingAnswer {
                    AnswerSide(card: card)
                } else {
                    QuestionSide(card: card)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 300)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                showingAnswer ? Color.green.opacity(0.1) : Color.blue.opacity(0.1),
                                showingAnswer ? Color.green.opacity(0.05) : Color.blue.opacity(0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(radius: 8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        showingAnswer ? Color.green.opacity(0.3) : Color.blue.opacity(0.3),
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .rotation3DEffect(
            .degrees(showingAnswer ? 180 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(.easeInOut(duration: 0.6), value: showingAnswer)
    }
}

// MARK: - Question Side
struct QuestionSide: View {
    let card: FlashCard
    
    var body: some View {
        VStack(spacing: 16) {
            Text("English")
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            
            Text(card.englishWord)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            if !card.example.isEmpty {
                Text(card.example)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            Text("Tap kartani aylantirish uchun")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Answer Side
struct AnswerSide: View {
    let card: FlashCard
    
    var body: some View {
        VStack(spacing: 16) {
            Text("O'zbek")
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            
            Text(card.uzbekTranslation)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            HStack {
                Text(card.partOfSpeech)
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
                
                Circle()
                    .fill(card.frequency.color)
                    .frame(width: 8, height: 8)
                
                Text(card.frequency.title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if !card.example.isEmpty {
                Text(card.example)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
    }
}

// MARK: - Answer Buttons
struct AnswerButtonsView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    
    var body: some View {
        HStack(spacing: 20) {
            // Incorrect Button
            Button(action: {
                viewModel.markCurrentCardIncorrect()
            }) {
                HStack {
                    Image(systemName: "x.circle.fill")
                    Text("Bilmayman")
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .cornerRadius(12)
            }
            
            // Correct Button
            Button(action: {
                viewModel.markCurrentCardCorrect()
            }) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Bilaman")
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .cornerRadius(12)
            }
        }
    }
}

// MARK: - Show Answer Button
struct ShowAnswerButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "eye.fill")
                Text("Javobni ko'rsatish")
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .cornerRadius(12)
        }
    }
}

// MARK: - Exit Study Button
struct ExitStudyButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "xmark.circle")
                Text("Chiqish")
            }
            .foregroundColor(.red)
            .padding()
        }
    }
}

// MARK: - Empty Study Session
struct EmptyStudySessionView: View {
    let onExit: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Ajoyib!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Hozircha o'rganish uchun kartalar yo'q")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Bosh sahifaga qaytish") {
                onExit()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .padding()
    }
}

// MARK: - Study Completion
struct StudyCompletionView: View {
    let onExit: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "star.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
            
            Text("Tabriklaymiz!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Barcha kartalarni ko'rib chiqdingiz")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Bosh sahifaga qaytish") {
                onExit()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .padding()
    }
} 