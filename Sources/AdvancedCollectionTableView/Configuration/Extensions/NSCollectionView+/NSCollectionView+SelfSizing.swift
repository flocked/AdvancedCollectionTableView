//
//  NSCollectionView+SelfSizing.swift
//  
//
//  Created by Florian Zand on 23.07.23.
//

/*
import AppKit
import FZSwiftUtils
import FZUIKit

public extension NSCollectionView {
    /**
     Constants that describe modes for invalidating the size of self-sizing table view items.
     
     Use these constants with the selfSizingInvalidation property.
     
     - Parameters:
     - disabled: A mode that disables self-sizing invalidation.
     - enabled: A mode that enables manual self-sizing invalidation.
     - enabledIncludingConstraints: A mode that enables automatic self-sizing invalidation after Auto Layout changes.
     */
    enum SelfSizingInvalidation: Int {
        case disabled = 0
        case enabled = 1
        case enabledIncludingConstraints = 2
    }
    
    /**
     The mode that the table view uses for invalidating the size of self-sizing items.
     */
    var selfSizingInvalidation: SelfSizingInvalidation {
        get {
            let rawValue: Int = getAssociatedValue(key: "NSCollectionView_selfSizingInvalidation", object: self, initialValue: SelfSizingInvalidation.disabled.rawValue)
            return SelfSizingInvalidation(rawValue: rawValue)!
        }
        set {
            self.indexPathsForVisibleItems()
            set(associatedValue: newValue.rawValue, key: "NSCollectionView_selfSizingInvalidation", object: self)
        }
    }
}

internal extension NSCollectionViewItem {    
    @objc func swizzled_apply(_ layoutAttributes: NSCollectionViewLayoutAttributes) {
        self.cachedLayoutAttributes = layoutAttributes
    }
    
    @objc func swizzled_preferredLayoutAttributesFitting(_ layoutAttributes: NSCollectionViewLayoutAttributes) -> NSCollectionViewLayoutAttributes {
        if (self.backgroundConfiguration != nil || self.contentConfiguration != nil) {
            
            let width = layoutAttributes.size.width
            var fittingSize = self.sizeThatFits(CGSize(width: width, height: .infinity))
            fittingSize.width = width
            layoutAttributes.size = fittingSize
            return layoutAttributes
        }
        return swizzled_preferredLayoutAttributesFitting(layoutAttributes)
    }
    
    @objc func swizzled_viewDidLayout() {
        switch collectionView?.selfSizingInvalidation {
        case .enabled:
            if let cachedLayoutAttributes = cachedLayoutAttributes {
                if (self.view.frame != cachedLayoutAttributes.frame) {
                    Swift.print("Not the same. InvalidateSelfSizing")
                    invalidateSelfSizing()
                }
            }
        case .enabledIncludingConstraints:
            break
        default:
            break
        }
    }
}
*/
