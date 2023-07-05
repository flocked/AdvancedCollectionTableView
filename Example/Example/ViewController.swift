//
//  ViewController.swift
//  
//
//  Created by Florian Zand on 19.01.23.
//

import AppKit
import AdvancedCollectionTableView

class ViewController: NSViewController {
    
    typealias ItemRegistration = NSCollectionView.ItemRegistration<NSCollectionViewItem, GalleryItem>
    typealias DataSource = CollectionViewDiffableDataSource<Section, GalleryItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, GalleryItem>
    
    @IBOutlet weak var collectionView: NSCollectionView!
    
    /// Sample items.
    var galleryItems: [GalleryItem] = GalleryItem.sampleItems
    
    lazy var dataSource = DataSource(collectionView: self.collectionView, itemRegistration: itemRegistration)

    lazy var itemRegistration: ItemRegistration = {
        var itemRegistration = ItemRegistration(handler: { collectionViewItem, indexPath, galleryItem in
            
            var configuration = NSItemContentConfiguration()
            configuration.text = galleryItem.title
            configuration.secondaryText = galleryItem.detail
            configuration.image = NSImage(named: galleryItem.imageName)
            
            collectionViewItem.contentConfiguration = configuration
            
            collectionViewItem.configurationUpdateHandler = { [weak self] item, state in
                
                configuration.contentProperties.scaleTransform = state.isHovered ? 1.03 : 1.0
                configuration.overlayView = state.isHovered ? NSView(color: .white.withAlphaComponent(0.25)) : nil
                
                configuration.contentProperties.borderColor =  state.isSelected ? .controlAccentColor : nil
                configuration.contentProperties.borderWidth = state.isSelected ? 2.0 : 0.0
                configuration.contentProperties.shadow = state.isSelected ? .colored(.controlAccentColor) : .black()
                
                collectionViewItem.contentConfiguration = configuration
            }
        })
        return itemRegistration
    }()
    
    override func viewDidLoad() {
        
        collectionView.collectionViewLayout = NSCollectionViewCompositionalLayout.grid(columns: 2, spacing: 4.0, insets: .init(14.0))
        collectionView.dataSource = self.dataSource
        
        dataSource.allowsDeleting = true
        dataSource.allowsReordering = true
        
        applySnapshot()
        
        collectionView.selectItems(at: .init([IndexPath(item: 0, section: 0)]), scrollPosition: .top)
        super.viewDidLoad()
    }
    
    override func viewDidAppear() {
        self.view.window?.makeFirstResponder(self.collectionView)
    }
    
    func applySnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(galleryItems, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
