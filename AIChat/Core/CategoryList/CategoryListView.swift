//
//  CategoryListView.swift
//  AIChat
//
//  Created by Michal Fereniec on 20/02/2025.
//

import SwiftUI

@Observable
@MainActor
class CategoryListViewModel {
    let avatarManager: AvatarManager
    let logManager: LogManager
    
    private(set) var avatars: [AvatarModel] = []
    private(set) var isLoading: Bool = true
    
    var showAlert: AnyAppAlert?
    
    init(container: DependencyContainer) {
        self.avatarManager = container.resolve(AvatarManager.self)!
        self.logManager = container.resolve(LogManager.self)!
    }
    
    func loadAvatars(category: CharacterOption) async {
        logManager.trackEvent(event: Event.loadAvatarsStart)
        
        do {
            avatars = try await avatarManager.getAvatarsForCategory(category: category)
            logManager.trackEvent(event: Event.loadAvatarsSuccess)
        } catch {
            showAlert = AnyAppAlert(error: error)
            logManager.trackEvent(event: Event.loadAvatarsFail(error: error))
        }
        isLoading = false
    }

    func onAvatarPressed(avatar: AvatarModel, path: Binding<[NavigationPathOption]>) {
        path.wrappedValue.append(.chat(avatarId: avatar.avatarId, chat: nil))
        logManager.trackEvent(event: Event.avatarPressed(avatar: avatar))
    }
    
    enum Event: LoggableEvent {
        case loadAvatarsStart
        case loadAvatarsSuccess
        case loadAvatarsFail(error: Error)
        case avatarPressed(avatar: AvatarModel)
        
        var eventName: String {
            switch self {
            case .loadAvatarsStart:             return "CategoryList_LoadAvatars_Start"
            case .loadAvatarsSuccess:           return "CategoryList_LoadAvatars_Success"
            case .loadAvatarsFail:              return "CategoryList_LoadAvatars_Fail"
            case .avatarPressed:                return "CategoryList_Avatar_Pressed"
            }
        }
        var parameters: [String: Any]? {
            switch self {
            case .loadAvatarsFail(error: let error):
                return error.eventParameters
            case .avatarPressed(avatar: let avatar):
                return avatar.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            default:
                return .analytic
            }
        }
    }
}

struct CategoryListView: View {

    @State var viewModel: CategoryListViewModel
    
    @Binding var path: [NavigationPathOption]
    var category: CharacterOption = .alien
    var imageName: String = Constants.randomImage

    var body: some View {
        List {
            CategoryCellView(
                title: category.plural.capitalized,
                imageName: imageName,
                font: .largeTitle,
                cornerRadius: 0
            )
            .removeListRowFormatting()

            if viewModel.isLoading {
                ProgressView()
                    .padding(40)
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
                    .removeListRowFormatting()
            } else if viewModel.avatars.isEmpty {
                Text("No avatars found 😢")
                    .frame(maxWidth: .infinity)
                    .padding(40)
                    .foregroundStyle(.secondary)
                    .listRowSeparator(.hidden)
                    .removeListRowFormatting()
            } else {
                ForEach(viewModel.avatars, id: \.self) { avatar in
                    CustomListCellView(
                        imageName: avatar.profileImageName,
                        title: avatar.name,
                        subtitle: avatar.characterDescription
                    )
                    .anyButton(.highlight, action: {
                        viewModel.onAvatarPressed(avatar: avatar, path: $path)
                    })
                    .removeListRowFormatting()
                }
            }
        }
        .showCustomAlert(alert: $viewModel.showAlert)
        .screenAppearAnalytics(name: "CategoryList")
        .ignoresSafeArea()
        .listStyle(PlainListStyle())
        .task {
            await viewModel.loadAvatars(category: category)
        }
    }
}

#Preview("Has data") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(remote: MockAvatarService()))
    
    return CategoryListView(viewModel: CategoryListViewModel(container: container), path: .constant([]))
        .previewEnvironment()
}

#Preview("No data") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(remote: MockAvatarService(avatars: [])))

    return CategoryListView(viewModel: CategoryListViewModel(container: container), path: .constant([]))
        .previewEnvironment()
}

#Preview("Slow loading") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(remote: MockAvatarService(delay: 10)))

    return CategoryListView(viewModel: CategoryListViewModel(container: container), path: .constant([]))
        .previewEnvironment()
}

#Preview("Error loading") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(remote: MockAvatarService(delay: 5, showError: true)))

    return CategoryListView(viewModel: CategoryListViewModel(container: container), path: .constant([]))
        .previewEnvironment()
}
