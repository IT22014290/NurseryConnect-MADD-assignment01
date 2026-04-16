import SwiftUI
import SwiftData

struct MediaLibraryView: View {
    @Query(sort: \MediaPhoto.captureDate, order: .reverse) private var photos: [MediaPhoto]
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @State private var filterState = "all"
    @State private var showAddSheet = false

    let filters = [("all","All"),("pending","Pending"),("approved","Approved"),("posted","Posted")]

    var filtered: [MediaPhoto] {
        switch filterState {
        case "pending":  return photos.filter { !$0.isApprovedForSocial && !$0.postedToSocial }
        case "approved": return photos.filter { $0.isApprovedForSocial && !$0.postedToSocial }
        case "posted":   return photos.filter { $0.postedToSocial }
        default:         return photos
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            NurseryTheme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                // Header
                ZStack {
                    NurseryTheme.gradient(NurseryTheme.indigo).ignoresSafeArea(edges: .top)
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Label("Media Library", systemImage: "photo.stack.fill")
                                .font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
                            Text("\(photos.count) items · GDPR compliant workflow")
                                .font(.system(size: 13)).foregroundStyle(.white.opacity(0.75))
                        }
                        Spacer()
                        Button { showAddSheet = true } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 22)).foregroundStyle(.white)
                        }
                    }
                    .padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 14)
                }
                .frame(height: 90)

                // Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(filters, id: \.0) { (val, label) in
                            Button { filterState = val } label: {
                                Text(label)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(filterState == val ? .white : NurseryTheme.textSecondary)
                                    .padding(.horizontal, 14).padding(.vertical, 7)
                                    .background(filterState == val ? NurseryTheme.indigo : NurseryTheme.cardBg)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal, 16).padding(.vertical, 10)
                }

                if filtered.isEmpty {
                    EmptyStateView(icon: "photo.stack", title: "No Media",
                                   message: "No \(filterState == "all" ? "" : filterState) media items found.",
                                   color: NurseryTheme.indigo)
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 10) {
                            ForEach(filtered) { photo in
                                MediaPhotoCard(photo: photo)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 32)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddMediaPhotoView()
        }
    }
}

// MARK: - Media Photo Card

struct MediaPhotoCard: View {
    @Bindable var photo: MediaPhoto
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                // Photo placeholder (blurred indicator)
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(NurseryTheme.indigo.opacity(0.10))
                        .frame(width: 64, height: 64)
                    if photo.isBlurred {
                        Image(systemName: "eye.slash.fill")
                            .font(.system(size: 24)).foregroundStyle(NurseryTheme.indigo.opacity(0.5))
                    } else {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 24)).foregroundStyle(NurseryTheme.indigo)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(photo.caption.isEmpty ? "No caption" : photo.caption)
                        .font(.system(size: 14, weight: .semibold))
                        .lineLimit(2)
                    Label(photo.activityTag, systemImage: "tag.fill")
                        .font(.system(size: 11)).foregroundStyle(NurseryTheme.textSecondary)
                    Text("By \(photo.keyworkerName) · \(photo.captureDate.shortDateString)")
                        .font(.system(size: 10)).foregroundStyle(NurseryTheme.textSecondary)
                }
                Spacer()
                statusBadge
            }

            // Status line
            HStack(spacing: 8) {
                if photo.isBlurred {
                    Label("Face blurred", systemImage: "eye.slash.fill")
                        .font(.system(size: 10)).foregroundStyle(.gray)
                } else {
                    Label("Consent confirmed", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 10)).foregroundStyle(.green)
                }
            }

            // Action buttons
            HStack(spacing: 8) {
                if !photo.isApprovedForSocial && !photo.postedToSocial {
                    Button {
                        photo.isApprovedForSocial = true
                        photo.approvedByManager   = appState.currentUserName
                        photo.approvalDate        = Date()
                        try? modelContext.save()
                    } label: {
                        Label("Approve", systemImage: "checkmark.seal.fill")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .buttonStyle(PrimaryButtonStyle(color: NurseryTheme.indigo))
                }

                if photo.isApprovedForSocial && !photo.postedToSocial {
                    Button {
                        photo.postedToSocial = true
                        photo.postDate       = Date()
                        try? modelContext.save()
                    } label: {
                        Label("Mark as Posted", systemImage: "square.and.arrow.up.fill")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .buttonStyle(PrimaryButtonStyle(color: .green))
                }

                if photo.postedToSocial {
                    Label("Posted \(photo.postDate?.shortDateString ?? "")", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 12)).foregroundStyle(.green)
                }
            }
        }
        .cardStyle()
    }

    var statusBadge: some View {
        Group {
            if photo.postedToSocial {
                StatusPill(label: "Posted", color: .green)
            } else if photo.isApprovedForSocial {
                StatusPill(label: "Approved", color: NurseryTheme.indigo)
            } else {
                StatusPill(label: "Pending", color: .orange)
            }
        }
    }
}

// MARK: - Add Media Photo

struct AddMediaPhotoView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    @State private var caption     = ""
    @State private var activityTag = ""
    @State private var isBlurred   = true

    let activityTags = ["Art & Craft","Outdoor Play","Story Time","Music","Science","Cooking","Sports Day","Field Trip","Celebration","General"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Photo Details") {
                    TextField("Caption", text: $caption)
                    Picker("Activity Tag", selection: $activityTag) {
                        ForEach(activityTags, id: \.self) { Text($0).tag($0) }
                    }
                    .onAppear { if activityTag.isEmpty { activityTag = activityTags[0] } }
                }
                Section("Privacy") {
                    Toggle("Faces blurred / anonymised", isOn: $isBlurred)
                    if !isBlurred {
                        Label("Ensure explicit social media consent exists for all visible children before publishing.", systemImage: "exclamationmark.triangle.fill")
                            .font(.system(size: 11)).foregroundStyle(.orange)
                    }
                }
                Section {
                    GDPRNoticeBanner()
                }
            }
            .navigationTitle("Add Media")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let photo = MediaPhoto(activityTag: activityTag, caption: caption, keyworkerName: appState.currentUserName)
                        photo.isBlurred = isBlurred
                        modelContext.insert(photo)
                        try? modelContext.save()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
