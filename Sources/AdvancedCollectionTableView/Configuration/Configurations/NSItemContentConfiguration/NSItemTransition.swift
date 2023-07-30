//
//  File.swift
//  
//
//  Created by Florian Zand on 29.07.23.
//

import AppKit
import FZUIKit


internal extension NSItemContentConfiguration {
    func animate(with configuration: TransitionConfiguration) {
        guard let view = (self.collectionViewItem?.contentView as? NSItemContentView), let collectionView = self.collectionViewItem?._collectionView else { return }
        var backgroundView: NSView? = nil
        if let backgroundColor = configuration.backgroundColor {
            if let _backgroundView = collectionView.superview?.firstSubview(type: TransitionBackgroundView.self) {
                backgroundView = _backgroundView
                _backgroundView.frame = collectionView.frame
                collectionView.superview?.addSubview(backgroundView!)
            } else {
                backgroundView = TransitionBackgroundView(frame: collectionView.frame)
                backgroundView?.backgroundColor = backgroundColor
                backgroundView?.alphaValue = 0.0
                collectionView.superview?.addSubview(backgroundView!)
            }
        }
        collectionView.superview?.addSubview(view)
        Wave.animate(withSpring: .defaultAnimated, animations: {
            if let alpha = configuration.text.alpha {
                view.textField.animator.alpha = alpha
            }
            if let alpha = configuration.secondaryText.alpha {
                view.secondaryTextField.animator.alpha = alpha
            }
            if let alpha = configuration.content.alpha {
                view.contentView.animator.alpha = alpha
            }
            if let frame = configuration.text.frame {
                view.textField.animator.frame = frame
            }
            if let frame = configuration.secondaryText.frame {
                view.secondaryTextField.animator.frame = frame
            }
            if let frame = configuration.content.frame {
                view.contentView.animator.frame = frame
            }
            backgroundView?.animator.alpha = 1.0
            collectionView.animator.alpha = 0.0
        }, completion: { _,_ in
            configuration.completion?()
            backgroundView?.removeFromSuperview()
        })
    }
    
    struct TransitionConfiguration {
        public struct TransitionItem: Hashable {
            var alpha: CGFloat? = nil
            var frame: CGRect? = nil
        }
        
        public enum AnimationType: Int, Hashable {
            case spring
            case easeInOut
            case easeIn
            case easeOut
            case linear
        }
        
        var text: TransitionItem = TransitionItem()
        var secondaryText: TransitionItem = TransitionItem()
        var content: TransitionItem = TransitionItem()
        
        var backgroundColor: NSColor? = nil
        var fading: Bool = true
        var animationTime: CGFloat = 0.1
        var animationType: AnimationType = .spring
        var completion: (()->())? = nil
    }
    
     class TransitionBackgroundView: NSView {
        override var tag: Int {
            return 34576542
        }
    }
}


