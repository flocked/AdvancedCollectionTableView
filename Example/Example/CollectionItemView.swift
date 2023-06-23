//
//  CollectionItemView.swift
//
//
//  Created by Florian Zand on 24.01.23.
//

import AppKit
import SwiftUI
import AdvancedCollectionTableView

struct CollectionItemView: View {
    let item: CollectionItem
    let state: NSItemConfigurationState
    
    @Namespace var animation

    
    init(_ item: CollectionItem, state: NSItemConfigurationState) {
        self.item = item
        self.state = state
    }
    
    @ViewBuilder
    var imageItem: some View {
        if (state.isSelected) {
            Image(NSImage(named: item.imageName)!)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(10.0)
                .overlay(RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.accentColor, lineWidth: 4))
        } else {
            Image(NSImage(named: item.imageName)!)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(10.0)
        }
    }
    
    var body: some View {
        VStack(spacing: 4.0) {
            if (state.isHovered) {
                imageItem
                    .overlay(RoundedRectangle(cornerRadius: 10).foregroundColor(.white).opacity(0.25))
                    .scaleEffect(1.05)
                    .matchedGeometryEffect(id: "imageItem", in: animation)
            } else {
                imageItem
                    .matchedGeometryEffect(id: "imageItem", in: animation)
            }
            VStack(spacing: 4.0) {
                Text(item.title)
                    .font(.body)
                    .lineLimit(1)
                Text(item.detail)
                    .font(.caption)
                    .foregroundColor(.black.opacity(0.5))
                    .lineLimit(1)
            }
        }
    }
}

struct CollectionItemView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 10.0) {
            HStack(spacing: 10.0) {
                CollectionItemView(CollectionItem.sample[0], state: NSItemConfigurationState(isSelected: true))
                    .frame(width: 140, height: 160)
                CollectionItemView(CollectionItem.sample[1], state: NSItemConfigurationState(isSelected: false))
                    .frame(width: 140, height: 160)
            }
            HStack(spacing: 10.0) {
                CollectionItemView(CollectionItem.sample[2], state: NSItemConfigurationState(isSelected: true))
                    .frame(width: 140, height: 160)
                CollectionItemView(CollectionItem.sample[3], state: NSItemConfigurationState(isSelected: true, isHovered: true))
                    .frame(width: 140, height: 160)
            }
        }
            .padding()
    }
}

