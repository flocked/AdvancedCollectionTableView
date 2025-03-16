//
//  NSPasteboardItem+.swift
//
//
//  Created by Florian Zand on 16.03.25.
//

import AppKit
import FZUIKit


extension NSPasteboardItem {
    convenience init<Element: Identifiable & Hashable>(for element: Element, content: [PasteboardWriting]? = nil) {
        self.init(content: content ?? [])
        setString(String(element.id.hashValue), forType: .itemID)
    }
    
    convenience init<Item: Hashable>(forItem item: Item, content: [PasteboardWriting]? = nil) {
        self.init(content: content ?? [])
        setString(String(describing: item), forType: .itemID)
    }
}
