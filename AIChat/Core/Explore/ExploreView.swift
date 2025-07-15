//
//  ExploreView.swift
//  AIChat
//
//  Created by Michal Fereniec on 13/01/2025.
//

import SwiftUI

struct ExploreView: View {

    @Environment(AvatarManager.self) private var avatarManager
    @Environment(LogManager.self) private var logManager

    @State private var categories: [CharacterOption] = CharacterOption.allCases

    @State private var featuredAvatars: [AvatarModel] = []
    @State private var popularAvatars: [AvatarModel] = []
    @State private var isLoadingFeatured: Bool = true
    @State private var isLoadingPopular: Bool = true

    @State private var path: [NavigationPathOption] = []
    @State private var showDevSettings: Bool = true
    
    private var showDevSettingsButton: Bool {
        #if DEV || MOCK
        return true
        #else
        return false
        #endif
    }

    var body: some View {
        NavigationStack(path: $path) {
            List {
                if featuredAvatars.isEmpty && popularAvatars.isEmpty {
                    ZStack {
                        if isLoadingFeatured || isLoadingPopular {
                            loadingIndicator
                        } else {
                            errorMessageView
                        }
                    }
                    .removeListRowFormatting()
                }

                if !featuredAvatars.isEmpty {
                    featuredSection
                }

                if !popularAvatars.isEmpty {
                    categorySection
                    popularSection
                }
            }
            .navigationTitle("Explore")
            .screenAppearAnalytics(name: "ExploreView")
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    if showDevSettingsButton {
                        devSettingsButton
                    }
                }
            })
            .sheet(isPresented: $showDevSettings, content: {
                DevSettingsView()
            })
            .navigationDestinationForCoreModule(path: $path)
            .task {
                await loadFeaturedAvatars()
            }
            .task { // to put this into 2 seperate tasks is the simplest and best option in this case
                await loadPopularAvatars()
            }
        }
    }
    
    private var devSettingsButton: some View {
        Text("DEV 🤫")
            .badgeButton()
            .anyButton(.press) {
                onDevSettingsPressed()
            }
    }
    
    enum Event: LoggableEvent {
        case devSettingsPressed
        case tryAgainPressed
        case loadFeaturedAvatarsStart
        case loadFeaturedAvatarsSuccess(avatarCount: Int)
        case loadFeaturedAvatarsFail(error: Error)
        case loadPopularAvatarsStart
        case loadPopularAvatarsSuccess(avatarCount: Int)
        case loadPopularAvatarsFail(error: Error)
        case avatarPressed(avatar: AvatarModel)
        case categoryPressed(category: CharacterOption)
        
        var eventName: String {
            switch self {
            case .devSettingsPressed:              return "ExploreView_DevSettings_Pressed"
            case .tryAgainPressed:                 return "ExploreView_TryAgain_Pressed"
            case .loadFeaturedAvatarsStart:        return "ExploreView_LoadAvatars_Start"
            case .loadFeaturedAvatarsSuccess:      return "ExploreView_LoadAvatars_Success"
            case .loadFeaturedAvatarsFail:         return "ExploreView_LoadAvatars_Fail"
            case .loadPopularAvatarsStart:         return "ExploreView_PopularAvatars_Start"
            case .loadPopularAvatarsSuccess:       return "ExploreView_PopularAvatars_Success"
            case .loadPopularAvatarsFail:          return "ExploreView_PopularAvatars_Fail"
            case .avatarPressed:                   return "ExploreView_Avatar_Pressed"
            case .categoryPressed:                 return "ExploreView_Category_Pressed"
            }
        }
        var parameters: [String: Any]? {
            switch self {
            case .loadFeaturedAvatarsFail(error: let error):
                return error.eventParameters
            case .loadFeaturedAvatarsSuccess(avatarCount: let avatarCount), .loadPopularAvatarsSuccess(avatarCount: let avatarCount):
                return [
                    "avatars_count": avatarCount
                ]
            case .avatarPressed(avatar: let avatar):
                return avatar.eventParameters
            case .categoryPressed(category: let category):
                return [
                    "category": category.rawValue
                ]
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadFeaturedAvatarsFail, .loadPopularAvatarsFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
    
    private func onDevSettingsPressed() {
        showDevSettings = true
        logManager.trackEvent(event: Event.devSettingsPressed)
    }

    private var loadingIndicator: some View {
        ProgressView()
            .tint(.accent)
            .padding(40)
            .frame(maxWidth: .infinity)
    }

    private var errorMessageView: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("Error")
                .font(.headline)
            Text("Please check your internet connection and try again")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button("Try again") {
                onTryAgainPressed()
            }
            .foregroundStyle(.blue)
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
        .padding(40)
    }

    private func onTryAgainPressed() {
        isLoadingPopular = true
        isLoadingFeatured = true
        logManager.trackEvent(event: Event.tryAgainPressed)
        Task { await loadFeaturedAvatars() }
        Task { await loadPopularAvatars() }
    }

    private func loadFeaturedAvatars() async {
        // If already loaded, there is no need to fetch again
        guard featuredAvatars.isEmpty else { return }
        logManager.trackEvent(event: Event.loadFeaturedAvatarsStart)

        do {
            featuredAvatars = try await avatarManager.getFeaturedAvatars()
            logManager.trackEvent(event: Event.loadFeaturedAvatarsSuccess(avatarCount: featuredAvatars.count))
        } catch {
            logManager.trackEvent(event: Event.loadFeaturedAvatarsFail(error: error))
        }
    }

    private func loadPopularAvatars() async {
        guard popularAvatars.isEmpty else { return }
        logManager.trackEvent(event: Event.loadPopularAvatarsStart)
        
        do {
            popularAvatars = try await avatarManager.getPopularAvatars()
            logManager.trackEvent(event: Event.loadPopularAvatarsSuccess(avatarCount: popularAvatars.count))
        } catch {
            logManager.trackEvent(event: Event.loadPopularAvatarsFail(error: error))
        }
    }

    private var featuredSection: some View {
        Section {
            ZStack {
                CarouselView(items: featuredAvatars) { avatar in
                    HeroCellView(
                        title: avatar.name,
                        subtitle: avatar.characterDescription,
                        imageName: avatar.profileImageName
                    )
                    .anyButton {
                        onAvatarPressed(avatar: avatar)
                    }
                }
            }
            .removeListRowFormatting()
        } header: {
            Text("Featured")
        }
    }

    private var categorySection: some View {
        Section {
            ZStack {
                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.self) { category in
                            let imageName = popularAvatars.last(where: { $0.characterOption == category })?.profileImageName
                            if let imageName {
                                CategoryCellView(
                                    title: category.plural.capitalized,
                                    imageName: imageName
                                )
                                .anyButton {
                                    onCategoryPressed(category: category, imageName: imageName)
                                }
                            }
                        }
                    }
                }
                .frame(height: 140)
                .scrollIndicators(.hidden)
                .scrollTargetLayout()
                .scrollTargetBehavior(.viewAligned)
            }
            .removeListRowFormatting()
        } header: {
            Text("Categories")
        }
    }

    private var popularSection: some View {
        Section {
            ForEach(popularAvatars, id: \.self) { avatar in
                CustomListCellView(
                    imageName: avatar.profileImageName,
                    title: avatar.name,
                    subtitle: avatar.characterDescription
                )
                .anyButton(.highlight) {
                    onAvatarPressed(avatar: avatar)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Popular")
        }
    }

    private func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
        logManager.trackEvent(event: Event.avatarPressed(avatar: avatar))

    }

    private func onCategoryPressed(category: CharacterOption, imageName: String) {
        path.append(.category(category: category, imageName: imageName))
        logManager.trackEvent(event: Event.categoryPressed(category: category))
    }
}

#Preview("Has data") {
    ExploreView()
        .environment(AvatarManager(remote: MockAvatarService()))
}

#Preview("No data") {
    ExploreView()
        .environment(AvatarManager(remote: MockAvatarService(avatars: [])))
}

#Preview("Slow loading") {
    ExploreView()
        .environment(AvatarManager(remote: MockAvatarService(delay: 10)))
}
