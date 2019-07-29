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
    private let size: ImageService.Size
    private let service: ImageService

    private var cancellable: AnyCancellable?

    let willChange = PassthroughSubject<Void, Never>()

    var isLoading: Bool = false

    private(set) var image: UIImage? = nil {
        willSet {
            self.isLoading = false
            self.willChange.send()
        }
    }


    init(path: String?,
         size: ImageService.Size = .medium,
         service: ImageService = .shared) {
        self.path = path
        self.size = size
        self.service = service
    }

    func loadImage() {

        guard let path = self.path else { return }

        self.isLoading = true

        self.cancellable = self.service.image(
            poster: path,
            size: size
        )
            .catch { _ in Just(nil) }
            .receive(on: RunLoop.main)
            .assign(to: \.image, on: self)
    }

}
