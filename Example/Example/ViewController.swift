//
//  ViewController.swift
//
//
//  Created by Florian Zand on 19.01.23.
//

import AdvancedCollectionTableView
import AppKit
import FZSwiftUtils
import FZUIKit

class ViewController: NSViewController {
    typealias ItemRegistration = NSCollectionView.ItemRegistration<NSCollectionViewItem, GalleryItem>
    typealias DataSource = CollectionViewDiffableDataSource<Section, GalleryItem>

    @IBOutlet var collectionView: NSCollectionView!

    var galleryItems = GalleryItem.sampleItems

    lazy var dataSource = DataSource(collectionView: collectionView, itemRegistration: itemRegistration)

    lazy var itemRegistration = ItemRegistration { collectionViewItem, _, galleryItem in

        // Configurate the item
        var configuration = NSItemContentConfiguration()

        configuration.text = galleryItem.title
        configuration.secondaryText = galleryItem.detail
        configuration.image = NSImage(named: galleryItem.imageName)
        configuration.contentProperties.shadow = .black(opacity: 0.5, radius: 5.0)

        if let badgeText = galleryItem.badge {
            configuration.badges = [.textBadge(badgeText, color: galleryItem.badgeColor, type: .attachment)]
        }
        
        if galleryItem.isFavorite {
            configuration.badges = [.textBadge("􀋃", color: .systemRed, type: .attachment, shape: .circle)]
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

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.collectionViewLayout = .grid(columns: 3)

        collectionView.dataSource = dataSource

        // Enables deleting selected items via backspace key.
        dataSource.deletingHandlers.canDelete = { selectedItems in return selectedItems }

        // Enables reordering selected items by dragging them.
        dataSource.reorderingHandlers.canReorder = { selectedItems in return true }

        dataSource.rightClickHandler = { selectedItems in
            selectedItems.forEach({ item in
                item.isFavorite = !item.isFavorite
            })
            // Reconfigurates items without reloading them by calling the item registration
            self.dataSource.reconfigureElements(selectedItems)
        }

        applySnapshot(using: galleryItems)
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        view.window?.makeFirstResponder(collectionView)
        collectionView.selectItems(at: [.zero], scrollPosition: .top)
    }

    func applySnapshot(using items: [GalleryItem]) {
        var snapshot = dataSource.emptySnapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot, .animated)
    }
}

private extension NSView {
    /// Creates a colored view.
    convenience init(color: NSUIColor, opacity: CGFloat) {
        self.init(frame: .zero)
        backgroundColor = color
        alphaValue = opacity
    }
}
