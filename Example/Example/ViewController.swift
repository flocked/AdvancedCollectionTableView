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
            configuration.badges = [.text(badgeText, color: .controlAccentColor, type: .attachment, position: .topRight)]
        }

        // Apply the configuration
        collectionViewItem.contentConfiguration = configuration

        // Gets called when the item state changes (on selection, mouse hover, etc.)
        collectionViewItem.configurationUpdateHandler = { item, state in
            // Adds a selection border for state.isSelected
            configuration = configuration.updated(for: state)

            // Updates the configuration based on whether the mouse is hovering the item
            configuration.contentProperties.scaleTransform = state.isHovered ? CGPoint(x: 1.03, y: 1.03) : CGPoint(x: 1, y: 1)
            configuration.overlayView = state.isHovered ? NSView(color: .white, opacity: 0.25) : nil

            // Apply the updated configuration
            item.contentConfiguration = configuration
        }
    }

    lazy var toolbar = Toolbar {
        // Reconfigurates the collection view items without reloading them which provides much better performance compared to `reloadItems(at: )`.
        ToolbarItem.Button(image: NSImage(systemSymbolName: "arrow.clockwise.circle")!)
            .label("Reconfigurate")
            .onAction {
                self.dataSource.reconfigureElements(self.galleryItems.shuffledItems())
            }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.collectionViewLayout = .grid(columns: 3)

        collectionView.dataSource = dataSource

        // Enables deleting of every selected item via backspace keyboard shortcut.
        dataSource.deletingHandlers.canDelete = { selectedGalleryItems in return selectedGalleryItems }

        // Enables reordering of items by dragging them.
        dataSource.reorderingHandlers.canReorder = { selectedGalleryItems in return true }

        // Right click menu for deleting selected items.
        dataSource.menuProvider = { selectedItems in
            guard !selectedItems.isEmpty else { return nil }
            let deleteMenuItem = NSMenuItem("Delete…")
            deleteMenuItem.actionBlock = { _ in
                self.galleryItems.remove(selectedItems)
                self.applySnapshot(using: self.galleryItems)
            }
            let menu = NSMenu()
            menu.addItem(deleteMenuItem)
            return menu
        }

        applySnapshot(using: galleryItems)
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        toolbar.attachedWindow = view.window
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
