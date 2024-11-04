//
//  EmptyView.swift
//
//
//  Created by Florian Zand on 25.10.24.
//

import AppKit
import FZUIKit

/// View that is displayed if a table or collection view is empty.
class EmptyView: NSView {
        
    var contentView: (NSView & NSContentView)?
    var view: NSView? {
        didSet {
            guard oldValue != view else { return }
            if let view = view {
                contentView?.removeFromSuperview()
                contentView = nil
                view.frame.size = bounds.size
                addSubview(view)
            }
        }
    }
    
    public var configuration: NSContentConfiguration? {
        get { contentView?.configuration }
        set {
            if let newValue = newValue {
                view?.removeFromSuperview()
                view = nil
                if contentView?.supports(newValue) == true {
                    contentView?.configuration = newValue
                } else {
                    contentView?.removeFromSuperview()
                    contentView = newValue.makeContentView()
                    contentView?.frame.size = bounds.size
                    addSubview(contentView!)
                }
            }
        }
    }
    
    public init(view: NSView) {
        self.view = view
        super.init(frame: .zero)
        addSubview(view)
    }
    
    public init(configuration: NSContentConfiguration) {
        self.contentView = configuration.makeContentView()
        super.init(frame: .zero)
        addSubview(contentView!)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layout() {
        super.layout()
        contentView?.frame.size = bounds.size
        view?.frame.size = bounds.size
    }
}
