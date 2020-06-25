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

class MoviesViewModel: ObservableObject {


    private var cancellable = Set<AnyCancellable>()

    private let datasource = DataSource<MovieApi, Movie>(sortDescriptor: [
        NSSortDescriptor(key: "releaseDate", ascending: false),
        NSSortDescriptor(key: "title", ascending: true)
    ])

    @Published var movies: [Movie] = []

    func load() {
        self.datasource
            .publisher(for: .currentlyInTheater)
            .catch { error in return Just([]) }
            .receive(on: RunLoop.main)
            .sink(receiveValue: { self.movies = $0 })
            .store(in: &cancellable)
    }
}

struct MovieListView : View {

    @ObservedObject var viewModel = MoviesViewModel()

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

    @ObservedObject var movie: Movie

    var body: some View {
        HStack(spacing: 16) {

            LoadableImage(imageLoader: ImageLoader(path: movie.posterPath, size: .small))
                .posterStyle()
                .frame(width: 100, height: 150)

            VStack(alignment: .leading, spacing: 4) {

                HStack {
                    Image(systemName: movie.isFavorite ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                        .onTapGesture { self.movie.isFavorite.toggle() }

                    Text(movie.title ?? "")
                        .lineLimit(2)

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
                    .lineLimit(6)

                Spacer()
            }
        }
        .padding(8)
    }
}
