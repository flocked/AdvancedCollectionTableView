//
//  TableRowContentConfiguration.swift
//  NSTableViewRegister
//
//  Created by Florian Zand on 14.12.22.
//

import AppKit
import FZSwiftUtils
import FZUIKit
/**
 A content configuration for a table row-based content view.
 
 A table row content configuration describes the styling and content for an individual element that might appear in a list, like a row. Using a row content configuration, you can obtain system default styling for a variety of different view states. You fill the configuration with your content, and then assign it directly to rows in NSTableView, or to your own custom row content view (NSContentView).
 
 For views like rows (NSTableRowView) use their defaultContentConfiguration() to get a list content configuration that has preconfigured default styling. Alternatively, you can create a row content configuration from one of the system default styles. After you get the configuration, you assign your content to it, customize any other properties, and assign it to your view as the current content configuration.
 
 ```
 var content = rowView.defaultContentConfiguration()

 // Configure content.
 content.backgroundColor = .controlAccentColor
 content.cornerRadius = 4.0

 rowView.contentConfiguration = content
 ```
 */
public struct NSTableRowContentConfiguration: NSContentConfiguration, Hashable {
    /// The background color.
    var backgroundColor: NSColor? = nil
    /// The color transformer of the background color.
    public var backgroundColorTansform: NSConfigurationColorTransformer? = nil
    /// Generates the resolved background color for the specified background color, using the color and color transformer.
    public func resolvedBackgroundColor() -> NSColor? {
        if let backgroundColor = self.backgroundColor {
            return backgroundColorTansform?(backgroundColor) ?? backgroundColor
        }
        return nil
    }
    /// The corner radius.
    var cornerRadius: CGFloat = 0.0
    /// The background view.
    var backgroundView: NSView? = nil
    
    /**
     The margins between the content and the edges of the content view.
     */
    var autoAdjustRowSize: Bool = false
    
    var backgroundPadding: NSDirectionalEdgeInsets = .zero
    
    internal var roundedCorners: CACornerMask = .all
    
    /**
     Properties for configuring the seperator.
     */
    var seperatorProperties: SeperatorProperties = .default()
    
    internal var tableViewStyle: NSTableView.Style? = nil
    
    
    public static func `default`() -> NSTableRowContentConfiguration {
        return.automatic()
    }
    
    public static func style(_ style: NSTableView.Style) -> NSTableRowContentConfiguration {
        switch style {
        case .automatic:
            return .automatic()
        case .fullWidth:
            return .fullWidth()
        case .inset:
            return .inset()
        case .sourceList:
            return .sourceList()
        case .plain:
            return .plain()
        @unknown default:
            return .automatic()
        }
    }
    
    public static func automatic() -> NSTableRowContentConfiguration {
        var configuration = NSTableRowContentConfiguration()
        configuration.tableViewStyle = .automatic
        return configuration
    }
    
    public static func fullWidth() -> NSTableRowContentConfiguration {
        var configuration = NSTableRowContentConfiguration()
        configuration.tableViewStyle = .fullWidth
        configuration.backgroundPadding = .zero
        configuration.cornerRadius = 0.0
        return configuration
    }
    
    public static func sourceList() -> NSTableRowContentConfiguration {
        var configuration = NSTableRowContentConfiguration()
        configuration.tableViewStyle = .sourceList
        configuration.backgroundPadding = .init(top: 4.0, leading: 4.0, bottom: 4.0, trailing: 4.0)
        configuration.cornerRadius = 4.0
        return configuration
    }
    
    public static func plain() -> NSTableRowContentConfiguration {
        var configuration = NSTableRowContentConfiguration()
        configuration.tableViewStyle = .plain
        return configuration
    }

    public static func inset() -> NSTableRowContentConfiguration {
        var configuration = NSTableRowContentConfiguration()
        configuration.tableViewStyle = .inset
        return configuration
    }
    
    // Creates a new instance of the content view using the configuration.
    public func makeContentView() -> NSView & NSContentView {
        let contentView = ContentView(configuration: self)
        return contentView
    }
    
    /**
     Generates a configuration for the specified state by applying the configuration’s default values for that state to any properties that you don’t customize.
     */
    public func updated(for state: NSConfigurationState) -> Self {
        var configuration = self
        if let state = state as? NSTableRowConfigurationState {
            configuration.roundedCorners = []
            if (state.isPreviousRowSelected == false) {
                configuration.roundedCorners.insert(.topLeft)
                configuration.roundedCorners.insert(.topRight)
            }
            if (state.isNextRowSelected == false) {
                configuration.roundedCorners.insert(.bottomLeft)
                configuration.roundedCorners.insert(.bottomRight)
            }
            if (state.isSelected) {
                configuration.backgroundColor = .controlAccentColor
            } else {
                configuration.backgroundColor = nil
            }
        }
        return configuration
    }
}

public extension NSTableRowContentConfiguration {
    struct SeperatorProperties: Hashable {
        var color: NSColor = .separatorColor
        var colorTransform: NSConfigurationColorTransformer? = nil
        var height: CGFloat = 1.0
        var insets: NSDirectionalEdgeInsets = .init(top: 0, leading: 4.0, bottom: 0, trailing: 4.0)

        func resolvedColor() -> NSColor? {
            return self.colorTransform?(color) ?? color
        }
        
        static func `default`() -> SeperatorProperties {
            return SeperatorProperties()
        }
    }
}
