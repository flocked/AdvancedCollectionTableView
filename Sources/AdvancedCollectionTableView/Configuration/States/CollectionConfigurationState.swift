//
//  CollectionConfigurationState.swift
//  
//
//  Created by Florian Zand on 12.10.23.
//

import Foundation

internal protocol CollectionConfigurationState {
    var isSelected: Bool { get }
    var isEmphasized: Bool { get }
    var isHovered: Bool { get }
}

extension NSItemConfigurationState: CollectionConfigurationState { }
extension NSTableCellConfigurationState: CollectionConfigurationState { }
extension NSTableRowConfigurationState: CollectionConfigurationState { }
