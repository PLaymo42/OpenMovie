//
//  MovieDetailView.swift
//  OpenMovie
//
//  Created by Anthony Soulier on 13/07/2019.
//  Copyright © 2019 Anthony Soulier. All rights reserved.
//

import SwiftUI
import Combine
import CoreData

struct MovieDetailView : View {

    private let datasource = SingleResultDataSource<MovieApi, MovieDetail>()

    private let movieImageDatasource = SingleResultDataSource<MovieApi, MovieImage>()

    @ObservedObject var movie: Movie

    @State private var modalImagePath: ImageInfo? = nil

    var body: some View {
        NavigationView {
            List {
                LoadableImage(imageLoader: ImageLoader(path: movie.backdropPath))
                    .frame(width: UIScreen.main.bounds.width)
                    .listRowInsets(EdgeInsets())

                HStack {
                    Image(systemName: self.movie.isFavorite ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                        .onTapGesture { self.movie.isFavorite.toggle() }

                    Text(self.movie.title ?? "")
                }

                self.movie.detail.map {
                    ViewBuilder.buildEither(first:
                        Text("budget \($0.budget)")
                    )
                    } ?? ViewBuilder.buildEither(second:
                        Text("budget unknown")
                )
                
                LoadableCarousselView(
                    imageInfos: self.posterPath,
                    imageWidth: 100,
                    imageTapAction: { self.modalImagePath = $0 }
                )
                
                LoadableCarousselView(
                    imageInfos: self.backdropsPath,
                    imageWidth: UIScreen.main.bounds.width * 2/3,
                    imageTapAction: { self.modalImagePath = $0 }
                )
            }
            //            .edgesIgnoringSafeArea(.top)
        }
        .onAppear(perform: self.load)
        .sheet(item: $modalImagePath) { info in
            return FullScreenImageView(imageInfo: info)
        }
    }


    var backdropsPath: [ImageInfo] {
        return (self.movie.images?.backdrops?.allObjects as? [ImageInfo] ?? [])
    }

    var posterPath: [ImageInfo] {
        return (self.movie.images?.posters?.allObjects as? [ImageInfo] ?? [])
    }

    func load() {
        self.loadDetail()
        self.loadImages()
    }

    private func loadDetail() {
        guard self.movie.detail == nil else { return }

        let id = Int(self.movie.id)

        _ = self.datasource
            .publisher(for: .detail(id))
            .receive(on: RunLoop.main)
            .catch { _ in Just(nil) }
            .sink(receiveValue: { _ in  })
    }

    private func loadImages() {
        guard self.movie.images == nil else { return }

        let id = Int(self.movie.id)

        _ = self.movieImageDatasource
            .publisher(for: .images(id))
            .receive(on: RunLoop.main)
            .catch { _ in Just(nil) }
            .sink(receiveValue: { _ in })
    }
}

//#if DEBUG
//struct MovieDetailView_Previews : PreviewProvider {
//    static var previews: some View {
//        MovieDetailView(movie: <#Movie#>)
//    }
//}
//#endif

struct LoadableCarousselView : View {

    let imageInfos: [ImageInfo]
    let imageWidth: CGFloat
    let imageTapAction: ((ImageInfo) -> Void)

    var body: some View {
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(self.imageInfos, id: \.id) { info in
                    LoadableImage(imageLoader: ImageLoader(path: info.filePath))
                        .posterStyle()
                        .frame(width: self.imageWidth, height: self.imageHeight)
                        .onTapGesture { self.imageTapAction(info) }
                }
            }
            .padding()
        }
    }
    
    private var imageHeight: CGFloat {
        return imageInfos.map { self.imageWidth * $0.ratio }.min() ?? 0
    }
}
