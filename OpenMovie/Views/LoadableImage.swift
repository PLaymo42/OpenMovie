//
//  LoadableImage.swift
//  OpenMovie
//
//  Created by Anthony Soulier on 02/07/2019.
//  Copyright © 2019 Anthony Soulier. All rights reserved.
//

import SwiftUI

struct LoadableImage: View {

    @ObservedObject var imageLoader: ImageLoader

    var body: some View {
        ZStack {
            self.imageLoader.image
                .map {
                    ViewBuilder.buildEither(first: self.imageView(uiImage: $0))

                } ??
                ViewBuilder.buildEither(second: self.loadingView)
        }.onAppear(perform: {
            self.imageLoader.loadImage()
        })
    }

    private func imageView(uiImage: UIImage) -> some View {
        return Image(uiImage: uiImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .animation(.easeInOut)
    }

    private var loadingView: some View {
        return ZStack {
            Rectangle()
                .foregroundColor(.gray)
                .opacity(0.1)

            ActivityIndicator(isAnimating: $imageLoader.isLoading, style: .large)
        }
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
        return ModifiedContent(
            content: self,
            modifier: PosterStyle()
        )
    }
}

protocol Poster: View {}
extension LoadableImage: Poster {}
