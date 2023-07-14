//
//  ViewController.swift
//  
//
//  Created by Florian Zand on 19.01.23.
//

import AppKit
import AdvancedCollectionTableView
import FZUIKit
import FZSwiftUtils

class ViewController: NSViewController {
    
    typealias ItemRegistration = NSCollectionView.ItemRegistration<NSCollectionViewItem, GalleryItem>
    typealias DataSource = AdvanceColllectionViewDiffableDataSource<Section, GalleryItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, GalleryItem>
    
    @IBOutlet weak var collectionView: NSCollectionView!
    
    /// Sample items.
    var galleryItems: [GalleryItem] = GalleryItem.sampleItems
    
    var dataSource: DataSource!

     let itemRegistration = ItemRegistration() { collectionViewItem, indexPath, galleryItem in
            
            Swift.print("itemRegistration", galleryItem.title)
            
            // A content configuration for items.
            var configuration = NSItemContentConfiguration()
            configuration.text = galleryItem.title
            configuration.secondaryText = galleryItem.detail
            configuration.image = NSImage(named: galleryItem.imageName)
            
            collectionViewItem.contentConfiguration = configuration
            
            
            /// Gets called when an item gets selected, hovered by mouse, etc.
            collectionViewItem.configurationUpdateHandler = { item, state in
                /// Updates the configuration based on if the mouse is hovering the item.
                configuration.contentProperties.scaleTransform = state.isHovered ? 1.03 : 1.0
                configuration.overlayView = state.isHovered ? NSView(color: .white.withAlphaComponent(0.25)) : nil
                
                /// Updates the configuration based on if the item is selected.
                configuration.contentProperties.borderColor =  state.isSelected ? .controlAccentColor : nil
                configuration.contentProperties.borderWidth = state.isSelected ? 2.0 : 0.0
                configuration.contentProperties.shadow = state.isSelected ? .colored(.controlAccentColor) : .black()
                collectionViewItem.contentConfiguration = configuration
                
            }
        }
    
    // The toolbar of the window.
    lazy var toolbar = Toolbar("WindowToolbar") {
        /// A toolbar button for reconfigurating the first collection item which reconfigurates it without reloading it (much better performance).
        ToolbarItem.Button("Reconfigurate", image: NSImage(systemSymbolName: "arrow.clockwise.circle")!).onAction {
            guard let firstItem = self.galleryItems.first, let newRandomItem = GalleryItem.sampleItems.randomElement(excluding: [firstItem]) else { return }
            
            // Replaces the info of the first item with the new random item info.
            firstItem.imageName = newRandomItem.imageName
            firstItem.title = newRandomItem.title
            firstItem.detail = newRandomItem.detail
            
            // Reconfigurates the first item.
            self.dataSource.reconfigurateElements([firstItem])
        }
        /// A toolbar button for inserting a new random gallery item to the beginning of the collection.
        ToolbarItem.Button("Add", image: NSImage(systemSymbolName: "plus.app")!).onAction {
            let newRandomItem = GalleryItem.sampleItems.randomElement()!
            let previousItems = self.galleryItems
            self.galleryItems.insert(newRandomItem, at: 0)
          //  self.applySnapshot(with: self.galleryItems, .animated)
            
            Swift.print("newRandomItem", newRandomItem.title)

            
            var newSnapShot = self.dataSource.snapshot()
            if let first = newSnapShot.itemIdentifiers.first {
                newSnapShot.insertItems([newRandomItem], beforeItem: first)
            }
            self.dataSource.apply(newSnapShot, .animated) {
            }
            
            /*
            var snapshot = Snapshot()
            snapshot.appendSections([.main])
            snapshot.appendItems(previousItems, toSection: .main)
            self.dataSource.apply(snapshot, .non) {
                self.collectionView.collectionViewLayout?.invalidateLayout()
                snapshot = Snapshot()
                snapshot.appendSections([.main])
                snapshot.appendItems(self.galleryItems, toSection: .main)
                self.dataSource.apply(snapshot, .animated) {
                    self.collectionView.collectionViewLayout?.invalidateLayout()
                    self.dataSource.apply(snapshot, .non) {
                    }
                }
            }
            */
            /*
            snapshot.appendItems(self.galleryItems, toSection: .main)
            
            self.dataSource.apply(snapshot, .animated) {
                self.collectionView.collectionViewLayout?.invalidateLayout()
                snapshot.appendItems(self.galleryItems, toSection: .main)
                self.dataSource.apply(snapshot, .animated) {
                    self.collectionView.collectionViewLayout?.invalidateLayout()
                }
            }
            */
            
           
        }

    }.attachedWindow(self.view.window)
    
    override func viewDidLoad() {
        
        var layout = NSCollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 150, height: 150)
        layout.minimumInteritemSpacing = 8.0
        layout.sectionInset = .init(16.0)
    
        collectionView.collectionViewLayout = layout
        
        self.dataSource = DataSource(collectionView: self.collectionView, itemRegistration: itemRegistration)
        
        collectionView.dataSource = self.dataSource
        
        // Enables deleting of selected enables via backspace
        dataSource.allowsDeleting = true
        // Enables dragging of elements via drag and drop
        dataSource.allowsReordering = true
        
        applySnapshot(with: galleryItems)
        collectionView.selectItems(at: .init([IndexPath(item: 0, section: 0)]), scrollPosition: .top)
        
        super.viewDidLoad()
    }
    
    override func viewDidAppear() {
        // Loads the window toolbar.
        _ = toolbar
        
        // Makes the collectionview first responder so it reacts to backspace item deletion and spacebar item quicklook preview.
        collectionView.becomeFirstResponder()
        
        super.viewDidAppear()
        
    }
    
    func applySnapshot(with galleryItems: [GalleryItem], _ applyOption: NSDiffableDataSourceSnapshotApplyOption = .animated) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(galleryItems, toSection: .main)
        dataSource.apply(snapshot, applyOption)
    }
    
    func addRandomGalleryItem() {
        if let randomItem = GalleryItem.sampleItems.randomElement(excluding: galleryItems.isEmpty ? [] : [galleryItems.first!]) {
            self.galleryItems.insert(randomItem, at: 0)
        }
        self.applySnapshot(with: self.galleryItems)
    }
}
