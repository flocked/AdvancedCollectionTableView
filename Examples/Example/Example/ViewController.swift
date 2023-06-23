//
//  ViewController.swift
//  
//
//  Created by Florian Zand on 19.01.23.
//

import AppKit
import FZUIKit
import AdvancedCollectionTableView

class ViewController: NSViewController {
    
    typealias ItemRegistration = NSCollectionView.ItemRegistration<NSCollectionViewItem, CollectionItem>
    typealias DataSource = CollectionViewDiffableDataSource<Section, CollectionItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, CollectionItem>
    
    lazy var itemRegistration: ItemRegistration = {
        var itemRegistration = ItemRegistration(handler: {item, indexPath, collectionItem in
            var configuration = NSItemContentConfiguration()
            configuration.text = collectionItem.title
            configuration.secondaryText = collectionItem.detail
            configuration.image = NSImage(named: collectionItem.imageName)
            configuration.contentProperties.shadow = .black()
            item.contentConfiguration = configuration

            let hostingConfiguration = NSHostingConfiguration {
                CollectionItemView(collectionItem, state: item.configurationState)
            }.margins(.all, .init(10))
          //  item.contentConfiguration = hostingConfiguration
            item.configurationUpdateHandler = { [weak self] item, state in
                let hostingConfiguration = NSHostingConfiguration {
                    CollectionItemView(collectionItem, state: state)
                }.margins(.all, .init(10))
             //   item.contentConfiguration = hostingConfiguration
                
                configuration.contentProperties.scaleTransform = state.isHovered ? 1.03 : 1.0
                configuration.contentProperties.overlayView = state.isHovered ? NSView(color: .white.withAlphaComponent(0.25)) : nil
                
                configuration.contentProperties.borderColor =  state.isSelected ? .controlAccentColor : nil
                configuration.contentProperties.borderWidth = state.isSelected ? 2.0 : 0.0
                configuration.contentProperties.shadow = state.isSelected ? .colored(.controlAccentColor) : .black()

                item.contentConfiguration = configuration
                
            }
        })
        return itemRegistration
    }()
    
    lazy var dataSource: DataSource = {
        DataSource(collectionView: self.collectionView, itemRegistration: itemRegistration)
    }()

    @IBOutlet weak var collectionView: NSCollectionView!
    var items: [CollectionItem] = CollectionItem.sample
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.collectionViewLayout = NSCollectionViewCompositionalLayout.grid(columns: 2, insets: .init(6.0))
        collectionView.dataSource = self.dataSource
        
        applySnapshot()
        collectionView.selectItems(at: .init([IndexPath(item: 0, section: 0)]), scrollPosition: .top)
        
    }
    
    override func viewDidAppear() {
        for subview in self.collectionView.subviews {
            Swift.print(subview)
        }
    }
    
    func applySnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
