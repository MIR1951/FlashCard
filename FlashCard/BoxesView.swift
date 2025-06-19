import SwiftUI

struct BoxesView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Spaced Repetition System")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("So'zlar qutilar bo'yicha taqsimlangan")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    // Boxes Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(StudyBox.allCases, id: \.rawValue) { box in
                            BoxCard(
                                box: box,
                                count: viewModel.getCardsInBox(box).count,
                                viewModel: viewModel
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Qutilar")
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

// MARK: - Box Card
struct BoxCard: View {
    let box: StudyBox
    let count: Int
    @ObservedObject var viewModel: FlashCardViewModel
    @State private var showingBoxDetail = false
    
    var body: some View {
        Button(action: {
            showingBoxDetail = true
        }) {
            VStack(spacing: 12) {
                // Box icon and color
                Circle()
                    .fill(box.color)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text("\(box.rawValue)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
                
                // Box name
                Text(box.displayName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                // Word count
                Text("\(count) ta so'z")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Next review info
                if box != .new && box != .mastered {
                    Text("\(box.daysToNextReview) kun interval")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Study button
                if count > 0 {
                    Button("O'rganish") {
                        viewModel.startStudySession(mode: .specificBox(box))
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(box.color)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(box.color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingBoxDetail) {
            BoxDetailView(box: box, viewModel: viewModel)
        }
    }
}

// MARK: - Box Detail View
struct BoxDetailView: View {
    let box: StudyBox
    @ObservedObject var viewModel: FlashCardViewModel
    @Environment(\.dismiss) private var dismiss
    
    private var wordsInBox: [FlashCard] {
        viewModel.getCardsInBox(box)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 12) {
                    Circle()
                        .fill(box.color)
                        .frame(width: 60, height: 60)
                        .overlay(
                            Text("\(box.rawValue)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        )
                    
                    Text(box.displayName)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("\(wordsInBox.count) ta so'z")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if box != .new && box != .mastered {
                        Text("Takrorlash intervali: \(box.daysToNextReview) kun")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.8))
                .cornerRadius(16)
                .shadow(radius: 4)
                
                // Action buttons
                if !wordsInBox.isEmpty {
                    HStack(spacing: 16) {
                        Button("O'rganishni boshlash") {
                            viewModel.startStudySession(mode: .specificBox(box))
                            dismiss()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(box.color)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        
                        Button("So'zlarni ko'rish") {
                            // Show word list for this box
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(box.color.opacity(0.2))
                        .foregroundColor(box.color)
                        .cornerRadius(12)
                    }
                }
                
                // Words list preview
                if !wordsInBox.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("So'zlar ro'yxati")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(wordsInBox.prefix(10)) { card in
                                    WordRowView(card: card)
                                }
                                
                                if wordsInBox.count > 10 {
                                    Text("Va yana \(wordsInBox.count - 10) ta so'z...")
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
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "folder")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        
                        Text("Bu qutida hozircha so'zlar yo'q")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding(40)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Quti tafsilotlari")
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