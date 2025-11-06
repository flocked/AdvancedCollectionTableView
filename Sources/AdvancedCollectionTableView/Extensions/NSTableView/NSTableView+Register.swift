//
//  NSTableView+Register.swift
//
//
//  Created by Florian Zand on 22.07.25.
//

#if os(macOS)

import AppKit
import FZSwiftUtils

extension NSTableView {
    /**
     Registers a view class for the specified identifier, so that view-based table views can use it to instantiate views.

     Use this method to associate the view class with the specified identifier. When you request a view using ``AppKit/NSTableView/makeView(for:)``, the table view recycles an existing view with the same class or creates a new one by instantiating your class.
     
     - Parameter viewClass: The  view class to register.
     */
    public func register(_ viewClass: NSView.Type) {
        register(viewClass, forIdentifier: .init(viewClass))
    }

    func register(_ viewClass: NSView.Type, forIdentifier identifier: NSUserInterfaceItemIdentifier) {
        Self.swizzleViewRegistration()
        registeredClassesByIdentifier[identifier] = viewClass
        registeredClassesByIdentifier = registeredClassesByIdentifier
    }

    /**
     Returns a new or existing view with the specified view class.

     To be able to create a reusable view using this method, you have to register it first via ``AppKit/NSTableView/register(_:)``.

     When this method is called, the table view automatically instantiates the cell view with the specified owner, which is usually the table view’s delegate. (The owner is useful in setting up outlets and target/actions from the view.).

     This method may return a reused view with the same class that is no longer available on screen.

     Note that `awakeFromNib()` is called each time this method is called.

     - Parameter viewClass: The class of the view.

     - Returns:The view, or `nil` if the view class isn't registered or the view couldn't be created.
     */
    public func makeView<View: NSView>(for viewClass: View.Type) -> View? {
        makeView(for: viewClass, withIdentifier: .init(viewClass))
    }

    func makeView<View: NSView>(for _: View.Type, withIdentifier identifier: NSUserInterfaceItemIdentifier) -> View? {
        makeView(withIdentifier: identifier, owner: nil) as? View
    }
    
    /**
     The dictionary of all registered classes for view-based table view identifiers.
     
     Each key in the dictionary is the identifier used to register the view class in the ``AppKit/NSTableView/register(_:)``. The value of each key is the corresponding view class.
     */
    @objc public private(set) var registeredClassesByIdentifier: [NSUserInterfaceItemIdentifier: NSView.Type] {
        get { getAssociatedValue("registeredClassesByIdentifier", initialValue: [:]) }
        set { setAssociatedValue(newValue, key: "registeredClassesByIdentifier") }
    }

    @objc fileprivate func swizzled_register(_ nib: NSNib?, forIdentifier identifier: NSUserInterfaceItemIdentifier) {
        if nib == nil {
            registeredClassesByIdentifier[identifier] = nil
        }
        swizzled_register(nib, forIdentifier: identifier)
    }

    @objc fileprivate func swizzled_makeView(withIdentifier identifier: NSUserInterfaceItemIdentifier, owner: Any?) -> NSView? {
        if isEnablingAutomaticRowHeights {
            isEnablingAutomaticRowHeights = false
            return nil
        }
        if let reconfigureIndexPath = reconfigureIndexPath {
            if reconfigureIndexPath.section != -1, let cell = view(atColumn: reconfigureIndexPath.section, row: reconfigureIndexPath.item, makeIfNecessary: false) {
                return cell
            } else if reconfigureIndexPath.section == -1, let rowView = rowView(atRow: reconfigureIndexPath.item, makeIfNecessary: false) {
                return rowView
            }
        }
        if let registeredViewClass = registeredClassesByIdentifier[identifier] {
            if let view = swizzled_makeView(withIdentifier: identifier, owner: owner) {
                return view
            } else {
                let view = registeredViewClass.init(frame: .zero)
                view.identifier = identifier
                return view
            }
        }
        let view = swizzled_makeView(withIdentifier: identifier, owner: owner)
        return view
    }

    static func swizzleViewRegistration() {
        guard !didSwizzleViewRegistration else { return }
        do {
            try NSTableView.swizzle {
                #selector(makeView(withIdentifier:owner:)) <-> #selector(swizzled_makeView(withIdentifier:owner:))
                #selector((register(_:forIdentifier:)) as (NSTableView) -> (NSNib?, NSUserInterfaceItemIdentifier) -> Void) <-> #selector(swizzled_register(_:forIdentifier:))
            }
            didSwizzleViewRegistration = true
        } catch {
            Swift.debugPrint(error)
        }
    }
    
    fileprivate static var didSwizzleViewRegistration: Bool {
        get { getAssociatedValue("didSwizzleViewRegistration") ?? false }
        set { setAssociatedValue(newValue, key: "didSwizzleViewRegistration") }
    }
    
    @objc var isEnablingAutomaticRowHeights: Bool {
        get { getAssociatedValue("isEnablingAutomaticRowHeights") ?? false }
        set { setAssociatedValue(newValue, key: "isEnablingAutomaticRowHeights") }
    }
    
    @objc fileprivate static var shouldSwizzleViewRegistration: Bool {
        get { didSwizzleViewRegistration }
        set { swizzleViewRegistration() }
    }
}
#endif
