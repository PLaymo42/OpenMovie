//
//  CircleView.swift
//  OpenMovie
//
//  Created by Anthony Soulier on 03/07/2019.
//  Copyright © 2019 Anthony Soulier. All rights reserved.
//

import SwiftUI

struct CircleView: View {

    @State var value: Int

    private let lineWidth: CGFloat = 2

    var body: some View {
        ZStack {
            Circle()
                .inset(by: lineWidth / 2)
                .stroke(self.color, lineWidth: lineWidth)

            Text("\(value)")
                .font(.caption)
                .foregroundColor(.gray)
                .minimumScaleFactor(0.1)
                .padding(6)
        }
    }

    private var color: Color {
        switch self.value {
        case 0..<33:
            return .red
        case 33..<66:
            return .yellow
        default:
            return .green
        }
    }
}

#if DEBUG
struct CircleView_Previews : PreviewProvider {
    static var previews: some View {
        CircleView(value: 43)
    }
}
#endif

