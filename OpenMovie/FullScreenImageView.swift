//
//  FullScreenImageView.swift
//  OpenMovie
//
//  Created by Anthony Soulier on 15/07/2019.
//  Copyright © 2019 Anthony Soulier. All rights reserved.
//

import SwiftUI

struct FullScreenImageView : View {

    var imageInfo: ImageInfo

    var body: some View {
        VStack {
            LoadableImage(imageLoader: ImageLoader(path: self.imageInfo.filePath, size: .medium))

            Text(self.imageInfo.filePath ?? "No file path available")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

//#if DEBUG
//struct FullScreenImageView_Previews : PreviewProvider {
//    static var previews: some View {
//        FullScreenImageView(imageInfo: )
//    }
//}
//#endif
