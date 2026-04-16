import SwiftUI
import SwiftData

struct ChildrenListView: View {
    @Environment(AppState.self) private var appState
    @Query(sort: \Child.fullName) private var allChildren: [Child]
    @State private var searchText = ""
    @State private var showingAddChild = false

    var myChildren: [Child] {
        let filtered = allChildren.filter { $0.keyworkerName == appState.currentUserName }
        if searchText.isEmpty { return filtered }
        return filtered.filter { $0.fullName.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                NurseryTheme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Custom header
                    ZStack {
                        NurseryTheme.teal.ignoresSafeArea(edges: .top)
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("My Children")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundStyle(.white)
                                Text("\(myChildren.count) assigned · \(myChildren.filter(\.isCheckedIn).count) checked in")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.white.opacity(0.75))
                            }
                            Spacer()
                            Button { showingAddChild = true } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .padding(.bottom, 14)
                    }
                    .frame(height: 90)

                    // Search
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundStyle(NurseryTheme.textSecondary)
                        TextField("Search children...", text: $searchText)
                            .font(.system(size: 14))
                    }
                    .padding(12)
                    .background(NurseryTheme.cardBg)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.15), lineWidth: 1))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                    if myChildren.isEmpty {
                        EmptyStateView(icon: "person.2", title: searchText.isEmpty ? "No children assigned" : "No results",
                                       message: searchText.isEmpty ? "Children assigned to you will appear here." : "Try a different name.")
                        Spacer()
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 10) {
                                ForEach(myChildren) { child in
                                    NavigationLink(destination: ChildProfileView(child: child)) {
                                        ChildListCard(child: child)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 24)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddChild) {
                AddChildView()
            }
        }
    }
}

// MARK: - Child List Card

struct ChildListCard: View {
    let child: Child

    var body: some View {
        HStack(spacing: 14) {
            ChildAvatarView(initials: child.initials, size: 54, color: avatarColor, isCheckedIn: child.isCheckedIn)

            VStack(alignment: .leading, spacing: 5) {
                Text(child.fullName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(NurseryTheme.textPrimary)

                HStack(spacing: 6) {
                    Label(child.displayAge, systemImage: "birthday.cake")
                        .font(.system(size: 12))
                        .foregroundStyle(NurseryTheme.textSecondary)
                    Text("·")
                        .foregroundStyle(NurseryTheme.textSecondary)
                    Text(child.room)
                        .font(.system(size: 12))
                        .foregroundStyle(NurseryTheme.textSecondary)
                }

                HStack(spacing: 6) {
                    if child.hasAllergens {
                        Label(child.allergens.prefix(2).joined(separator: ", "), systemImage: "allergens")
                            .font(.system(size: 11))
                            .foregroundStyle(child.allergenSeverity == "anaphylactic" ? .red : .orange)
                    }
                    if !child.dietaryRequirements.isEmpty {
                        Label(child.dietaryRequirements.components(separatedBy: ",").first ?? "", systemImage: "fork.knife")
                            .font(.system(size: 11))
                            .foregroundStyle(NurseryTheme.primary)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                StatusPill(
                    label: child.isCheckedIn ? "In" : "Out",
                    color: child.isCheckedIn ? .green : .gray
                )
                if child.isCheckedIn, let t = child.checkInTime {
                    Text(t.shortTimeString)
                        .font(.system(size: 10))
                        .foregroundStyle(NurseryTheme.textSecondary)
                }
            }
        }
        .cardStyle()
    }

    var avatarColor: Color {
        let colors: [Color] = [NurseryTheme.teal, NurseryTheme.purple, NurseryTheme.primary, NurseryTheme.orange, NurseryTheme.pink]
        let idx = abs(child.fullName.hashValue) % colors.count
        return colors[idx]
    }
}
