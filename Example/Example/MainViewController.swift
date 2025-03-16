//
//  MainViewController.swift
//
//
//  Created by Florian Zand on 19.01.23.
//

import AppKit
import AdvancedCollectionTableView
import FZSwiftUtils
import FZUIKit

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
            
            /// Apply the updated configuration animated.
            item.contentConfiguration = configuration
        }
    }
    
    let testView = TestView()
    let view1 = TestView()
    let view2 = TestView()
    override func viewDidLoad() {
        super.viewDidLoad()
        

        Swift.print("view1", view1.tag)
        Swift.print("view2", view2.tag)

        Swift.print("-----")
        testView.addSubview(view1)
        Swift.print("-----")
        testView.addSubview(view2)
        Swift.print("-----")
        testView.addSubview(view1)
        Swift.print("-----")
        testView.subviews = [view1, view2]
        Swift.print("-----")
        testView.subviews = [view2, view1]
        Swift.print("-----")
        testView.subviews = [view2]


        var configuration = NSListContentConfiguration.sidebar()
        configuration.text = LoremIpsum.words(3)
        configuration.secondaryText = LoremIpsum.words(6)
        configuration.secondaryTextProperties.maximumNumberOfLines = 0
        configuration.image = NSImage(systemSymbolName: "photo")
        let contentView = configuration.makeContentView()
        contentView.frame.size = contentView.systemLayoutSizeFitting(width: 400)
        let containerView = NSTableCellView()
        containerView.frame.origin = CGPoint(20)
        containerView.frame.size = contentView.frame.size
        
        containerView.addSubview(contentView)
        containerView.cornerRadius = contentView.frame.size.height / 2.0
        Swift.print(contentView.frame.size.height / 2.0)
        contentView.frame.origin.x = contentView.frame.size.height / 2.0
        containerView.backgroundColor = .controlAccentColor
        containerView.backgroundStyle = .emphasized
      //  view.addSubview(containerView)
        
        let maskView = MaskView().size(CGSize(120, 60))
        maskView.backgroundColor = .clear
        maskView.shadowPath = .init(rect: maskView.bounds)
        view.addSubview(maskView)
      //  maskView.configurate(using: ShapeConfiguration.capsule)
        maskView.outerShadow = .accentColor(opacity: 0.9)
        
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

class MaskView: NSView {
    let shapeLayer = CAShapeLayer()
    
    override func layout() {
        super.layout()
        
        shapeLayer.frame = bounds
        shapeLayer.path = NSBezierPath(roundedRect: bounds, cornerRadius: bounds.height/2.0).cgPath
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
      //  layer?.addSublayer(shapeLayer)
        shapeLayer.fillColor = NSColor.controlAccentColor.cgColor
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
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



class TestView: NSView {
    var _tag: Int = Int.random(max: 30)
    
    override var tag: Int {
        _tag
    }
    
    override func layout() {
        super.layout()
        Swift.print("layout")
    }
    
    override func viewDidMoveToSuperview() {
        Swift.print("superview viewDidMoveToSuperview", superview != nil)
    }
    
    override func viewWillMove(toSuperview newSuperview: NSView?) {
        Swift.print("superview viewWillMove", newSuperview != nil)
    }
    
    override func layoutSubtreeIfNeeded() {
        Swift.print("layoutSubtreeIfNeeded")
    }
    
    override func willRemoveSubview(_ subview: NSView) {
        Swift.print("willRemoveSubview", subview.tag)

    }
    
    override func didAddSubview(_ subview: NSView) {
        Swift.print("didAddSubview", subview.tag)
    }
}

