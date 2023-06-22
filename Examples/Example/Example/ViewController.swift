//
//  ViewController.swift
//  
//
//  Created by Florian Zand on 19.01.23.
//

import AppKit
import AdvancedCollectionTableView

class ViewController: NSViewController {
    
    typealias ItemRegistration = NSCollectionView.ItemRegistration<NSCollectionViewItem, CollectionItem>
    typealias DataSource = CollectionViewDiffableDataSource<Section, CollectionItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, CollectionItem>
    
    lazy var itemRegistration: ItemRegistration = {
        var itemRegistration = ItemRegistration(handler: {item, indexPath, collectionItem in
            let hostingConfiguration = NSHostingConfiguration {
                CollectionItemView(collectionItem, state: item.configurationState)
            }.margins(.all, .init(10))
            item.contentConfiguration = hostingConfiguration
            item.configurationUpdateHandler = { [weak self] item, state in
                if state.isHovered == true {
                    Swift.print(state.isHovered)
                }
                let hostingConfiguration = NSHostingConfiguration {
                    CollectionItemView(collectionItem, state: state)
                }.margins(.all, .init(10))
                item.contentConfiguration = hostingConfiguration
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
