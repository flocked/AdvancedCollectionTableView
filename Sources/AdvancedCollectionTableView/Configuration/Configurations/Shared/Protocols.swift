//
//  AutomaticHeightSizable.swift
//
//
//  Created by Florian Zand on 20.07.24.
//

import AppKit
import FZUIKit

/// Content configurations with views that can autolayout their height.
protocol AutomaticHeightSizable: NSContentConfiguration { }

extension NSListContentConfiguration: AutomaticHeightSizable { }
extension NSHostingConfiguration: AutomaticHeightSizable { }

/// Content configuration views with editable text fields.
protocol EditingContentView: NSView { }
