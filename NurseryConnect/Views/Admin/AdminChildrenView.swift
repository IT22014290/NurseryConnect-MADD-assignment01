import SwiftUI
import SwiftData

struct AdminChildrenView: View {
    @Query(sort: \Child.fullName) private var allChildren: [Child]
    @Environment(\.modelContext) private var modelContext
    @State private var searchText = ""
    @State private var showAddSheet = false

    var filtered: [Child] {
        searchText.isEmpty ? allChildren : allChildren.filter {
            $0.fullName.localizedCaseInsensitiveContains(searchText) ||
            $0.room.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                NurseryTheme.background.ignoresSafeArea()
                VStack(spacing: 0) {
                    ZStack {
                        LinearGradient(colors: [Color(hex: "#2C3E50"), Color(hex: "#3D5A73")],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                            .ignoresSafeArea(edges: .top)
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Label("All Children", systemImage: "person.3.fill")
                                    .font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
                                Text("\(allChildren.count) registered · \(allChildren.filter { $0.isCheckedIn }.count) in today")
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

                    // Search
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundStyle(NurseryTheme.textSecondary)
                        TextField("Search children or rooms…", text: $searchText)
                            .font(.system(size: 14))
                    }
                    .padding(.horizontal, 12).padding(.vertical, 10)
                    .background(NurseryTheme.cardBg)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal, 16).padding(.vertical, 10)

                    if filtered.isEmpty {
                        EmptyStateView(icon: "person.3", title: "No Children",
                                       message: "No children match your search.", color: .gray)
                        Spacer()
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 8) {
                                ForEach(filtered) { child in
                                    NavigationLink(destination: ChildProfileView(child: child)) {
                                        AdminChildRow(child: child)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 32)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddChildView()
        }
    }
}

struct AdminChildRow: View {
    let child: Child

    var body: some View {
        HStack(spacing: 12) {
            ChildAvatarView(initials: child.initials, size: 42, color: .gray, isCheckedIn: child.isCheckedIn)
            VStack(alignment: .leading, spacing: 3) {
                Text(child.fullName).font(.system(size: 14, weight: .semibold))
                HStack(spacing: 6) {
                    Text(child.room).font(.system(size: 11)).foregroundStyle(NurseryTheme.textSecondary)
                    if child.hasAllergens {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 10)).foregroundStyle(.orange)
                    }
                    if child.sendFlag {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10)).foregroundStyle(NurseryTheme.primary)
                    }
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                StatusPill(label: child.isCheckedIn ? "In" : "Out",
                           color: child.isCheckedIn ? .green : .gray)
                Text(child.displayAge).font(.system(size: 10)).foregroundStyle(NurseryTheme.textSecondary)
            }
        }
        .cardStyle(padding: 12)
    }
}
