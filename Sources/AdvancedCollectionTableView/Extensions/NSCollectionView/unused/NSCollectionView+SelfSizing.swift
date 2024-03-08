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

// Currently not implemented
extension NSCollectionView {
    /**
     Constants that describe modes for invalidating the size of self-sizing collection view items.

     Use these constants with the `selfSizingInvalidation` property.
     */
    enum SelfSizingInvalidation: Int {
        /// A mode that disables self-sizing invalidation.
        case disabled = 0
        /// A mode that enables manual self-sizing invalidation.
        case enabled = 1
        /// A mode that enables automatic self-sizing invalidation after Auto Layout changes.
        case enabledIncludingConstraints = 2
    }

    /// The mode that the collection view uses for invalidating the size of self-sizing items.
    var selfSizingInvalidation: SelfSizingInvalidation {
        get { getAssociatedValue(key: "selfSizingInvalidation", object: self, initialValue: SelfSizingInvalidation.disabled) }
        set {
            set(associatedValue: newValue, key: "selfSizingInvalidation", object: self)
            if newValue != .disabled {
                NSCollectionViewItem.swizzleCollectionViewItemIfNeeded()
            }
        }
    }
}

extension NSCollectionViewItem {
    static var didSwizzleCollectionViewItem: Bool {
        get { getAssociatedValue(key: "didSwizzleCollectionViewItemLayoutAttributes", object: self, initialValue: false) }
        set { set(associatedValue: newValue, key: "didSwizzleCollectionViewItemLayoutAttributes", object: self) }
    }

    static func swizzleCollectionViewItemIfNeeded() {
        if didSwizzleCollectionViewItem == false {
            do {
                _ = try Swizzle(NSCollectionViewItem.self) {
                    #selector(viewDidLayout) <-> #selector(swizzled_viewDidLayout)
                    #selector(apply(_:)) <-> #selector(swizzled_apply(_:))
                    #selector(preferredLayoutAttributesFitting(_:)) <-> #selector(swizzled_preferredLayoutAttributesFitting(_:))
                }
                didSwizzleCollectionViewItem = true
            } catch {
                Swift.debugPrint(error)
            }
        }
    }

    @objc func swizzled_apply(_ layoutAttributes: NSCollectionViewLayoutAttributes) {
        cachedLayoutAttributes = layoutAttributes
    }

    @objc func swizzled_preferredLayoutAttributesFitting(_ layoutAttributes: NSCollectionViewLayoutAttributes) -> NSCollectionViewLayoutAttributes {
        if backgroundConfiguration != nil || contentConfiguration != nil {
            let width = layoutAttributes.size.width
            var fittingSize = view.sizeThatFits(CGSize(width: width, height: .infinity))
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
                if view.frame != cachedLayoutAttributes.frame {
                    Swift.debugPrint("Not the same. InvalidateSelfSizing")
                    invalidateSelfSizing()
                }
            }
        case .enabledIncludingConstraints:
            break
        default:
            break
        }
    }

    var cachedLayoutAttributes: NSCollectionViewLayoutAttributes? {
        get { getAssociatedValue(key: "cachedLayoutAttributes", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "cachedLayoutAttributes", object: self) }
    }

    var layoutInvalidationContext: NSCollectionViewLayoutInvalidationContext? {
        guard let collectionView = collectionView, let indexPath = collectionView.indexPath(for: self) else { return nil }

        let context = InvalidationContext(invalidateEverything: false)
        context.invalidateItems(at: [indexPath])
        return context
    }

    func invalidateSelfSizing() {
        guard let invalidationContext = layoutInvalidationContext, let collectionView = collectionView, let collectionViewLayout = collectionView.collectionViewLayout else { return }

        view.invalidateIntrinsicContentSize()

        collectionViewLayout.invalidateLayout(with: invalidationContext)
        collectionView.layoutSubtreeIfNeeded()
    }

    /// Invalidation of collection view items.
    class InvalidationContext: NSCollectionViewLayoutInvalidationContext {
        override public var invalidateEverything: Bool {
            _invalidateEverything
        }

        var _invalidateEverything: Bool

        public init(invalidateEverything: Bool) {
            _invalidateEverything = invalidateEverything
        }
    }
}
*/
