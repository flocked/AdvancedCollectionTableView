//
//  SupplementaryRegistration.swift
//  
//
//  Created by Florian Zand on 19.05.22.
//

import AppKit

public extension NSCollectionView {
    func makeSupplementaryView<V>(using registration: SupplementaryRegistration<V>, for indexPath: IndexPath) -> V {
        return registration.makeSupplementaryView(self, indexPath) as! V
    }
}

public protocol NSCollectionViewSupplementaryProvider {
    func makeSupplementaryView(_ collectionView: NSCollectionView, _ indexPath: IndexPath) -> (NSView & NSCollectionViewElement)
    var elementKind: String { get }
}

public extension NSCollectionView {
    class SupplementaryRegistration<Supplementary>: NSCollectionViewSupplementaryProvider where Supplementary: (NSView & NSCollectionViewElement)  {
        
        public typealias Handler = ((Supplementary, SupplementaryElementKind, IndexPath)->(Void))
        
        internal let identifier: NSUserInterfaceItemIdentifier
        internal let nib: NSNib?
        internal let handler: Handler
        public let elementKind: SupplementaryElementKind
        internal weak var registeredCollectionView: NSCollectionView? = nil
        
        public init(elementKind: SupplementaryElementKind, handler: @escaping Handler) {
            self.handler = handler
            self.elementKind = elementKind
            self.nib = nil
            self.identifier = NSUserInterfaceItemIdentifier(String(describing: Supplementary.self) + elementKind)
        }
        
        public init(nib: NSNib, elementKind: SupplementaryElementKind, handler: @escaping Handler) {
            self.nib = nib
            self.elementKind = elementKind
            self.handler = handler
            self.identifier = NSUserInterfaceItemIdentifier(String(describing: Supplementary.self) + elementKind)
        }
        
        public func makeSupplementaryView(_ collectionView: NSCollectionView, _ indexPath: IndexPath) -> (NSView & NSCollectionViewElement)   {
            if (registeredCollectionView != collectionView) {
                self.register(for: collectionView)
            }
            let view: Supplementary = collectionView.makeSupplementaryView(ofKind: self.elementKind, withIdentifier: self.identifier, for: indexPath)
            self.handler(view, elementKind, indexPath)
            return view
        }
        
        internal func register(for collectionView: NSCollectionView) {
            if let nib = self.nib {
                //     collectionView.reg
                collectionView.register(nib, forSupplementaryViewOfKind: self.elementKind, withIdentifier: self.identifier)
            } else {
                collectionView.register(Supplementary.self, forSupplementaryViewOfKind: self.elementKind, withIdentifier: self.identifier)
            }
            self.registeredCollectionView = collectionView
        }
        
        internal func unregister(for collectionView: NSCollectionView) {
            let any: AnyClass? = nil
            collectionView.register(any, forItemWithIdentifier: self.identifier)
            self.registeredCollectionView = nil
        }
        
        deinit {
            if let registeredCollectionView = registeredCollectionView {
                self.unregister(for: registeredCollectionView)
            }
        }
    }
}
