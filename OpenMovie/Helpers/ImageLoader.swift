//
//  ImageLoader.swift
//  OpenMovie
//
//  Created by Anthony Soulier on 02/07/2019.
//  Copyright © 2019 Anthony Soulier. All rights reserved.
//

import SwiftUI
import UIKit
import Combine

final class ImageLoader: BindableObject {

    private let path: String?
    private let service: ImageService

    private var cancellable: AnyCancellable?

    let didChange = PassthroughSubject<UIImage?, Never>()

    private(set) var image: UIImage? = nil {
        didSet {
            self.didChange.send(self.image)
        }
    }

    init(path: String?, service: ImageService = .shared) {
        self.path = path
        self.service = service
    }

    func loadImage() {

        guard let path = path else { image = nil; return }

        self.cancellable = self.service.image(poster: path, size: .medium)
            .catch { _ in Just(nil) }
            .receive(on: RunLoop.main)
            .assign(to: \.image, on: self)
    }
}
