//
//  ViewController.swift
//
//
//  Created by Florian Zand on 19.01.23.
//

import AppKit
import AdvancedCollectionTableView

class MainViewController: NSViewController {
    typealias DataSource = CollectionViewDiffableDataSource<Section, GalleryItem>
    typealias ItemRegistration = NSCollectionView.ItemRegistration<NSCollectionViewItem, GalleryItem>
    
    @IBOutlet var collectionView: NSCollectionView!

    var galleryItems = GalleryItem.sampleItems

    lazy var dataSource = DataSource(collectionView: collectionView, itemRegistration: itemRegistration)

    let itemRegistration = ItemRegistration() { collectionViewItem, _, galleryItem in
        /// Configurate the item
        var configuration = NSItemContentConfiguration()

        configuration.text = galleryItem.title
        configuration.secondaryText = galleryItem.detail
        configuration.image = NSImage(named: galleryItem.title)
        configuration.contentProperties.shadow = .black(opacity: 0.5, radius: 5.0)

        if let badgeText = galleryItem.badgeText {
            configuration.badges = [.text(badgeText, color: galleryItem.badgeColor, type: .attachment)]
        }
        
        if galleryItem.isFavorite {
            configuration.badges = [.text("􀋃", color: .systemRed, shape: .circle, type: .attachment)]
        }

        /// Apply the configuration
        collectionViewItem.contentConfiguration = configuration
        
        /// Gets called when the item state changes (on selection, mouse hover, etc.)
        collectionViewItem.configurationUpdateHandler = { item, state in
            /// Updates the configuration based on whether the mouse is hovering the item
            configuration.contentProperties.scaleTransform = state.isHovered ? 1.03 : 1.0
            configuration.overlayView = state.isHovered ? NSView(color: .white, opacity: 0.25) : nil

            /// Apply the updated configuration
            item.contentConfiguration = configuration
            
            item.view.anchorPoint = CGPoint(0.5)
            item.view.rotation = state.isHovered ? .init(0, 0, 40) : .init(0, 0, 0)
        }
    }
    
    let testView = NSView().backgroundColor(.controlAccentColor).size(CGSize(200, 100))

    override func viewDidLayout() {
        testView.rotation = Bool.random() ? .init(0, 0, 40) : .init(0, 0, 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testView.center = view.center
        view.addSubview(testView)
        testView.anchorPoint = CGPoint(0.5)

        collectionView.collectionViewLayout = .grid(columns: 3)

        collectionView.dataSource = dataSource

        /// Enables deleting selected items via backspace key.
        dataSource.deletingHandlers.canDelete = { selectedItems in return selectedItems }
        dataSource.deletingHandlers.didDelete = { deletedItems, _ in
            self.galleryItems.remove(deletedItems)
        }

        /// Enables reordering selected items by dragging them.
        dataSource.reorderingHandlers.canReorder = { selectedItems in return true }
        dataSource.reorderingHandlers.didReorder = { transaction in
            self.galleryItems = self.galleryItems.applying(transaction.difference)!
        }

        dataSource.rightClickHandler = { selectedItems in
            selectedItems.forEach({ item in
                item.isFavorite = !item.isFavorite
            })
            /// Reconfigurates items without reloading them by calling the item registration handler.
            self.dataSource.reconfigureElements(selectedItems)
        }
                
        applySnapshot(using: galleryItems)
        
        dataSource.selectElements([galleryItems.first!], scrollPosition: .top)
        collectionView.makeFirstResponder()
    }

    func applySnapshot(using items: [GalleryItem]) {
        var snapshot = dataSource.emptySnapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot, .withoutAnimation)
    }
}

private extension NSView {
    /// Creates a colored view.
    convenience init(color: NSColor, opacity: CGFloat) {
        self.init(frame: .zero)
        backgroundColor = color
        alphaValue = opacity
    }
}
