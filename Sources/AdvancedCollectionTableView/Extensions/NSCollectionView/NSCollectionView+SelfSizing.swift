//
//  NSCollectionView+SelfSizing.swift
//  
//
//  Created by Florian Zand on 23.07.23.
//

// Currently not implemented

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
 get { return getAssociatedValue(key: "NSCollectionView_selfSizingInvalidation", object: self, initialValue: SelfSizingInvalidation.disabled) }
 set {
 set(associatedValue: newValue, key: "NSCollectionView_selfSizingInvalidation", object: self)
 if newValue != .disabled {
 NSCollectionViewItem.swizzleCollectionViewItemIfNeeded()
 }
 }
 }
 }
 
 internal extension NSCollectionViewItem {
 static var didSwizzleCollectionViewItem: Bool {
 get { getAssociatedValue(key: "NSCollectionViewItem_didSwizzleCollectionViewItem", object: self, initialValue: false) }
 set { set(associatedValue: newValue, key: "NSCollectionViewItem_didSwizzleCollectionViewItem", object: self) }
 }
 
 static func swizzleCollectionViewItemIfNeeded() {
 if didSwizzleCollectionViewItem == false {
 didSwizzleCollectionViewItem = true
 do {
 _ = try Swizzle(NSCollectionViewItem.self) {
 #selector(viewDidLayout) <-> #selector(swizzled_viewDidLayout)
 #selector(apply(_:)) <-> #selector(swizzled_apply(_:))
 #selector(preferredLayoutAttributesFitting(_:)) <-> #selector(swizzled_preferredLayoutAttributesFitting(_:))
 }
 } catch {
 Swift.print(error)
 }
 }
 }
 
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
