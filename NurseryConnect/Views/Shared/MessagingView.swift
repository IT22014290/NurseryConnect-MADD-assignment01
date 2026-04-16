import SwiftUI
import SwiftData

struct MessagingView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Message.timestamp, order: .reverse) private var allMessages: [Message]

    @State private var newMessage = ""
    @State private var selectedChildName = ""
    @State private var showingCompose = false

    var myMessages: [Message] {
        allMessages.filter {
            $0.senderName == appState.currentUserName || $0.recipientName == appState.currentUserName || $0.recipientName == "All Staff"
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                NurseryTheme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    if myMessages.isEmpty {
                        EmptyStateView(icon: "envelope.fill", title: "No Messages", message: "Your messages will appear here.")
                            .padding(.top, 80)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(myMessages) { msg in
                                    MessageBubble(message: msg, currentUser: appState.currentUserName)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                            .padding(.bottom, 90)
                        }
                    }
                }

                // Compose bar
                VStack(spacing: 0) {
                    Divider()
                    HStack(spacing: 12) {
                        TextField("Type a message...", text: $newMessage, axis: .vertical)
                            .font(.system(size: 14))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(NurseryTheme.cardBg)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                            .lineLimit(1...4)

                        Button {
                            sendMessage()
                        } label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 34))
                                .foregroundStyle(newMessage.isEmpty ? Color.gray.opacity(0.3) : NurseryTheme.primary)
                        }
                        .disabled(newMessage.isEmpty)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(NurseryTheme.background)
                }
            }
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func sendMessage() {
        let trimmed = newMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let recipient: String
        let recipientRole: String
        let senderRole = appState.selectedRole?.rawValue ?? "Staff"

        switch appState.selectedRole {
        case .parent:
            recipient = "Sarah Johnson"; recipientRole = "Keyworker"
        case .keyworker:
            recipient = "Mrs. Karen White"; recipientRole = "Setting Manager"
        default:
            recipient = "All Staff"; recipientRole = "Staff"
        }

        let msg = Message(
            senderName: appState.currentUserName,
            senderRole: senderRole,
            recipientName: recipient,
            recipientRole: recipientRole,
            content: trimmed,
            childName: appState.parentChildName
        )
        modelContext.insert(msg)
        try? modelContext.save()
        newMessage = ""
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let message: Message
    let currentUser: String

    var isFromMe: Bool { message.senderName == currentUser }

    var body: some View {
        HStack {
            if isFromMe { Spacer(minLength: 60) }

            VStack(alignment: isFromMe ? .trailing : .leading, spacing: 4) {
                if !isFromMe {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(NurseryTheme.primary.opacity(0.2))
                            .frame(width: 28, height: 28)
                            .overlay(
                                Text(message.senderName.prefix(1))
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(NurseryTheme.primary)
                            )
                        Text(message.senderName)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(NurseryTheme.textSecondary)
                        if !message.childName.isEmpty {
                            Text("· \(message.childName)")
                                .font(.system(size: 11))
                                .foregroundStyle(NurseryTheme.textSecondary.opacity(0.7))
                        }
                    }
                }

                Text(message.content)
                    .font(.system(size: 14))
                    .foregroundStyle(isFromMe ? .white : NurseryTheme.textPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(isFromMe ? NurseryTheme.primary : NurseryTheme.cardBg)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.04), radius: 4)

                Text(message.timestamp.timeAgoString)
                    .font(.system(size: 10))
                    .foregroundStyle(NurseryTheme.textSecondary.opacity(0.6))
            }

            if !isFromMe { Spacer(minLength: 60) }
        }
    }
}
