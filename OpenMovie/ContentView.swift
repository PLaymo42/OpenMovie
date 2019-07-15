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

    public let didChange = PassthroughSubject<MoviesViewModel, Never>()

    private let datasource = DataSource<MovieApi, Movie>(sortDescriptor: [
        NSSortDescriptor(key: "releaseDate", ascending: false),
        NSSortDescriptor(key: "title", ascending: true)
    ])

    var movies: [Movie] = [] {
        didSet {
            didChange.send(self)
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

struct ContentView : View {

    @State var viewModel = MoviesViewModel()

    var body: some View {
        NavigationView {

            List(self.viewModel.movies) { item in
                NavigationLink(destination: MovieDetailView(movie: item)) {

                    HStack(spacing: 16) {
                        LoadableImage(imageLoader: ImageLoader(path: item.posterPath))
                            .posterStyle()
                            .frame(width: 100, height: 150)

                        VStack(alignment: .leading, spacing: 4) {

                            HStack {
                                Image(systemName: item.isFavorite ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                                    .tapAction { item.isFavorite.toggle() }

                                Text(item.title ?? "")
                                    .color(.yellow)
                                    .font(.headline)
                            }

                            HStack {
                                CircleView(value: Int(item.voteAverage * 10))
                                    .frame(width: 25, height: 25)

                                Text(item.releaseDate?.shortDate ?? "")
                            }

                            Text(item.overview ?? "")
                                .font(.subheadline)
                                .color(.gray)
                                .lineLimit(0)

                            Spacer()
                        }
                    }
                    .padding(8)

                }.navigationBarTitle(Text("In Theater"))
            }
        }.onAppear(perform: self.viewModel.load)
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
