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
    typealias DataSource = CollectionViewDiffableDataSource<Section, GalleryItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, GalleryItem>
    
    @IBOutlet weak var collectionView: NSCollectionView!
    
    lazy var dataSource: DataSource = DataSource(collectionView: collectionView, itemRegistration: itemRegistration)
    
    lazy var itemRegistration: ItemRegistration = ItemRegistration() { collectionViewItem, indexPath, galleryItem in

        // Configurate the item
        var configuration = NSItemContentConfiguration()
        configuration.text = galleryItem.title
        configuration.secondaryText = galleryItem.detail
        configuration.image = NSImage(named: galleryItem.imageName)
        configuration.contentProperties.shadow = .black(opacity: 0.5, radius: 5.0)
        
        if let badgeText = galleryItem.badge {
            configuration.badges = [.text(badgeText, color: .controlAccentColor, type: .attachment, position: .topRight)]
        }
        
        // Apply the configuration
        collectionViewItem.contentConfiguration = configuration
        
        // Gets called when the item state changes (on selection, mouse hover, etc.)
        collectionViewItem.configurationUpdateHandler = { item, state in            
            // Adds a selection border for state.isSelected
            configuration = configuration.updated(for: state)
            
            // Updates the configuration based on whether the mouse is hovering the item
            configuration.contentProperties.scaleTransform = state.isHovered ? 1.03 : 1.0
            configuration.overlayView = state.isHovered ? NSView(color: .white, opacity: 0.25) : nil
 
            // Apply the updated configuration
            item.contentConfiguration = configuration
        }
    }
        
    // Window toolbar
    lazy var toolbar = Toolbar() {
        // Toolbar item that reconfigurates the collectionview items without reloading them which provides much better performance compared to `reloadItems(at: )`.
        ToolbarItem.Button(image: NSImage(systemSymbolName: "arrow.clockwise.circle")!)
            .label("Reconfigurate")
            .onAction {
                var snapshotGalleryItems = self.dataSource.snapshot().itemIdentifiers
                snapshotGalleryItems.shuffleItems()
                self.dataSource.reconfigureElements(snapshotGalleryItems)
            }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.collectionViewLayout = .grid(columns: 2)
        
        collectionView.dataSource = self.dataSource
        
        // Enables deleting of selected items via backspace.
        dataSource.allowsDeleting = true
        // Enables reordering of items via drag and drop.
        dataSource.allowsReordering = true
        
        collectionView.allowsMultipleSelection = true
        
        // Applies a snapshot with sample gallery items.
        applySnapshot(with: GalleryItem.sampleItems)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()

        toolbar.attachedWindow = self.view.window
        
        // Makes the collectionview first responder so it reacts to backspace item deletion and spacebar item quicklook preview.
        collectionView.becomeFirstResponder()
        
        collectionView.selectItems(at: [.zero], scrollPosition: .top)
    }
    
    func applySnapshot(with galleryItems: [GalleryItem]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(galleryItems, toSection: .main)
        dataSource.apply(snapshot, .usingReloadData)
    }
}

fileprivate extension NSView {
    /// Creates a colored view.
    convenience init(color: NSUIColor, opacity: CGFloat) {
        self.init(frame: .zero)
        self.backgroundColor = color
        self.alphaValue = opacity
    }
}
