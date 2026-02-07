//
//  TableCollectionObserverView.swift
//
//
//  Created by Florian Zand on 25.01.25.
//

import AppKit
import FZSwiftUtils
import FZUIKit

class TableCollectionObserverView: NSView {
    var tokens: [NotificationToken] = []
    lazy var trackingArea = TrackingArea(for: self, options: [.mouseMoved, .mouseEnteredAndExited, .activeInKeyWindow])
    weak var collectionView: NSCollectionView?
    weak var tableView: NSTableView?
    var focusObservation: KeyValueObservation?
    var isEnabledObservation: KeyValueObservation?
    var appearanceObservation: KeyValueObservation?

    var isFocused = false {
        didSet {
            guard oldValue != isFocused else { return }
            collectionView?.visibleItems().forEach { $0.setNeedsAutomaticUpdateConfiguration() }
            tableView?.visibleRows().forEach { $0.setNeedsAutomaticUpdateConfiguration() }
        }
    }
    
    weak var editingView: NSView? {
        didSet {
            guard oldValue != editingView else { return }
            if collectionView != nil {
                (oldValue?.firstSuperview(where: { $0.parentController is NSCollectionViewItem })?.parentController as? NSCollectionViewItem)?.setNeedsAutomaticUpdateConfiguration()
                (editingView?.firstSuperview(where: { $0.parentController is NSCollectionViewItem })?.parentController as? NSCollectionViewItem)?.setNeedsAutomaticUpdateConfiguration()
            } else {
                oldValue?.firstSuperview(for: NSTableRowView.self)?.setNeedsAutomaticUpdateConfiguration()
                editingView?.firstSuperview(for: NSTableRowView.self)?.setNeedsAutomaticUpdateConfiguration()
            }
        }
    }
    
    init(for collectionView: NSCollectionView) {
        super.init(frame: .zero)
        self.collectionView = collectionView
        initialSetup(for: collectionView)
    }
    
    init(for tableView: NSTableView) {
        super.init(frame: .zero)
        self.tableView = tableView
        initialSetup(for: tableView)
        isEnabledObservation = tableView.observeChanges(for: \.isEnabled) { [weak self] old, new in
            guard let self = self, old != new else { return }
            self.tableView?.visibleRows().forEach { $0.setNeedsAutomaticUpdateConfiguration() }
        }
    }
    
    func initialSetup(for view: NSView) {
        view.addSubview(withConstraint: self)
        zPosition = -CGFloat.greatestFiniteMagnitude
        isFocused = view.isDescendantFirstResponder
        sendToBack()
        updateTrackingAreas()
        appearanceObservation = observeChanges(for: \.effectiveAppearance) { [weak self] oldValue, newValue in
            guard let self = self else { return }
            self.tableView?.visibleRows().forEach { $0.setNeedsAutomaticUpdateConfiguration() }
            self.collectionView?.visibleItems().forEach { $0.setNeedsAutomaticUpdateConfiguration() }
        }
        focusObservation = observeChanges(for: \.window?.firstResponder) { [weak self] oldValue, newValue in
            guard let self = self, let _view = self.collectionView ?? self.tableView else { return }
            if let view = (newValue as? NSView ?? (newValue as? NSText)?.delegate as? NSView), view.isDescendant(of: _view) {
                self.isFocused = true
                self.editingView = (view as? EditiableView)?.isEditable == true ? view : nil
            } else {
                self.isFocused = false
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        trackingArea.update()
    }
    
    override func mouseEntered(with event: NSEvent) {
        updateHovered(for: event)
    }
    
    override func mouseMoved(with event: NSEvent) {
        updateHovered(for: event)
    }
    
    override func mouseExited(with event: NSEvent) {
        collectionView?.hoveredIndexPath = nil
        tableView?.hoveredRow = -1
    }
    
    func updateHovered(for event: NSEvent) {
        if let collectionView = collectionView {
            let location = event.location(in: collectionView)
            collectionView.hoveredIndexPath = collectionView.indexPathForItem(at: location)
            if let item = collectionView.hoveredItem {
                if let view = item.view as? NSItemContentView {
                    item.isHovered = view.isHovering(at: collectionView.convert(location, to: view))
                } else {
                    item.isHovered = true
                }
            }
        } else if let tableView = tableView {
            tableView.hoveredRow = tableView.row(at: event.location(in: tableView))
        }
    }
    
    override func hitTest(_ point: NSPoint) -> NSView? {
        return nil
    }
    
    func _removeFromSuperview() {
        super.removeFromSuperview()
    }
    
    override func removeFromSuperview() { }
    
    override func viewWillMove(toWindow newWindow: NSWindow?) {
        tokens = []
        guard let newWindow = newWindow else { return }
        tokens = [NotificationCenter.default.observe(NSWindow.didBecomeKeyNotification, postedBy: newWindow) { [weak self] _ in
            guard let self = self else { return }
            self.collectionView?.visibleItems().forEach { $0.setNeedsAutomaticUpdateConfiguration() }
            self.tableView?.visibleRows().forEach { $0.setNeedsAutomaticUpdateConfiguration() }
        }, NotificationCenter.default.observe(NSWindow.didResignKeyNotification, postedBy: newWindow) { [weak self] _ in
            guard let self = self else { return }
            self.collectionView?.hoveredIndexPath = nil
            self.collectionView?.visibleItems().forEach { $0.setNeedsAutomaticUpdateConfiguration() }
            self.tableView?.hoveredRow = -1
            self.tableView?.visibleRows().forEach { $0.setNeedsAutomaticUpdateConfiguration() }
        }]
    }
}
