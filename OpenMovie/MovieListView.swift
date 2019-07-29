//
//  ContentView.swift
//  OpenMovie
//
//  Created by Anthony Soulier on 27/06/2019.
//  Copyright © 2019 Anthony Soulier. All rights reserved.
//

import SwiftUI
import Combine
import CoreData

class MoviesViewModel: BindableObject {

    public let willChange = PassthroughSubject<MoviesViewModel, Never>()

    private let datasource = DataSource<MovieApi, Movie>(sortDescriptor: [
        NSSortDescriptor(key: "releaseDate", ascending: false),
        NSSortDescriptor(key: "title", ascending: true)
    ])

    var movies: [Movie] = [] {
        willSet {
            self.willChange.send(self)
        }
    }

    func load() {
        _ = self.datasource
            .publisher(for: .currentlyInTheater)
            .catch { error in return Just([]) }
            .receive(on: RunLoop.main)
            .sink(receiveValue: { (value: [Movie]) in self.movies = value })
    }
}

struct MovieListView : View {

    @ObjectBinding var viewModel = MoviesViewModel()

    var body: some View {
        NavigationView {

            List(self.viewModel.movies) { item in
                NavigationLink (destination: MovieDetailView(movie: item)) {
                    MovieCell(movie: item)
                }.navigationBarTitle(Text("In Theater"))
            }
        }.onAppear(perform: self.viewModel.load)
    }
}

#if DEBUG
struct MovieListView_Previews : PreviewProvider {
    static var previews: some View {
        MovieListView()
    }
}
#endif

private struct MovieCell: View {

    @ObjectBinding var movie: Movie

    var body: some View {
        HStack(spacing: 16) {

            LoadableImage(imageLoader: ImageLoader(path: movie.posterPath, size: .small))
                .posterStyle()
                .frame(width: 100, height: 150)

            VStack(alignment: .leading, spacing: 4) {

                HStack {
                    Image(systemName: movie.isFavorite ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                        .tapAction { self.movie.isFavorite.toggle() }

                    Text(movie.title ?? "")
                        .foregroundColor(.yellow)
                        .font(.headline)
                }

                HStack {
                    CircleView(value: Int(movie.voteAverage * 10))
                        .frame(width: 25, height: 25)

                    Text(movie.releaseDate?.shortDate ?? "")
                }

                Text(movie.overview ?? "")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(0)

                Spacer()
            }
        }
        .padding(8)
    }
}
