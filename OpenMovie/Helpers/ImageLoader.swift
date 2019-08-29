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

final class ImageLoader: ObservableObject {
    
    private let path: String?
    private let size: ImageService.Size
    private let service: ImageService

    private var cancellable: AnyCancellable?

    var isLoading: Bool = false

    @Published var image: UIImage? = nil

    init(path: String?,
         size: ImageService.Size = .medium,
         service: ImageService = .shared) {
        self.path = path
        self.size = size
        self.service = service
        
        if let path = path {
            self.image = service.fromCache(poster: path, size: size)
        }
    }

    func loadImage() {

        guard let path = self.path, self.image == nil else { return }

//        self.isLoading = true

        self.cancellable = self.service.image(
            poster: path,
            size: size
        )
            .catch { _ in Just(nil) }
            .receive(on: DispatchQueue.main)
            .assign(to: \.image, on: self)
    }

}
