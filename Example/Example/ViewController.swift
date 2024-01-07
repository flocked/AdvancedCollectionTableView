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
    
    @IBOutlet weak var collectionView: NSCollectionView!
        
    var galleryItems = GalleryItem.sampleItems
    
    lazy var dataSource = DataSource(collectionView: collectionView, itemRegistration: itemRegistration)
    
    lazy var itemRegistration = ItemRegistration() { collectionViewItem, indexPath, galleryItem in

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
        
    lazy var toolbar = Toolbar() {
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
        
        // Enables deleting of selected items via backspace keyboard shortcut.
        dataSource.allowsDeleting = true
        
        // Enables reordering of items by dragging them.
        dataSource.allowsReordering = true
                
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

fileprivate extension NSView {
    /// Creates a colored view.
    convenience init(color: NSUIColor, opacity: CGFloat) {
        self.init(frame: .zero)
        backgroundColor = color
        alphaValue = opacity
    }
}


final class HeaderCell: NSView, NSCollectionViewSectionHeaderView {
    lazy var label: NSTextField = {
        let label = NSTextField()
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.stringValue = "Header"
        label.textColor = NSColor.labelColor
        label.isBordered = false
        label.isEditable = false
        label.isSelectable = false
        label.backgroundColor = .clear
        return label
    }()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: label.leadingAnchor, constant: -16),
            bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 4),
            widthAnchor.constraint(equalTo: label.widthAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static let id = NSUserInterfaceItemIdentifier(rawValue: "sectionHeader")
}
