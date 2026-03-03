//
//  ExploreView.swift
//  AIChat
//
//  Created by Michal Fereniec on 13/01/2025.
//

import SwiftUI

@Observable
@MainActor
class ExploreViewModel {
    let authManager: AuthManager
    let avatarManager: AvatarManager
    let logManager: LogManager
    let abTestManager: ABTestManager
    let pushManager: PushManager
    
    private(set) var featuredAvatars: [AvatarModel] = []
    private(set) var popularAvatars: [AvatarModel] = []
    private(set) var isLoadingFeatured: Bool = true
    private(set) var isLoadingPopular: Bool = true
    private(set) var categories: [CharacterOption] = CharacterOption.allCases
    private(set) var showNotificationButton: Bool = false
    
    var showPushNotificationModal: Bool = false
    var showCreateAccountView: Bool = false
    var showDevSettings: Bool = false
    var path: [NavigationPathOption] = []
    
    var showDevSettingsButton: Bool {
        #if DEV || MOCK
        return true
        #else
        return false
        #endif
    }

    var categoryRowTest: CategoryRowTestOption {
        abTestManager.activeTests.categoryRowTest
    }
    
    init(container: DependencyContainer) {
        self.authManager = container.resolve(AuthManager.self)!
        self.avatarManager = container.resolve(AvatarManager.self)!
        self.logManager = container.resolve(LogManager.self)!
        self.pushManager = container.resolve(PushManager.self)!
        self.abTestManager = container.resolve(ABTestManager.self)!
    }
    
    func handleDeepLink(url: URL) {
        logManager.trackEvent(event: Event.deeplinkStart)
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems else {
            logManager.trackEvent(event: Event.deeplinkNoQueryItems)
            return
        }
        
        for queryItem in queryItems {
            if queryItem.name == "category", let value = queryItem.value, let category = CharacterOption(rawValue: value) {
                let imageName = popularAvatars.first(where: { $0.characterOption == category })?.profileImageName ?? Constants.randomImage
                path.append(.category(category: category, imageName: imageName))
                logManager.trackEvent(event: Event.deeplinkCategory(category: category))
                return
            }
        }
        
        logManager.trackEvent(event: Event.deeplinkUnknown)
    }
    
    func schedulePushNotifications() {
        pushManager.schedulePushNotificationsForTheNextWeek()
    }
    
    func handleShowPushNotificationButton() async {
        showNotificationButton = await pushManager.canRequestAuthorization()
    }
    
    func showCreateAccountViewIfNeeded() {
        Task {
            try? await Task.sleep(for: .seconds(2))
            
            // If the user doesn't already have an account
            // If the user is in our AB test
            guard
                authManager.auth?.isAnonymous == true &&
                    abTestManager.activeTests.createAccountTest == true
            else {
                return
            }
            
            showCreateAccountView = true
        }
    }
    
    func onPushNotificationButtonPressed() {
        showPushNotificationModal = true
        logManager.trackEvent(event: Event.pushNotifsStart)
    }
    
    func onEnablePushNotificationsPressed() {
        showPushNotificationModal = false

        Task {
            let isAuthorized = try await pushManager.requestAuthorization()
            logManager.trackEvent(event: Event.pushNotifsEnable(isAuthorized: isAuthorized))
            await handleShowPushNotificationButton()
        }
    }
    
    func onCancelPushNotificationsPressed() {
        showPushNotificationModal = false
        logManager.trackEvent(event: Event.pushNotifsCancel)
    }
    
    func onDevSettingsPressed() {
        showDevSettings = true
        logManager.trackEvent(event: Event.devSettingsPressed)
    }
    
    func onTryAgainPressed() {
        isLoadingFeatured = true
        isLoadingPopular = true
        logManager.trackEvent(event: Event.tryAgainPressed)

        Task {
            await loadFeaturedAvatars()
        }
        Task {
            await loadPopularAvatars()
        }
    }
    
    func loadFeaturedAvatars() async {
        // If already loaded, no need to fetch again
        guard featuredAvatars.isEmpty else { return }
        logManager.trackEvent(event: Event.loadFeaturedAvatarsStart)

        do {
            featuredAvatars = try await avatarManager.getFeaturedAvatars()
            logManager.trackEvent(event: Event.loadFeaturedAvatarsSuccess(count: featuredAvatars.count))
        } catch {
            logManager.trackEvent(event: Event.loadFeaturedAvatarsFail(error: error))
        }
        
        isLoadingFeatured = false
    }
    
    func loadPopularAvatars() async {
        guard popularAvatars.isEmpty else { return }
        logManager.trackEvent(event: Event.loadPopularAvatarsStart)

        do {
            popularAvatars = try await avatarManager.getPopularAvatars()
            logManager.trackEvent(event: Event.loadPopularAvatarsSuccess(count: popularAvatars.count))
        } catch {
            logManager.trackEvent(event: Event.loadPopularAvatarsFail(error: error))
        }
        
        isLoadingPopular = false
    }
    
    func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
        logManager.trackEvent(event: Event.avatarPressed(avatar: avatar))
    }

    func onCategoryPressed(category: CharacterOption, imageName: String) {
        path.append(.category(category: category, imageName: imageName))
        logManager.trackEvent(event: Event.categoryPressed(category: category))
    }
    
    enum Event: LoggableEvent {
        case devSettingsPressed
        case tryAgainPressed
        case loadFeaturedAvatarsStart
        case loadFeaturedAvatarsSuccess(count: Int)
        case loadFeaturedAvatarsFail(error: Error)
        case loadPopularAvatarsStart
        case loadPopularAvatarsSuccess(count: Int)
        case loadPopularAvatarsFail(error: Error)
        case avatarPressed(avatar: AvatarModel)
        case categoryPressed(category: CharacterOption)
        case pushNotifsStart
        case pushNotifsEnable(isAuthorized: Bool)
        case pushNotifsCancel
        case deeplinkStart
        case deeplinkNoQueryItems
        case deeplinkCategory(category: CharacterOption)
        case deeplinkUnknown

        var eventName: String {
            switch self {
            case .devSettingsPressed:           return "ExploreView_DevSettings_Pressed"
            case .tryAgainPressed:              return "ExploreView_TryAgain_Pressed"
            case .loadFeaturedAvatarsStart:     return "ExploreView_LoadFeaturedAvatars_Start"
            case .loadFeaturedAvatarsSuccess:   return "ExploreView_LoadFeaturedAvatars_Success"
            case .loadFeaturedAvatarsFail:      return "ExploreView_LoadFeaturedAvatars_Fail"
            case .loadPopularAvatarsStart:      return "ExploreView_LoadPopularAvatars_Start"
            case .loadPopularAvatarsSuccess:    return "ExploreView_LoadPopularAvatars_Success"
            case .loadPopularAvatarsFail:       return "ExploreView_LoadPopularAvatars_Fail"
            case .avatarPressed:                return "ExploreView_Avatar_Pressed"
            case .categoryPressed:              return "ExploreView_Category_Pressed"
            case .pushNotifsStart:              return "ExploreView_PushNotifs_Start"
            case .pushNotifsEnable:             return "ExploreView_PushNotifs_Enable"
            case .pushNotifsCancel:             return "ExploreView_PushNotifs_Cancel"
            case .deeplinkStart:                return "ExploreView_DeepLink_Start"
            case .deeplinkNoQueryItems:         return "ExploreView_DeepLink_NoItems"
            case .deeplinkCategory:             return "ExploreView_DeepLink_Category"
            case .deeplinkUnknown:              return "ExploreView_DeepLink_Unknown"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loadPopularAvatarsSuccess(count: let count), .loadFeaturedAvatarsSuccess(count: let count):
                return [
                    "avatars_count": count
                ]
            case .loadPopularAvatarsFail(error: let error), .loadFeaturedAvatarsFail(error: let error):
                return error.eventParameters
            case .avatarPressed(avatar: let avatar):
                return avatar.eventParameters
            case .categoryPressed(category: let category), .deeplinkCategory(category: let category):
                return [
                    "category": category.rawValue
                ]
            case .pushNotifsEnable(isAuthorized: let isAuthorized):
                return [
                    "is_authorized": isAuthorized
                ]
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadPopularAvatarsFail, .loadFeaturedAvatarsFail, .deeplinkUnknown:
                return .severe
            default:
                return .analytic
            }
        }
    }
}

struct ExploreView: View {
    
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: ExploreViewModel

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            List {
                if viewModel.featuredAvatars.isEmpty && viewModel.popularAvatars.isEmpty {
                    ZStack {
                        if viewModel.isLoadingFeatured || viewModel.isLoadingPopular {
                            loadingIndicator
                        } else {
                            errorMessageView
                        }
                    }
                    .removeListRowFormatting()
                }
                
                if !viewModel.popularAvatars.isEmpty {
                    if viewModel.categoryRowTest == .top {
                        categorySection
                    }
                }
                
                if !viewModel.featuredAvatars.isEmpty {
                    featuredSection
                }
                
                if !viewModel.popularAvatars.isEmpty {
                    if viewModel.categoryRowTest == .original {
                        categorySection
                    }
                    popularSection
                }
            }
            .navigationTitle("Explore")
            .screenAppearAnalytics(name: "ExploreView")
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.showDevSettingsButton {
                        devSettingsButton
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.showNotificationButton {
                        pushNotificationButton
                    }
                }
            })
            .sheet(isPresented: $viewModel.showDevSettings, content: {
                DevSettingsView()
            })
            .sheet(isPresented: $viewModel.showCreateAccountView, content: {
                CreateAccountView()
                    .presentationDetents([.medium])
            })
            .navigationDestinationForCoreModule(path: $viewModel.path)
            .showModal(showModal: $viewModel.showPushNotificationModal, content: {
                pushNotificationModal
            })
            .task {
                await viewModel.loadFeaturedAvatars()
            }
            .task {
                await viewModel.loadPopularAvatars()
            }
            .task {
                await viewModel.handleShowPushNotificationButton()
            }
            .onFirstAppear {
                viewModel.schedulePushNotifications()
                viewModel.showCreateAccountViewIfNeeded()
            }
            .onOpenURL { url in
                viewModel.handleDeepLink(url: url)
            }
        }
    }
    
    var loadingIndicator: some View {
        ProgressView()
            .tint(.accent)
            .padding(40)
            .frame(maxWidth: .infinity)
    }
    
    private var pushNotificationButton: some View {
        Image(systemName: "bell.fill")
            .font(.headline)
            .padding(4)
            .tappableBackground()
            .foregroundStyle(.accent)
            .anyButton {
                viewModel.onPushNotificationButtonPressed()
            }
    }
    
    private var featuredSection: some View {
        Section {
            ZStack {
                CarouselView(items: viewModel.featuredAvatars) { avatar in
                    HeroCellView(
                        title: avatar.name,
                        subtitle: avatar.characterDescription,
                        imageName: avatar.profileImageName
                    )
                    .anyButton {
                        viewModel.onAvatarPressed(avatar: avatar)
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
                        ForEach(viewModel.categories, id: \.self) { category in
                            let imageName = viewModel.popularAvatars.last(where: { $0.characterOption == category })?.profileImageName
                            if let imageName {
                                CategoryCellView(
                                    title: category.plural.capitalized,
                                    imageName: imageName
                                )
                                .anyButton {
                                    viewModel.onCategoryPressed(category: category, imageName: imageName)
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
            ForEach(viewModel.popularAvatars, id: \.self) { avatar in
                CustomListCellView(
                    imageName: avatar.profileImageName,
                    title: avatar.name,
                    subtitle: avatar.characterDescription
                )
                .anyButton(.highlight) {
                    viewModel.onAvatarPressed(avatar: avatar)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Popular")
        }
    }
    
    private var pushNotificationModal: some View {
        CustomModalView(
            title: "Enable push notifications?",
            subtitle: "We'll send you reminders and updates!",
            primaryButtonTitle: "Enable",
            primaryButtonAction: {
                viewModel.onEnablePushNotificationsPressed()
            },
            secondaryButtonTitle: "Cancel",
            secondaryButtonAction: {
                viewModel.onCancelPushNotificationsPressed()
            }
        )
    }
    
    private var devSettingsButton: some View {
        Text("DEV 🤫")
            .badgeButton()
            .anyButton(.press) {
                viewModel.onDevSettingsPressed()
            }
    }
    
    private var errorMessageView: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("Error")
                .font(.headline)
            Text("Please check your internet connection and try again.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("Try again") {
                viewModel.onTryAgainPressed()
            }
            .foregroundStyle(.blue)
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
        .padding(40)
    }
}

#Preview("Has data") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(remote: MockAvatarService()))
    
    return ExploreView(viewModel: ExploreViewModel(container: container))
        .previewEnvironment()
 }
 #Preview("Has data w/ Create Account AB test") {
     let container = DevPreview.shared.container
     container.register(AvatarManager.self, service: AvatarManager(remote: MockAvatarService()))
     container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: .mock(isAnonymous: true))))
     container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(createAccountTest: true)))

     return ExploreView(viewModel: ExploreViewModel(container: container))
         .previewEnvironment()
 }
 #Preview("CategoryRowTest: original") {
     let container = DevPreview.shared.container
     container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(categoryRowTest: .original)))

    return ExploreView(viewModel: ExploreViewModel(container: container))
        .previewEnvironment()
 }
 #Preview("CategoryRowTest: top") {
     let container = DevPreview.shared.container
     container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(categoryRowTest: .top)))

     return ExploreView(viewModel: ExploreViewModel(container: container))
        .previewEnvironment()
 }
 #Preview("CategoryRowTest: hidden") {
     let container = DevPreview.shared.container
     container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(categoryRowTest: .hidden)))

     return ExploreView(viewModel: ExploreViewModel(container: container))
        .previewEnvironment()
 }
 #Preview("No data") {
     let container = DevPreview.shared.container
     container.register(AvatarManager.self, service: AvatarManager(remote: MockAvatarService(avatars: [], delay: 2.0)))

     return ExploreView(viewModel: ExploreViewModel(container: container))
        .previewEnvironment()
 }
 #Preview("Slow loading") {
     let container = DevPreview.shared.container
     container.register(AvatarManager.self, service: AvatarManager(remote: MockAvatarService(delay: 10)))

     return ExploreView(viewModel: ExploreViewModel(container: container))
        .previewEnvironment()
 }
