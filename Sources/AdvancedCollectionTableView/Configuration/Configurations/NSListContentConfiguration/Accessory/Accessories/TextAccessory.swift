//
//  TextAccessory.swift
//  
//
//  Created by Florian Zand on 16.03.25.
//

import Foundation

struct TextAccessory {
    /**
     The text.

     This value supersedes the ``attributedText`` property.
     */
    public var text: String? {
        didSet {
            guard text != nil else { return }
            attributedText = nil
        }
    }

    /**
     An attributed variant of the text.

     This value supersedes the ``text`` property.
     */
    public var attributedText: AttributedString? {
        didSet {
            guard attributedText != nil else { return }
            text = nil
        }
    }

    /**
     The placeholder text.

     This value supersedes the ``attributedPlaceholderText`` property.
     */
    public var placeholderText: String? {
        didSet {
            guard placeholderText != nil else { return }
            attributedPlaceholderText = nil
        }
    }

    /**
     An attributed variant of the placeholder text.

     This value supersedes the ``placeholderText`` property.
     */
    public var attributedPlaceholderText: AttributedString? {
        didSet {
            guard attributedPlaceholderText != nil else { return }
            placeholderText = nil
        }
    }
    
    /// Properties for configuring the primary text.
    public var textProperties: TextProperties = .primary
}
