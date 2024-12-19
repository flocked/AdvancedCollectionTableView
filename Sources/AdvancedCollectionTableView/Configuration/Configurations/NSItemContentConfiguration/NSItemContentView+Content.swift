//
//  NSItemContentView+Content.swift
//
//
//  Created by Florian Zand on 07.08.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit

extension NSItemContentView {
    class ItemContentView: NSView {
        var configuration: NSItemContentConfiguration {
            didSet {
                guard oldValue != configuration else { return }
                updateConfiguration()
            }
        }

        var contentProperties: NSItemContentConfiguration.ContentProperties {
            configuration.contentProperties
        }

        let imageView: ImageView = .init()
        let containerView = NSView(frame: .zero)
        var badgeViews: [BadgeView] = []
        
        var previousSize: CGSize = .zero
        var centerYConstraint: NSLayoutConstraint?
        var intrinsicSize = CGSize(NSView.noIntrinsicMetric, NSView.noIntrinsicMetric)
        var _scaleTransform: Scale = .none
        var _rotation: Rotation = .zero

        var view: NSView? {
            didSet {
                guard oldValue != view else { return }
                oldValue?.removeFromSuperview()
                if let newView = view {
                    newView.frame.size = bounds.size
                    newView.clipsToBounds = true
                    containerView.addSubview(newView)
                    overlayView?.sendToFront()
                }
            }
        }

        var overlayView: NSView? {
            didSet {
                guard oldValue != overlayView else { return }
                oldValue?.removeFromSuperview()
                if let newView = overlayView {
                    newView.clipsToBounds = true
                    newView.frame.size = bounds.size
                    containerView.addSubview(newView)
                }
            }
        }

        var image: NSImage? {
            get { imageView.image }
            set {
                guard newValue != image else { return }
                imageView.image = newValue
                imageView.isHidden = newValue == nil
            }
        }

        func updateBadges() {
            let badges = configuration.badges.filter(\.isVisible).sorted(by: \.position.rawValue)
            if configuration.hasContent {
                let badgeViewsNeeded = badges.count - badgeViews.count
                if badgeViewsNeeded > 0 {
                    for i in 0 ..< badgeViewsNeeded {
                        let badgeView = BadgeView(properties: badges[i])
                        badgeViews.append(badgeView)
                        addSubview(badgeView)
                    }
                } else if badgeViewsNeeded < 0 {
                    for _ in 0 ..< -badgeViewsNeeded {
                        badgeViews.last?.removeFromSuperview()
                        badgeViews.removeLast()
                    }
                }
                guard badges.count == badgeViews.count else { return }
                for (index, badgeView) in badgeViews.sorted(by: \.properties.position.rawValue).enumerated() {
                    var badge = badges[index]
                    badge.maxWidth = min(badge.maxWidth ?? bounds.width, bounds.width)
                    badgeView.properties = badge
                    badgeView.layoutBadge()
                }
            } else {
                badgeViews.forEach { $0.removeFromSuperview() }
                badgeViews.removeAll()
            }
        }

        override func layout() {
            super.layout()
            guard previousSize != bounds.size else { return }
            previousSize = bounds.size
            invalidateIntrinsicContentSize()
            containerView.frame.size = bounds.size
            imageView.frame.size = bounds.size
            view?.frame.size = bounds.size
            overlayView?.frame.size = bounds.size
            /*
             if let imageSize = image?.size, contentProperties.imageScaling.shouldResize {
             var size = frame.size
             if let superviewWidth = superview?.frame.size.width {
             size.width = superviewWidth - configuration.margins.width
             }
             var newIntrinsicSize = CGSize(NSView.noIntrinsicMetric, NSView.noIntrinsicMetric)
             switch (contentProperties.maxWidth, contentProperties.maxHeight) {
             case (.some(let maxWidth), .some(let maxHeight)):
             let width = min(maxWidth, size.width)
             let height = min(maxHeight, size.height)
             let imagesize = imageSize.scaled(toFit: CGSize(width, height))
             newIntrinsicSize.width = imagesize.width
             newIntrinsicSize.height =  imagesize.height
             case (.some(let maxWidth), nil):
             let imagesize = imageSize.scaled(toWidth: min(maxWidth, size.width))
             newIntrinsicSize.width = imagesize.width
             newIntrinsicSize.height = imagesize.height
             case (nil, .some(let maxHeight)):
             let imagesize = imageSize.scaled(toHeight: min(maxHeight, size.height))
             Swift.debugPrint("maxHeight", frame.size, imagesize)
             newIntrinsicSize.width = imagesize.width
             newIntrinsicSize.height = imagesize.height
             case (nil, nil):
             let imagesize = imageSize.scaled(toFit: size)
             newIntrinsicSize.width = imagesize.width
             }
             if newIntrinsicSize != intrinsicSize {
             intrinsicSize = newIntrinsicSize
             Swift.debugPrint("invalidateIntrinsicContentSize", intrinsicSize)
             invalidateIntrinsicContentSize()
             }
             } else {
             intrinsicSize = CGSize(NSView.noIntrinsicMetric, NSView.noIntrinsicMetric)
             var size = frame.size
             if let superviewWidth = superview?.frame.size.width {
             size.width = superviewWidth - configuration.margins.width
             }

             if let maxWidth = contentProperties.maxWidth, size.width > maxWidth {
             intrinsicSize.width = maxWidth
             }

             /*
              var newWidth: CGFloat? = nil
              var newHeight: CGFloat? = nil
              if let maxWidth = contentProperties.maxWidth, size.width > maxWidth {
              newWidth = maxWidth
              }

              if let maxHeight = contentProperties.maxHeight, size.height > maxHeight {
              newHeight = maxHeight
              }

              if newWidth != width || newHeight != height {
              width = newWidth
              height = newHeight
              Swift.debugPrint("invalidateIntrinsicContentSize", height ?? "")
              invalidateIntrinsicContentSize()
              }
              */
             Swift.debugPrint("invalidateIntrinsicContentSize", intrinsicSize)
             invalidateIntrinsicContentSize()
             }
             */
        }
        
        override var intrinsicContentSize: NSSize {
            if frame.size == .zero {
                return CGSize(NSView.noIntrinsicMetric, NSView.noIntrinsicMetric)
            }

            var intrinsicContentSize = CGSize(NSView.noIntrinsicMetric, NSView.noIntrinsicMetric)
            var size = frame.size
            if let superviewWidth = superview?.frame.size.width {
                size.width = superviewWidth - configuration.margins.width
            }
            if let imageSize = image?.size, configuration.imageProperties.scaling.shouldResize {
                switch (contentProperties.maximumSize.width, contentProperties.maximumSize.height) {
                case let (.some(maxWidth), .some(maxHeight)):
                    let width = min(maxWidth, size.width)
                    let height = min(maxHeight, size.height)
                    let imagesize = imageSize.scaled(toFit: CGSize(width, height))
                    intrinsicContentSize.width = imagesize.width
                    intrinsicContentSize.height = imagesize.height
                case (.some(let maxWidth), nil):
                    let imagesize = imageSize.scaled(toWidth: min(maxWidth, size.width))
                    intrinsicContentSize.width = imagesize.width
                    intrinsicContentSize.height = imagesize.height
                case (nil, let .some(maxHeight)):
                    let imagesize = imageSize.scaled(toHeight: min(maxHeight, size.height))
                    intrinsicContentSize.width = imagesize.width
                    intrinsicContentSize.height = imagesize.height
                case (nil, nil):
                    let imagesize = imageSize.scaled(toFit: size)
                    intrinsicContentSize.width = imagesize.width
                }
                return intrinsicContentSize
            } else {
                if let imageSize = image?.size, configuration.imageProperties.scaling == .none {
                    if imageSize.width < size.width {
                        intrinsicContentSize.width = imageSize.width
                    }

                    if imageSize.height < size.height {
                        intrinsicContentSize.height = imageSize.height
                    }
                }

                if let maxWidth = contentProperties.maximumSize.width {
                    if intrinsicContentSize.width != -1 {
                        if intrinsicContentSize.width > maxWidth {
                            intrinsicContentSize.width = maxWidth
                        }
                    } else {
                        switch contentProperties.maximumSize.mode {
                        case .absolute:
                            if size.width > maxWidth {
                                intrinsicContentSize.width = maxWidth
                            }
                        case .relative:
                            intrinsicContentSize.width = size.width * maxWidth
                        }
                    }
                }

                if let maxHeight = contentProperties.maximumSize.height {
                    if intrinsicContentSize.height != -1 {
                        if intrinsicContentSize.height > maxHeight {
                            intrinsicContentSize.height = maxHeight
                        }
                    } else {
                        switch contentProperties.maximumSize.mode {
                        case .absolute:
                            if size.height > maxHeight {
                                intrinsicContentSize.height = maxHeight
                            }
                        case .relative:
                            intrinsicContentSize.height = size.height * maxHeight
                        }
                    }
                }

                return intrinsicContentSize
            }
        }

        func updateConfiguration() {
            let isAnimating = NSAnimationContext.hasActiveGrouping && NSAnimationContext.current.duration > 0.0

            animator(isAnimating).backgroundColor = contentProperties.resolvedBackgroundColor()
            visualEffect = contentProperties.visualEffect
            
            containerView.animator(isAnimating).border = contentProperties._resolvedBorder()
            animator(isAnimating).cornerRadius = contentProperties.cornerRadius
            containerView.animator(isAnimating).cornerRadius = contentProperties.cornerRadius

            animator(isAnimating).outerShadow = contentProperties._resolvedShadow()

            if isAnimating, imageView.image != configuration.image || imageView.imageScaling != configuration.imageProperties.scaling.scaling {
                imageView.transition(.fade(duration: NSAnimationContext.current.duration))
            }
            imageView.tintColor = configuration.imageProperties.resolvedTintColor()
            imageView.imageScaling = configuration.imageProperties.scaling.scaling
            imageView.symbolConfiguration = configuration.imageProperties.symbolConfiguration?.nsSymbolConfiguration()
            image = configuration.image
            view = configuration.view
            overlayView = configuration.overlayView
            
            if contentProperties.scaleTransform != _scaleTransform {
                anchorPoint = .center
                _scaleTransform = contentProperties.scaleTransform
                animator(isAnimating).scale = _scaleTransform
            }
            if contentProperties.rotation != _rotation {
                anchorPoint = .center
                _rotation = contentProperties.rotation
                animator(isAnimating).rotation = _rotation
            }
            
            toolTip = contentProperties.toolTip
            animator(isAnimating).isHidden = !configuration.hasContent
            updateBadges()
            
            invalidateIntrinsicContentSize()
        }

        init(configuration: NSItemContentConfiguration) {
            self.configuration = configuration
            super.init(frame: .zero)
            clipsToBounds = false
            containerView.clipsToBounds = true
            addSubview(containerView)
            imageView.clipsToBounds = true
            containerView.addSubview(imageView)
            updateConfiguration()
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension OptionalProtocol where Wrapped == CGFloat {
    var reverse: CGFloat? {
        if let optional = optional {
            return -optional
        }
        return nil
    }
}
