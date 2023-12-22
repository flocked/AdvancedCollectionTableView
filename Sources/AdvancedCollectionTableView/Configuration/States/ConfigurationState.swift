//
//  ConfigurationState.swift
//  
//
//  Created by Florian Zand on 12.10.23.
//

import Foundation
import FZUIKit

protocol ConfigurationState: NSConfigurationState {
    var isSelected: Bool { get }
    var isEmphasized: Bool { get }
    var isHovered: Bool { get }
}

extension NSItemConfigurationState: ConfigurationState { }
extension NSTableCellConfigurationState: ConfigurationState { }
extension NSTableRowConfigurationState: ConfigurationState { }
