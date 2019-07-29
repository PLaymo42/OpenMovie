//
//  ActivityIndicator.swift
//  OpenMovie
//
//  Created by Anthony Soulier on 29/07/2019.
//  Copyright © 2019 Anthony Soulier. All rights reserved.
//

import SwiftUI

struct ActivityIndicator: UIViewRepresentable {

    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        self.isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
