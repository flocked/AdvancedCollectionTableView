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
    
    lazy var dataSource = DataSource(collectionView: self.collectionView, itemRegistration: itemRegistration)

    lazy var itemRegistration: ItemRegistration = {
        var itemRegistration = ItemRegistration(handler: { collectionViewItem, indexPath, galleryItem in
            
            // A content configuration for items.
            var configuration = NSItemContentConfiguration()
            configuration.text = galleryItem.title
            configuration.secondaryText = galleryItem.detail
            configuration.image = NSImage(named: galleryItem.imageName)
            
            collectionViewItem.contentConfiguration = configuration
            
            /// Gets called when an item gets selected, hovered by mouse, etc.
            collectionViewItem.configurationUpdateHandler = { [weak self] item, state in
                /// Updates the configuration based on if the mouse is hovering the item.
                configuration.contentProperties.scaleTransform = state.isHovered ? 1.03 : 1.0
                configuration.overlayView = state.isHovered ? NSView(color: .white.withAlphaComponent(0.25)) : nil
                
                /// Updates the configuration based on if the item is selected.
                configuration.contentProperties.borderColor =  state.isSelected ? .controlAccentColor : nil
                configuration.contentProperties.borderWidth = state.isSelected ? 2.0 : 0.0
                configuration.contentProperties.shadow = state.isSelected ? .colored(.controlAccentColor) : .black()
                collectionViewItem.contentConfiguration = configuration
            }
        })
        return itemRegistration
    }()
    
    // The toolbar of the window which adds reconfigurating the first displayed item.
    // Updates the data, preserving the existing cells for the first item.
    lazy var toolbar = Toolbar("Toolbar") {
        /// A toolbar button for reconfigurating the first gallery item.
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
            self.galleryItems.insert(newRandomItem, at: 0)
            self.applySnapshot(with: self.galleryItems, .usingReloadData)
        }

    }.attachedWindow(self.view.window)
    
    override func viewDidLoad() {
        
        collectionView.collectionViewLayout = .grid(columns: 2)
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
