//
//  CustomListCellView.swift
//  AIChat
//
//  Created by Michal Fereniec on 25/01/2025.
//

import SwiftUI

struct CustomListCellView: View {

    let imageName: String = Constants.randomImage
    var title: String? = "Alpha"
    var subtitle: String? = "An alien that is smiling in the park"
    let items: [AvatarModel] = AvatarModel.mocks
    
    var body: some View {
        HStack(spacing: 8) {
            ImageLoaderView(urlString: imageName)
                .aspectRatio(1, contentMode: .fit)
                .frame(height: 60)
                .cornerRadius(16)
            
            VStack(alignment: .leading, spacing: 4) {
                if let title {
                    Text(title)
                        .font(.headline)
                }
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .padding(.vertical, 4)
        .background(Color(uiColor: .systemBackground))
    }
}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea(edges: .all)
        CustomListCellView()
    }
}
