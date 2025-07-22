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
    fileprivate var boundsSize: CGSize = .zero

    var view: NSView? {
        didSet {
            guard oldValue != view else { return }
            oldValue?.removeFromSuperview()
            if let view = view?.size(bounds.size) {
                addSubview(view)
            }
        }
    }
    
    var configuration: NSContentConfiguration? {
        get { (view as? NSContentView)?.configuration }
        set {
            if let newValue = newValue {
                if let view = view as? NSContentView, view.supports(newValue) {
                    view.configuration = newValue
                } else {
                    view = newValue.makeContentView()
                }
            } else {
                view = nil
            }
        }
    }
    
    public init(view: NSView) {
        super.init(frame: .zero)
        defer { self.view = view }
    }
    
    public init(configuration: NSContentConfiguration) {
        super.init(frame: .zero)
        defer { self.configuration = configuration }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layout() {
        super.layout()
        guard bounds.size != boundsSize else { return }
        boundsSize = bounds.size
        view?.frame.size = bounds.size
    }
}
