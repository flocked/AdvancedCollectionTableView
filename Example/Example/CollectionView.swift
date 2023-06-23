//
//  CollectionView.swift
//  Example
//
//  Created by Florian Zand on 23.06.23.
//

import AppKit

class CollectionView: NSCollectionView {
    override func keyDown(with event: NSEvent) {
        super.keyDown(with: event)
        Swift.print("CollectionView keydown")
    }
}
