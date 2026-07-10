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
     Registers a view class for use in creating reusable table views.

     After registering a class, call ``AppKit/NSTableView/makeView(for:)`` to dequeue an existing view of that class or create a new instance if no reusable view is available.

     - Parameter viewClass: The view class to register.
     */
    public func register(_ viewClass: NSView.Type) {
        register(viewClass, forIdentifier: .init(viewClass))
    }

    func register(_ viewClass: NSView.Type, forIdentifier identifier: NSUserInterfaceItemIdentifier) {
        swizzleViewRegistration()
        registeredClassesByIdentifier[identifier] = viewClass
        registeredClassesByIdentifier = registeredClassesByIdentifier
    }

    /**
     Returns a new or existing view of the specified class.

     If a reusable view of the requested class is available, the table view returns it. Otherwise, it creates a new instance of the registered class.

     Register the view class beforehand using ``AppKit/NSTableView/register(_:)``.

     When a new view is created, the table view uses its delegate as the owner, allowing outlets and actions to be connected when loading from a nib. Note that [awakeFromNib()](https://developer.apple.com/documentation/objectivec/nsobject-swift.class/awakefromnib()) is called each time this method is called.

     - Parameter viewClass: The class of the view to return.
     - Returns: A reusable view of the specified class, or `nil` if the class hasn't been registered or the view couldn't be created.
     */
    public func makeView<View: NSView>(for viewClass: View.Type) -> View? {
        makeView(for: viewClass, withIdentifier: .init(viewClass))
    }

    private func makeView<View: NSView>(for _: View.Type, withIdentifier identifier: NSUserInterfaceItemIdentifier) -> View? {
        makeView(withIdentifier: identifier, owner: nil) as? View
    }

    var registeredClassesByIdentifier: [NSUserInterfaceItemIdentifier: NSView.Type] {
        get { getAssociatedValue("registeredClassesByIdentifier") ?? [:] }
        set { setAssociatedValue(newValue, key: "registeredClassesByIdentifier") }
    }

    /**
     The view classes currently registered with the table view.

     Register a class using ``AppKit/NSTableView/register(_:)``. When you later request a view using ``AppKit/NSTableView/makeView(for:)``, the table view reuses an existing view of the requested class or creates a new instance if necessary.
     */
    public var registeredClasses: [NSView.Type] {
        registeredClassesByIdentifier.values.map { ($0, ObjectIdentifier($0)) }.uniqued(by: \.1).map(\.0)
    }

    func swizzleViewRegistration() {
        guard viewRegistrationHooks.isEmpty else { return }
        do {
            viewRegistrationHooks += try hook(#selector(NSTableView.makeView(withIdentifier:owner:)), closure: {
                original, tableView, selector, identifier, owner in
                if tableView.isEnablingAutomaticRowHeights {
                    tableView.isEnablingAutomaticRowHeights = false
                    return nil
                }
                if let reconfigureIndexPath = tableView.reconfigureIndexPath {
                    if reconfigureIndexPath.section != -1, let cell = tableView.view(atColumn: reconfigureIndexPath.section, row: reconfigureIndexPath.item, makeIfNecessary: false) {
                        return cell
                    } else if reconfigureIndexPath.section == -1, let rowView = tableView.rowView(atRow: reconfigureIndexPath.item, makeIfNecessary: false) {
                        return rowView
                    }
                }
                if let registeredViewClass = tableView.registeredClassesByIdentifier[identifier] {
                    if let view = original(tableView, selector, identifier, owner) {
                        return view
                    } else {
                        let view = registeredViewClass.init(frame: .zero)
                        view.identifier = identifier
                        return view
                    }
                }
                return original(tableView, selector, identifier, owner)
            } as @convention(block) ((NSTableView, Selector, NSUserInterfaceItemIdentifier, Any?) -> NSView?, NSTableView, Selector, NSUserInterfaceItemIdentifier, Any?) -> NSView?)

            viewRegistrationHooks += try hook(#selector((NSTableView.register(_:forIdentifier:)) as (NSTableView) -> (NSNib?, NSUserInterfaceItemIdentifier) -> ()), closure: {
                original, tableView, selector, nib, identifier in
                if nib == nil {
                    tableView.registeredClassesByIdentifier[identifier] = nil
                }
                original(tableView, selector, nib, identifier)
            } as @convention(block) ((NSTableView, Selector, NSNib?, NSUserInterfaceItemIdentifier) -> (), NSTableView, Selector, NSNib?, NSUserInterfaceItemIdentifier) -> ())
        } catch {
            Swift.print(error)
        }
    }

    fileprivate var viewRegistrationHooks: [Hook] {
        get { getAssociatedValue("viewRegistrationHooks") ?? [] }
        set { setAssociatedValue(newValue, key: "viewRegistrationHooks") }
    }

    @objc var isEnablingAutomaticRowHeights: Bool {
        get { getAssociatedValue("isEnablingAutomaticRowHeights") ?? false }
        set { setAssociatedValue(newValue, key: "isEnablingAutomaticRowHeights") }
    }
}
#endif
