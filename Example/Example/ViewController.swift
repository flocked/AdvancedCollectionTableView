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
    
    lazy var dataSource: DataSource = DataSource(collectionView: collectionView, itemRegistration: itemRegistration)
    
    let itemRegistration = ItemRegistration() { collectionViewItem, indexPath, galleryItem in
        // Content configuration for collectionview items.
        var configuration = NSItemContentConfiguration()
        configuration.text = galleryItem.title
        configuration.secondaryText = galleryItem.detail
        configuration.image = NSImage(named: galleryItem.imageName)

        collectionViewItem.contentConfiguration = configuration

        /// Gets called when the item gets selected, hovered by mouse, etc.
        collectionViewItem.configurationUpdateHandler = { item, state in
            /// Updates the configuration based on whether the mouse is hovering the item.
            configuration.contentProperties.scaleTransform = state.isHovered ? 1.03 : 1.0
            configuration.overlayView = state.isHovered ? NSView(color: .white.withAlphaComponent(0.25)) : nil
            
            /// Updates the configuration based on whether the item is selected.
            configuration.contentProperties.borderColor =  state.isSelected ? .controlAccentColor : nil
            configuration.contentProperties.borderWidth = state.isSelected ? 2.0 : 0.0
            configuration.contentProperties.shadow = state.isSelected ? .colored(.controlAccentColor) : .black()
            
            collectionViewItem.contentConfiguration = configuration
        }
    }
    
    // Window toolbar
    lazy var toolbar = Toolbar("WindowToolbar") {
        /// Toolbar item that reconfigurates the first collectionview item without reloading it which provides much better performance.
        ToolbarItem.Button("Reconfigurate", image: NSImage(systemSymbolName: "arrow.clockwise.circle")!).onAction {
            guard let firstItem = self.galleryItems.first, let newRandomItem = GalleryItem.sampleItems.randomElement(excluding: [firstItem]) else { return }
                        
            // Replaces the info of the first gallery item with the new random item values.
            firstItem.replaceInfo(with: newRandomItem)
            
            // Reconfigurates the first item.
            self.dataSource.reconfigurateElements([firstItem])
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
}
