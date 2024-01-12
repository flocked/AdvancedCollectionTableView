//
//  File.swift
//  
//
//  Created by Florian Zand on 12.01.24.
//

import AppKit
import SwiftUI

struct ItemContentView: View {
    
    let configuration: NSItemContentConfiguration
    
    @ViewBuilder
    var textItem: some View {
        if let attributedText = configuration.attributedText {
            Text(attributedText)
        } else if let text = configuration.text {
            Text(text)
        }
    }
    
    @ViewBuilder
    var secondaryText: some View {
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
                .lineLimit(configuration.textProperties.numberOfLines)
                .foregroundStyle(Color(configuration.textProperties._resolvedTextColor))
                .minimumScaleFactor(configuration.textProperties.minimumScaleFactor)
            
            secondaryText
                .lineLimit(configuration.secondaryTextProperties.numberOfLines)
                .foregroundStyle(Color(configuration.secondaryTextProperties._resolvedTextColor))
                .minimumScaleFactor(configuration.secondaryTextProperties.minimumScaleFactor)
            
        }
    }
    
    var body: some View {
        Text("")
    }
}
