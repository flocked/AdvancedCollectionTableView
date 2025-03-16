//
//  TextStackAccessory.swift
//  
//
//  Created by Florian Zand on 16.03.25.
//

import Foundation

struct TextStackAccessory {
    /**
     The leading text.

     This value supersedes the ``attributedLeadingText`` property.
     */
    public var leadingText: String? {
        didSet {
            guard leadingText != nil else { return }
            attributedLeadingText = nil
        }
    }

    /**
     An attributed variant of the leading text.

     This value supersedes the ``leadingText`` property.
     */
    public var attributedLeadingText: AttributedString? {
        didSet {
            guard attributedLeadingText != nil else { return }
            leadingText = nil
        }
    }

    /**
     The leading placeholder text.

     This value supersedes the ``attributedPlaceholderLeadingText`` property.
     */
    public var placeholderLeadingText: String? {
        didSet {
            guard placeholderLeadingText != nil else { return }
            attributedPlaceholderLeadingText = nil
        }
    }

    /**
     An attributed variant of the leading placeholder text.

     This value supersedes the ``placeholderLeadingText`` property.
     */
    public var attributedPlaceholderLeadingText: AttributedString? {
        didSet {
            guard attributedPlaceholderLeadingText != nil else { return }
            placeholderLeadingText = nil
        }
    }
    
    /**
     The trailing text.

     This value supersedes the ``attributedTrailingText`` property.
     */
    public var trailingText: String? {
        didSet {
            guard trailingText != nil else { return }
            attributedTrailingText = nil
        }
    }

    /**
     An attributed variant of the trailing text.

     This value supersedes the ``trailingText`` property.
     */
    public var attributedTrailingText: AttributedString? {
        didSet {
            guard attributedLeadingText != nil else { return }
            trailingText = nil
        }
    }

    /**
     The trailing placeholder text.

     This value supersedes the ``attributedPlaceholderTrailingText`` property.
     */
    public var placeholderTrailingText: String? {
        didSet {
            guard placeholderLeadingText != nil else { return }
            attributedPlaceholderTrailingText = nil
        }
    }

    /**
     An attributed variant of the trailing placeholder text.

     This value supersedes the ``placeholderTrailingText`` property.
     */
    public var attributedPlaceholderTrailingText: AttributedString? {
        didSet {
            guard attributedPlaceholderTrailingText != nil else { return }
            placeholderTrailingText = nil
        }
    }
    
    
    /// Properties for configuring the primary text.
    public var leadingTextProperties: TextProperties = .primary
    
    /// Properties for configuring the primary text.
    public var trailingTextProperties: TextProperties = .primary
    
    /// The spacing between the leading and trailing text.
    public var leadingToTrailingTextSpacing: CGFloat = 4.0
    
    var trailingText: String?
}
