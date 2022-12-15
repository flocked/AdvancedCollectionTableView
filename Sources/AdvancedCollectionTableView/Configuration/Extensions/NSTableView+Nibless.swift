//
//  NSTableView+.swift
//  NSTableViewRegister
//
//  Created by Florian Zand on 10.12.22.
//

import AppKit

public extension NSTableView {
    /**
     Registers a class to use when creating new cells in the table view.
     
     Use this method to register the classes that represent cells in your table view. When you request an cell using the makeView(withIdentifier:owner:) method, the table view recycles an existing cell with the same identifier or creates a new one by instantiating your class.
     
     Use this method to associate one of the NIB's cell views with identifier so that the table can instantiate this view when requested. This method is used when makeView(withIdentifier:owner:) is called, and there was no NIB created at design time for the specified identifier. This allows dynamic loading of NIBs that can be associated with the table.
     Because a NIB can contain multiple views, you can associate the same NIB with multiple identifiers. To remove a previously associated NIB for identifier, pass in nil for the nib value.
     
     - Parameters:
        - cellClass: A class to use for creating cell. Specify nil to unregister a previously registered class.
        - identifier: The string that identifies the type of cell. You use this string later when requesting a cell and it must be unique among the other registered cell classes of this table view. This parameter must not be an empty string or nil.
     */
    func register(_ cellClass: NSTableCellView.Type, forIdentifier identifier: NSUserInterfaceItemIdentifier) {
        NSTableView.swizzle()
        var registeredCellsByIdentifier = self.registeredCellsByIdentifier ?? [:]
        registeredCellsByIdentifier[identifier] = cellClass
        self.registeredCellsByIdentifier = registeredCellsByIdentifier
    }
    
    /**
     The dictionary of all registered cells for view-based table view identifiers.
     
     Each key in the dictionary is the identifier string (given by NSUserInterfaceItemIdentifier) used to register the cell view in the register(_:forIdentifier:) method. The value of each key is the corresponding NSTableCellView class.
     */
    internal (set) var registeredCellsByIdentifier: [NSUserInterfaceItemIdentifier : NSTableCellView.Type]?   {
        get { getAssociatedValue(key: "_registeredCellsByIdentifier", object: self) }
        set { set(associatedValue: newValue, key: "_registeredCellsByIdentifier", object: self) }
    }
    
    @objc internal func swizzled_register(_ nib: NSNib?, forIdentifier identifier: NSUserInterfaceItemIdentifier) {
        if nib == nil, var registeredCellsByIdentifier = registeredCellsByIdentifier, registeredCellsByIdentifier[identifier] != nil {
            registeredCellsByIdentifier[identifier] = nil
            self.registeredCellsByIdentifier = registeredCellsByIdentifier
        } else {
            self.swizzled_register(nib, forIdentifier: identifier)
        }
    }
        
    @objc internal func swizzled_makeView(withIdentifier identifier: NSUserInterfaceItemIdentifier, owner: Any?) -> NSView? {
        if let registeredCellClass = self.registeredCellsByIdentifier?[identifier] {
            if let tableCellView = self.swizzled_makeView(withIdentifier: identifier, owner: owner) {
                return tableCellView
            } else {
                let tableCellView = registeredCellClass.init(frame: .zero)
                tableCellView.identifier = identifier
                return tableCellView
            }
        }
        return self.swizzled_makeView(withIdentifier: identifier, owner: owner)
    }
    
    static internal var didSwizzle: Bool {
        get { getAssociatedValue(key: "_didSwizzle", object: self, initialValue: false) }
        set { set(associatedValue: newValue, key: "_didSwizzle", object: self) }
    }
    
    @objc static internal func swizzle() {
        if (didSwizzle == false) {
            didSwizzle = true
            let registerSelector = #selector((self.register(_:forIdentifier:)) as (NSTableView) -> (NSNib?, NSUserInterfaceItemIdentifier) -> Void)
            Swizzle(NSTableView.self) {
                #selector(self.makeView(withIdentifier:owner:)) <-> #selector(self.swizzled_makeView(withIdentifier:owner:))
                registerSelector <-> #selector(self.swizzled_register(_:forIdentifier:))
            }
        }
    }
}
