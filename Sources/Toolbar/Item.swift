//
//  ToolbarItem.swift
//  Toolbar
//
//  Created by 1amageek on 2017/04/20.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

#if !os(macOS)
import UIKit
#endif

public extension Toolbar {
    
    class Item: UIView {

        public enum Spacing {
            case none
            case flexible
            case fixed
        }

        public override class var requiresConstraintBasedLayout: Bool {
            return true
        }

        public var title: String? {
            didSet {
                self.titleLabel?.text = title
                self.setNeedsUpdateConstraints()
            }
        }

        public var image: UIImage? {
            didSet {
                self.imageView?.image = image
                self.imageView?.setNeedsDisplay()
            }
        }

        public override var isHidden: Bool {
            willSet {
                self._setHidden(newValue, animated: false)
            }
            didSet {
                self.setNeedsLayout()
            }
        }

        public var isSelected: Bool = false {
            didSet {
                self.setSelected(isSelected, animated: true)
            }
        }

        public var isEnabled: Bool = true {
            didSet {
                self.tapGestureRecognizer.isEnabled = isEnabled
                self.setEnabled(isEnabled, animated: true)
            }
        }

        public var isHighlighted: Bool = false {
            didSet {
                self.setHighlighted(isHighlighted, animated: true)
            }
        }

        /// Animation Duration
        public var animationDuration: TimeInterval = 0.3

        /// Content inset
        public var contentInset: UIEdgeInsets = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)

        /// Content size
        public var contentSize: CGSize = .zero

        /// Fixed Space width
        public var width: CGFloat = 1 // Default 1

        /// Custom height
        public var height: CGFloat = 1

        /// The minimum height of the item
        public var minimumHeight: CGFloat = Toolbar.defaultHeight - 12

        /// The minimum width of the item
        public var minimumWidth: CGFloat {
            if let label: UILabel = self.titleLabel {
                let size: CGSize = label.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
                return self.contentInset.left + size.width + self.contentInset.right
            }

            if let view: UIImageView = self.imageView {
                let size: CGSize = view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
                return self.contentInset.left + size.width + self.contentInset.right
            }

            if let _: UIView = self.customView {
                return self.contentInset.left + self.width + self.contentInset.right
            }

            return self.width
        }

        /// The maximum height of the item
        public var maximumHeight: CGFloat = UIScreen.main.bounds.height {
            didSet {
                if maximumHeight < minimumHeight {
                    debugPrint("[ToolbarItem] *** error: maximumHeight can not be smaller than minimumHeight")
                }
                setNeedsUpdateConstraints()
            }
        }

        /// The maximum width of the item
        public var maximumWidth: CGFloat = UIScreen.main.bounds.width {
            didSet {
                if maximumWidth < minimumWidth {
                    debugPrint("[ToolbarItem] *** error: maximumWidth can not be smaller than minimumWidth")
                }
                setNeedsUpdateConstraints()
            }
        }

        /// Tap event target
        public weak var target: AnyObject?

        /// Tap event action
        public var action: Selector?

        // Private

        public private(set) var titleLabel: UILabel?

        public private(set) var imageView: UIImageView?

        public private(set) var customView: UIView?

        public private(set) var spacing: Spacing = .none

        private var minimumWidthConstraint: NSLayoutConstraint?

        private var maximumWidthConstraint: NSLayoutConstraint?

        private var minimumHeightConstraint: NSLayoutConstraint?

        private var maximumHeightConstraint: NSLayoutConstraint?

        private var titleLabelCenterXConstraint: NSLayoutConstraint?

        private var titleLabelCenterYConstraint: NSLayoutConstraint?

        private var imageViewCenterXConstraint: NSLayoutConstraint?

        private var imageViewCenterYConstraint: NSLayoutConstraint?

        private var imageViewWidthConstraint: NSLayoutConstraint?

        private var imageViewHeightConstraint: NSLayoutConstraint?

        private var customViewLeadingConstraint: NSLayoutConstraint?

        private var customViewTrailingConstraint: NSLayoutConstraint?

        private var customViewTopConstraint: NSLayoutConstraint?

        private var customViewBottomConstraint: NSLayoutConstraint?

        private var customViewMinimumHeightConstraint: NSLayoutConstraint?

        // MARK: - init

        public convenience init(title: String?, target: Any?, action: Selector?) {
            self.init(frame: .zero)
            self.target = target as AnyObject
            self.action = action

            let label: UILabel = UILabel(frame: .zero)
            label.numberOfLines = 1
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .center
            label.text = title

            self.title = title
            self.titleLabel = label

            self.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
            self.setContentHuggingPriority(UILayoutPriority.required, for: .vertical)

            self.addSubview(label)
            self.addGestureRecognizer(tapGestureRecognizer)
        }

        public convenience init(image: UIImage, target: Any?, action: Selector?) {
            self.init(frame: .zero)
            self.target = target as AnyObject
            self.action = action

            let view: UIImageView = UIImageView(image: image)
            view.contentMode = .scaleAspectFill
            view.translatesAutoresizingMaskIntoConstraints = false

            self.image = image
            self.imageView = view

            self.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
            self.setContentHuggingPriority(UILayoutPriority.required, for: .vertical)

            self.addSubview(view)
            self.addGestureRecognizer(tapGestureRecognizer)
        }

        public convenience init(customView: UIView) {
            self.init(frame: .zero)
            self.addSubview(customView)
            customView.translatesAutoresizingMaskIntoConstraints = false
            self.customView = customView
        }

        public convenience init(spacing: Spacing) {
            self.init(frame: .zero)
            self.spacing = spacing
            switch spacing {
                case .flexible:
                    self.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)
                    self.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .vertical)
                case .fixed:
                    self.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
                    self.setContentHuggingPriority(UILayoutPriority.required, for: .vertical)
                default: break
            }
        }

        public override init(frame: CGRect) {
            super.init(frame: frame)
            self.backgroundColor = .clear
            self.isOpaque = false
        }

        required public init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        public override var intrinsicContentSize: CGSize {

            if let label: UILabel = self.titleLabel {
                let size: CGSize = label.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
                return CGSize(width: self.contentInset.left + size.width + self.contentInset.right, height: size.height)
            }

            if let view: UIImageView = self.imageView {
                let size: CGSize = view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
                return CGSize(width: self.contentInset.left + size.width + self.contentInset.right, height: size.height)
            }

            switch self.spacing {
                case .flexible: return CGSize(width: 1, height: 1)
                case .fixed: return CGSize(width: self.width, height: 1)
                default: return super.intrinsicContentSize
            }
        }

        override public func updateConstraints() {

            // deactive
            self.removeConstraints([self.minimumWidthConstraint,
                                    self.maximumWidthConstraint,
                                    self.minimumHeightConstraint,
                                    self.maximumHeightConstraint,
                                    self.titleLabelCenterXConstraint,
                                    self.titleLabelCenterYConstraint,
                                    self.imageViewCenterXConstraint,
                                    self.imageViewCenterYConstraint,
                                    self.imageViewWidthConstraint,
                                    self.imageViewHeightConstraint,
                                    self.customViewLeadingConstraint,
                                    self.customViewTrailingConstraint,
                                    self.customViewTopConstraint,
                                    self.customViewBottomConstraint
            ].compactMap({ return $0 }))

            self.minimumWidthConstraint = self.widthAnchor.constraint(greaterThanOrEqualToConstant: self.minimumWidth)
            self.maximumWidthConstraint = self.widthAnchor.constraint(lessThanOrEqualToConstant: self.maximumWidth)
            self.minimumHeightConstraint = self.heightAnchor.constraint(greaterThanOrEqualToConstant: self.minimumHeight)
            self.maximumHeightConstraint = self.heightAnchor.constraint(lessThanOrEqualToConstant: self.maximumHeight)

            if let label: UILabel = self.titleLabel {
                self.titleLabelCenterXConstraint = label.centerXAnchor.constraint(equalTo: self.centerXAnchor)
                self.titleLabelCenterYConstraint = label.centerYAnchor.constraint(equalTo: self.centerYAnchor)
                self.titleLabelCenterXConstraint?.isActive = true
                self.titleLabelCenterYConstraint?.isActive = true
            }

            if let view: UIImageView = self.imageView {
                self.imageViewCenterXConstraint = view.centerXAnchor.constraint(equalTo: self.centerXAnchor)
                self.imageViewCenterYConstraint = view.centerYAnchor.constraint(equalTo: self.centerYAnchor)
                self.imageViewCenterXConstraint?.isActive = true
                self.imageViewCenterYConstraint?.isActive = true
                if self.contentSize != .zero {
                    self.imageViewWidthConstraint = view.widthAnchor.constraint(equalToConstant: self.contentSize.width)
                    self.imageViewHeightConstraint = view.heightAnchor.constraint(equalToConstant: self.contentSize.height)
                    self.imageViewWidthConstraint?.isActive = true
                    self.imageViewHeightConstraint?.isActive = true
                }
            }

            if let view: UIView = self.customView {
                self.customViewLeadingConstraint = view.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor)
                self.customViewTrailingConstraint = view.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor)
                self.customViewTopConstraint = view.topAnchor.constraint(equalTo: self.topAnchor, constant: 0)
                self.customViewBottomConstraint = view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
                self.customViewLeadingConstraint?.isActive = true
                self.customViewTrailingConstraint?.isActive = true
                self.customViewTopConstraint?.isActive = true
                self.customViewBottomConstraint?.isActive = true
            }

            self.minimumHeightConstraint?.isActive = true
            self.maximumHeightConstraint?.isActive = true
            super.updateConstraints()
        }

        // MARK: -

        private func _setHidden(_ hidden: Bool, animated: Bool) {
            if hidden == self.isHidden {
                return
            }
            self.layer.removeAllAnimations()
            let alpha: CGFloat = hidden ? 0 : 1
            if animated {
                UIView.animate(withDuration: self.animationDuration, animations: {
                    self.alpha = alpha
                    self.isHidden = hidden
                })
            }
            self.alpha = alpha
        }

        public func setHidden(_ hidden: Bool, animated: Bool) {
            _setHidden(hidden, animated: animated)
        }

        public func setSelected(_ isSelected: Bool, animated: Bool) {
            guard self.isEnabled else {
                return
            }
        }

        public func setEnabled(_ isEnabled: Bool, animated: Bool) {
            if animated {
                self.layoutIfNeeded()
                UIView.animate(withDuration: 0.2, animations: {
                    if let label: UILabel = self.titleLabel {
                        label.textColor = isEnabled ? self.tintColor : UIColor.lightGray
                    }
                    if let view: UIImageView = self.imageView {
                        view.tintColor = isEnabled ? self.tintColor : UIColor.lightGray
                    }
                })
            } else {
                if let label: UILabel = self.titleLabel {
                    label.textColor = isEnabled ? self.tintColor : UIColor.lightGray
                }
                if let view: UIImageView = self.imageView {
                    view.tintColor = isEnabled ? self.tintColor : UIColor.lightGray
                }
            }
        }

        public func setHighlighted(_ highlighted: Bool, animated: Bool) {
            guard self.isEnabled else {
                return
            }

            if animated {
                UIView.animate(withDuration: 0.2, animations: {
                    self.alpha = highlighted ? 0.5 : 1
                })
            } else {
                self.alpha = highlighted ? 0.5 : 1
            }
        }

        // MARK: -

        private(set) lazy var tapGestureRecognizer: UITapGestureRecognizer = {
            let recognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self.target, action: self.action)
            return recognizer
        }()

        // MARK: - Touches

        public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesBegan(touches, with: event)
            if self.customView == nil {
                self.isHighlighted = true
            }
        }

        public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesEnded(touches, with: event)
            if self.customView == nil {
                self.isHighlighted = false
            }
        }

        public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesCancelled(touches, with: event)
            if self.customView == nil {
                self.isHighlighted = false
            }
        }

    }
}
