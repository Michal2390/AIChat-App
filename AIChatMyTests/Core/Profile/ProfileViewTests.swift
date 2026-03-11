//
//  ProfileViewTests.swift
//  AIChatMyTests
//
//  Created by Michal Fereniec on 04/03/2026.
//

 import Testing
 import SwiftUI
 @testable import AIChat

 @MainActor
 struct ProfileViewTests {
     
     @MainActor
     struct MockProfileInteractor: ProfileInteractor {
         var logger = MockLogService()
         var user: UserModel = UserModel.mock
         var avatars: [AvatarModel] = AvatarModel.mocks
            
         var currentUser: AIChat.UserModel? {
             user
         }
         
         func getAuthId() throws -> String {
             "userId"
         }
         
         func getAvatarsForAuthor(userId: String) async throws -> [AIChat.AvatarModel] {
             avatars
         }
         
         func removeAuthorIdFromAvatar(avatarId: String) async throws {
             
         }
         
         func trackEvent(event: any AIChat.LoggableEvent) {
             logger.trackEvent(event: event)
         }
         
     }
     
     @MainActor
     struct AnyProfileInteractor: ProfileInteractor {
         let anyCurrentUser: UserModel?
         let anyGetAuthID: () throws -> String
         let anyGetAvatarsForAuthor: (String) async throws -> [AvatarModel]
         let anyRemoveAuthorIdFromAvatar: (String) async throws -> Void
         let anyTrackEvent: (LoggableEvent) -> Void
  
         init(
            currentUser: UserModel?,
            getAuthID: @escaping () throws -> String,
            getAvatarsForAuthor: @escaping (String) async throws -> [AvatarModel],
            removeAuthorIdFromAvatar: @escaping (String) async throws -> Void,
            trackEvent: @escaping (LoggableEvent) -> Void
         ) {
             self.anyCurrentUser = currentUser
             self.anyGetAuthID = getAuthID
             self.anyGetAvatarsForAuthor = getAvatarsForAuthor
             self.anyRemoveAuthorIdFromAvatar = removeAuthorIdFromAvatar
             self.anyTrackEvent = trackEvent
         }
        
         init(interactor: ProfileInteractor) {
             self.anyCurrentUser = interactor.currentUser
             self.anyGetAuthID = interactor.getAuthId
             self.anyGetAvatarsForAuthor = interactor.getAvatarsForAuthor
             self.anyRemoveAuthorIdFromAvatar = interactor.removeAuthorIdFromAvatar
             self.anyTrackEvent = interactor.trackEvent
         }
         
         init(interactor: MockProfileInteractor) {
             self.anyCurrentUser = interactor.currentUser
             self.anyGetAuthID = interactor.getAuthId
             self.anyGetAvatarsForAuthor = interactor.getAvatarsForAuthor
             self.anyRemoveAuthorIdFromAvatar = interactor.removeAuthorIdFromAvatar
             self.anyTrackEvent = interactor.trackEvent
         }
         
         init(interactor: ProdProfileInteractor) {
             self.anyCurrentUser = interactor.currentUser
             self.anyGetAuthID = interactor.getAuthId
             self.anyGetAvatarsForAuthor = interactor.getAvatarsForAuthor
             self.anyRemoveAuthorIdFromAvatar = interactor.removeAuthorIdFromAvatar
             self.anyTrackEvent = interactor.trackEvent
         }
         
         var currentUser: AIChat.UserModel? {
             anyCurrentUser
         }
         
         func getAuthId() throws -> String {
             try anyGetAuthID()
         }
         
         func getAvatarsForAuthor(userId: String) async throws -> [AIChat.AvatarModel] {
             try await anyGetAvatarsForAuthor(userId)
         }
         
         func removeAuthorIdFromAvatar(avatarId: String) async throws {
             try await anyRemoveAuthorIdFromAvatar(avatarId)
         }
         
         func trackEvent(event: any AIChat.LoggableEvent) {
             anyTrackEvent(event)
         }
     }

    @Test("loadData does set current user")
    func testLoadDataDoesSetCurrentUser() async throws {
        // Given
        let interactor = MockProfileInteractor()
        let viewModel = ProfileViewModel(interactor: interactor)
        
        // When
        await viewModel.loadData()
        
        // Then
        #expect(viewModel.currentUser?.userId == interactor.user.userId)
        #expect(interactor.logger.trackedEvents.contains { $0.eventName == ProfileViewModel.Event.loadAvatarsStart.eventName })
    }
    
    @Test("loadData does succeed and user avatars are set")
    func testLoadDataDoesSucceedAndAvatarsAreSet() async throws {
        // Given
        var events: [LoggableEvent] = []
        let avatars = AvatarModel.mocks
        let user = UserModel.mock
        
        let interactor = AnyProfileInteractor(
            currentUser: user,
            getAuthID: {
                user.userId
            },
            getAvatarsForAuthor: { _ in
                avatars
            },
            removeAuthorIdFromAvatar: { _ in },
            trackEvent: { event in
                events.append(event)
            }
        )
        let viewModel = ProfileViewModel(interactor: interactor)
        
        // When
        await viewModel.loadData()
        
        // Then
        #expect(viewModel.myAvatars.count == avatars.count)
        #expect(viewModel.isLoading == false)
        #expect(events.contains { $0.eventName == ProfileViewModel.Event.loadAvatarsSuccess(count: 0).eventName })
    }
    
    @Test("loadData does fail")
    func testLoadDataDoesFail() async throws {
        let container = DependencyContainer()
        let authManager = AuthManager(service: MockAuthService(user: nil))
        let mockUser = UserModel.mock
        let userManager = UserManager(services: MockUserServices(user: mockUser))
        let avatars = AvatarModel.mocks
        let avatarManager = AvatarManager(remote: MockAvatarService(avatars: avatars))
        let mockLogService = MockLogService()
        let logManager = LogManager(services: [mockLogService])
        
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(AvatarManager.self, service: avatarManager)
        container.register(LogManager.self, service: logManager)
        
        // Given
        let viewModel = ProfileViewModel(interactor: ProdProfileInteractor(container: container))
        // When
        await viewModel.loadData()
        
        // Then
        #expect(viewModel.isLoading == false)
        #expect(mockLogService.trackedEvents.contains { $0.eventName == ProfileViewModel.Event.loadAvatarsFail(error: URLError(.badURL)).eventName })
    }
    
    @Test("onSettingsButtonPressed")
    func testOnSettingsButtonPressed() async throws {
        let container = DependencyContainer()
        let authUser = UserAuthInfo.mock()
        let authManager = AuthManager(service: MockAuthService(user: authUser))
        let userManager = UserManager(services: MockUserServices())
        let avatarManager = AvatarManager(remote: MockAvatarService())
        let mockLogService = MockLogService()
        let logManager = LogManager(services: [mockLogService])
        
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(AvatarManager.self, service: avatarManager)
        container.register(LogManager.self, service: logManager)
        
        // Given
        let viewModel = ProfileViewModel(interactor: ProdProfileInteractor(container: container))
        
        // When
        viewModel.onSettingsButtonPressed()
        
        // Then
        #expect(viewModel.showSettingsView == true)
        #expect(mockLogService.trackedEvents.contains { $0.eventName == ProfileViewModel.Event.settingsPressed.eventName })
    }
    
    @Test("onNewAvatarButtonPressed")
    func testOnNewAvatarButtonPressed() async throws {
        let container = DependencyContainer()
        let authUser = UserAuthInfo.mock()
        let authManager = AuthManager(service: MockAuthService(user: authUser))
        let userManager = UserManager(services: MockUserServices())
        let avatarManager = AvatarManager(remote: MockAvatarService())
        let mockLogService = MockLogService()
        let logManager = LogManager(services: [mockLogService])
        
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(AvatarManager.self, service: avatarManager)
        container.register(LogManager.self, service: logManager)
        
        // Given
        let viewModel = ProfileViewModel(interactor: ProdProfileInteractor(container: container))
        
        // When
        viewModel.onNewAvatarButtonPressed()
        
        // Then
        #expect(viewModel.showCreateAvatarView == true)
        #expect(mockLogService.trackedEvents.contains { $0.eventName == ProfileViewModel.Event.newAvatarPressed.eventName })
    }
    
    @Test("onAvatarPressed")
    func testOnAvatarButtonPressed() async throws {
        let container = DependencyContainer()
        let authUser = UserAuthInfo.mock()
        let authManager = AuthManager(service: MockAuthService(user: authUser))
        let userManager = UserManager(services: MockUserServices())
        let avatarManager = AvatarManager(remote: MockAvatarService())
        let mockLogService = MockLogService()
        let logManager = LogManager(services: [mockLogService])
        
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(AvatarManager.self, service: avatarManager)
        container.register(LogManager.self, service: logManager)
        
        // Given
        let viewModel = ProfileViewModel(interactor: ProdProfileInteractor(container: container))
        
        // When
        let avatar = AvatarModel.mock
        viewModel.onAvatarPressed(avatar: avatar)
        
        // Then
        #expect(viewModel.path.first == .chat(avatarId: avatar.id, chat: nil))
        #expect(mockLogService.trackedEvents.contains { $0.eventName == ProfileViewModel.Event.avatarPressed(avatar: avatar).eventName })
    }
    
    @Test("onDeleteAvatar does succeed")
    func testOnDeleteAvatarSuccess() async throws {
        let container = DependencyContainer()
        let authUser = UserAuthInfo.mock()
        let authManager = AuthManager(service: MockAuthService(user: authUser))
        let userManager = UserManager(services: MockUserServices())
        let avatars = AvatarModel.mocks
        let avatarManager = AvatarManager(remote: MockAvatarService(avatars: avatars))
        let mockLogService = MockLogService()
        let logManager = LogManager(services: [mockLogService])
        
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(AvatarManager.self, service: avatarManager)
        container.register(LogManager.self, service: logManager)
        
        // Given
        let viewModel = ProfileViewModel(interactor: ProdProfileInteractor(container: container))
        
        // When
        await viewModel.loadData()
        viewModel.onDeleteAvatar(indexSet: IndexSet(integer: 0))
        try await Task.sleep(for: .milliseconds(100))
        
        // Then
        #expect(viewModel.myAvatars.count == (avatars.count - 1))
        #expect(mockLogService.trackedEvents.contains { $0.eventName == ProfileViewModel.Event.deleteAvatarSuccess(avatar: avatars[0]).eventName })
    }
    
    @Test("onDeleteAvatar does fail")
    func testOnDeleteAvatarFailure() async throws {
        let container = DependencyContainer()
        let authUser = UserAuthInfo.mock()
        let authManager = AuthManager(service: MockAuthService(user: authUser))
        let userManager = UserManager(services: MockUserServices())
        let avatars = AvatarModel.mocks
        let avatarManager = AvatarManager(remote: MockAvatarService(avatars: avatars, showErrorForRemoveAuthorIdFromAvatar: true))
        let mockLogService = MockLogService()
        let logManager = LogManager(services: [mockLogService])
        
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(AvatarManager.self, service: avatarManager)
        container.register(LogManager.self, service: logManager)
        
        // Given
        let viewModel = ProfileViewModel(interactor: ProdProfileInteractor(container: container))
        
        // When
        await viewModel.loadData()
        viewModel.onDeleteAvatar(indexSet: IndexSet(integer: 0))
        try await Task.sleep(for: .milliseconds(100))
        
        // Then
        #expect(viewModel.myAvatars.count == avatars.count)
        #expect(mockLogService.trackedEvents.contains { $0.eventName == ProfileViewModel.Event.deleteAvatarFail(error: URLError(.badURL)).eventName })
    }

 }
