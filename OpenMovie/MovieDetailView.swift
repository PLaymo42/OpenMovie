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

    @ObjectBinding var movie: Movie

    private let backdropsWidth: CGFloat = UIScreen.main.bounds.width * 2/3

    var body: some View {
        NavigationView {
            List {
                LoadableImage(imageLoader: ImageLoader(path: movie.backdropPath))
                    .listRowInsets(EdgeInsets())

                Image(systemName: self.movie.isFavorite ? "star.fill" : "star")
                    .foregroundColor(.yellow)
                    .tapAction { self.movie.isFavorite.toggle() }

                Text(self.movie.title ?? "")

                self.movie.detail.map {
                    ViewBuilder.buildEither(first:
                        Text("budget \($0.budget)")
                    )
                    } ?? ViewBuilder.buildEither(second:
                        Text("budget unknown")
                )

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(((movie.images?.posters?.allObjects as? [ImageInfo]) ?? []).identified(by: \.id)) { info in
                            LoadableImage(imageLoader: ImageLoader(path: info.filePath))
                                .posterStyle()
                                .frame(width: 100, height: 100 / CGFloat(info.aspectRatio))
                        }
                    }
                    .padding()
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(((movie.images?.backdrops?.allObjects as? [ImageInfo]) ?? []).identified(by: \.id)) { info in
                            LoadableImage(imageLoader: ImageLoader(path: info.filePath))
                                .posterStyle()
                                .frame(width: self.backdropsWidth, height: self.backdropsWidth / CGFloat(info.aspectRatio))
                        }
                    }
                    .padding()
                }
            }
            .edgesIgnoringSafeArea(.top)
        }
        .onAppear(perform: self.load)

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
            .sink(receiveValue: { _ in })
    }

    private func loadImages() {
        let id = Int(self.movie.id)

        _ = self.movieImageDatasource
            .publisher(for: .images(id))
            .receive(on: RunLoop.main)
            .catch { error in
                return Just(nil)
            }
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
