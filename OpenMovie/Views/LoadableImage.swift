//
//  LoadableImage.swift
//  OpenMovie
//
//  Created by Anthony Soulier on 02/07/2019.
//  Copyright © 2019 Anthony Soulier. All rights reserved.
//

import SwiftUI

struct LoadableImage: View {
    @State var imageLoader: ImageLoader

    var body: some View {
        ZStack {
            self.imageLoader.image.map {
                ViewBuilder.buildEither(first:
                    Image(uiImage: $0)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .animation(.basic())
                )
                } ?? ViewBuilder.buildEither(second:
                    Rectangle()
                        .foregroundColor(.gray)
                        .opacity(0.1)
            )
        }.onAppear(perform: self.imageLoader.loadImage)
    }
}


struct PosterStyle: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .cornerRadius(5)
            .shadow(radius: 8)
    }
}

extension Poster {
    func posterStyle() -> some View {
        return Modified(
            content: self,
            modifier: PosterStyle()
        )
    }
}

protocol Poster: View {}
extension LoadableImage: Poster {}
