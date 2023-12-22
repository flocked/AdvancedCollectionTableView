//
//  File.swift
//  
//
//  Created by Florian Zand on 22.12.23.
//

import AppKit
import SwiftUI
import FZUIKit

extension NSListContentViewSwiftUI {
    struct ContentView: View {
        let configuration: NSListContentConfiguration
        
        @ViewBuilder
        var textItem: some View {
            if let attributedText = configuration.attributedText {
                Text(attributedText)
            } else if let text = configuration.text {
                Text(text)
            }
        }
        
        @ViewBuilder
        var secondaryTextItem: some View {
            if let attributedText = configuration.secondaryAttributedText {
                Text(attributedText)
            } else if let text = configuration.secondaryText {
                Text(text)
            }
        }
        
        @ViewBuilder
        var textStack: some View {
            VStack(alignment: .leading, spacing: configuration.textToSecondaryTextPadding) {
                textItem
                    .font(Font(configuration.textProperties.font))
                    .foregroundStyle(Color(configuration.textProperties.color))
                secondaryTextItem
                    .font(Font(configuration.secondaryTextProperties.font))
                    .foregroundStyle(Color(configuration.secondaryTextProperties.color))
            }
        }
        
        @ViewBuilder
        var imageItem: some View {
            if let image = configuration.image {
                Image(image)
            }
        }
        
        var body: some View {
            Text("")
        }
    }
}
