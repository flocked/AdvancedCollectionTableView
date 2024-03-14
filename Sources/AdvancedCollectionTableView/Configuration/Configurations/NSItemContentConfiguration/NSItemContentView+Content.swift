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
        typealias Badge = NSItemContentConfiguration.Badge
        var configuration: NSItemContentConfiguration {
            didSet { if oldValue != configuration {
                updateConfiguration()
            } }
        }

        var contentProperties: NSItemContentConfiguration.ContentProperties {
            configuration.contentProperties
        }

        let imageView: ImageView = .init()
        let containerView = NSView(frame: .zero)
        var badgeViews: [BadgeView] = []

        var view: NSView? {
            didSet {
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
                    newView.cornerRadius = contentProperties.cornerRadius
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
            let badges = configuration.badges.filter(\.isVisible)
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
                for value in zip(badges, badgeViews) {
                    value.1.properties = value.0
                }
                layoutBadges()
            } else {
                badgeViews.forEach { $0.removeFromSuperview() }
                badgeViews.removeAll()
            }
        }

        var previousFrameSize: CGSize = .zero

        override func layout() {
            super.layout()
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

        func layoutBadges(elements: [(badge: Badge, badgeView: BadgeView)]) {
            var elements = elements
            let element = elements.removeFirst()
            let firstBadge = element.badge
            let firstBadgeView = element.badgeView
            layoutBadge(firstBadge, badgeView: firstBadgeView)
        }

        func layoutBadges() {
            let badges = configuration.badges.filter(\.isVisible).sorted(by: \.position.rawValue)
            guard configuration.hasBadges, badges.count == badgeViews.count else { return }
            let badgeViews = badgeViews.sorted(by: \.properties.position.rawValue)
            for value in zip(badges, badgeViews) {
                layoutBadge(value.0, badgeView: value.1)
            }
        }

        func layoutBadge(_ badge: Badge, badgeView: BadgeView) {
            badgeView.horizontalConstraint?.activate(false)
            badgeView.verticalConstraint?.activate(false)
            badgeView.widthConstraint?.activate(false)

            //   let constant = -(2*(badge.type.spacing ?? 0))
            //   badgeView.widthConstraint = badgeView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, constant: constant).activate()

            let badgeSize = badgeView.hostingView.fittingSize
            if badge.shape == .circle {
                badgeView.verticalConstraint = badgeView.topAnchor.constraint(equalTo: topAnchor, constant: badge.type.spacing ?? -(badgeSize.height * 0.33)).activate()
                badgeView.horizontalConstraint = badgeView.leadingAnchor.constraint(equalTo: trailingAnchor, constant: -(badgeSize.width * 0.66)).activate()
            } else {
                switch badge.position {
                case .topLeft, .top, .topRight:
                    badgeView.verticalConstraint = badgeView.topAnchor.constraint(equalTo: topAnchor, constant: badge.type.spacing ?? -(badgeSize.height * 0.33)).activate()
                case .centerLeft, .center, .centerRight:
                    badgeView.verticalConstraint = badgeView.centerYAnchor.constraint(equalTo: centerYAnchor).activate()
                case .bottomLeft, .bottom, .bottomRight:
                    badgeView.verticalConstraint = badgeView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: badge.type.spacing.reverse ?? (badgeSize.height * 0.33)).activate()
                }
                
                switch badge.position {
                case .topLeft, .centerLeft, .bottomLeft:
                    badgeView.horizontalConstraint = badgeView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: badge.type.spacing ?? -(badgeSize.width * 1.33)).activate()
                case .topRight, .centerRight, .bottomRight:
                    badgeView.horizontalConstraint = badgeView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: badge.type.spacing.reverse ?? badgeSize.width * 0.33).activate()
                case .top, .center, .bottom:
                    badgeView.horizontalConstraint = badgeView.centerXAnchor.constraint(equalTo: centerXAnchor).activate()
                }
            }
        }

        var centerYConstraint: NSLayoutConstraint?
        var intrinsicSize = CGSize(NSView.noIntrinsicMetric, NSView.noIntrinsicMetric)
        override var intrinsicContentSize: NSSize {
            if frame.size == .zero {
                return CGSize(NSView.noIntrinsicMetric, NSView.noIntrinsicMetric)
            }

            var intrinsicContentSize = CGSize(NSView.noIntrinsicMetric, NSView.noIntrinsicMetric)
            var size = frame.size
            if let superviewWidth = superview?.frame.size.width {
                size.width = superviewWidth - configuration.margins.width
            }
            if let imageSize = image?.size, contentProperties.imageProperties.scaling.shouldResize {
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
                if let imageSize = image?.size, configuration.contentProperties.imageProperties.scaling == .none {
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
            backgroundColor = contentProperties._resolvedBackgroundColor
            visualEffect = contentProperties.visualEffect
            containerView.border.color = contentProperties._resolvedBorderColor
            containerView.border.width = contentProperties.resolvedBorderWidth

            cornerRadius = contentProperties.cornerRadius
            containerView.cornerRadius = contentProperties.cornerRadius
            imageView.cornerRadius = contentProperties.cornerRadius
            view?.cornerRadius = contentProperties.cornerRadius
            overlayView?.cornerRadius = contentProperties.cornerRadius

            configurate(using: contentProperties.stateShadow, type: .outer)

            imageView.tintColor = contentProperties._resolvedImageTintColor
            imageView.imageScaling = contentProperties.imageProperties.scaling.scaling
            imageView.symbolConfiguration = contentProperties.imageProperties.symbolConfiguration?.nsSymbolConfiguration()
            image = configuration.image

            if configuration.view != view {
                view = configuration.view
            }

            if configuration.overlayView != overlayView {
                overlayView = configuration.overlayView
            }

            isHidden = configuration.hasContent == false
            updateBadges()

            anchorPoint = CGPoint(0.5, 0.5)
            layer?.scale = contentProperties.scaleTransform.point
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
