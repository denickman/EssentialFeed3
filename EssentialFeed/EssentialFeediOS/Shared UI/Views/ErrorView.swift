//
//  ErrorView.swift
//  EssentialFeediOS
//
//  Created by Denis Yaremenko on 11.02.2025.
//

import UIKit

// since ErrorView is duplicating in 2 storyboards we should make it by code
// so every storyboard in further will have the same error message
// here it is good to have a snapshot tests due to converting UI to code implementation of this element
// all the settings should be the same and look like in a storyboard UI Error view

public final class ErrorView: UIButton {
    
    // MARK: - Properties
    
    public var onHide: (()->Void)?
    
    public var message: String? {
        get { return isVisible ? configuration?.title : nil }
        set { setMessageAnimated(newValue) }
    }
    
    // label config was previously for the ErrorView: UIView not for ErrorView: UIButton
    //    private lazy var label: UILabel = {
    //        let label = UILabel()
    //        label.textColor = .white
    //        label.textAlignment = .center
    //        label.numberOfLines = 0
    //        label.font = .systemFont(ofSize: 17)
    //        return label
    //    }()
    
    private var isVisible: Bool {
        alpha > 0
    }
    
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    
    // awakeFromNib() вызывается только если объект был создан из Storyboard/XIB
    //    public override func awakeFromNib() {
    //        super.awakeFromNib()
    //        hideMessage()
    //    }
    
    // MARK: - Methods
    
    private var titleAttributes: AttributeContainer {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        
        var attributes = AttributeContainer()
        attributes.paragraphStyle = paragraphStyle
        attributes.font = UIFont.preferredFont(forTextStyle: .body)
        return attributes
    }
    
    @objc private func hideMessageAnimated() {
        UIView.animate(
            withDuration: 0.25,
            animations: { self.alpha = 0 },
            completion: { completed in
                if completed { self.hideMessage() }
            })
    }
    
    private func setMessageAnimated(_ message: String?) {
        if let message = message {
            showAnimated(message)
        } else {
            hideMessageAnimated()
        }
    }
    
    private func showAnimated(_ message: String) {
        configuration?.attributedTitle = AttributedString(message, attributes: titleAttributes)
        configuration?.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
    
    private func hideMessage() {
        //        setTitle(nil, for: .normal)
        //        alpha = 0
        //        var config = UIButton.Configuration.filled()
        //        config.baseBackgroundColor = .errorBackgroundColor
        //        config.titleAlignment = .center
        //        config.contentInsets = NSDirectionalEdgeInsets(top: -2.5, leading: 0, bottom: -2.5, trailing: 0)
        //        configuration = config
        //        onHide?()
        
        alpha = 0
        configuration?.attributedTitle = nil
        configuration?.contentInsets = .zero
        onHide?()
    }
    
    private func configure() {
        
        var configuration = Configuration.plain()
        configuration.titlePadding = 0
        configuration.baseForegroundColor = .white
        configuration.background.backgroundColor = .errorBackgroundColor
        configuration.background.cornerRadius = 0
        self.configuration = configuration
        
        
        addTarget(self, action: #selector(hideMessageAnimated), for: .touchUpInside)
        hideMessage()
    }
    
    
    /* do not use it anymore since `Configuration` appearance
     private func configureLabel() {
     titleLabel?.textColor = .white
     titleLabel?.textAlignment = .center
     titleLabel?.numberOfLines = 0
     //titleLabel?.font = .systemFont(ofSize: 17)
     
     // for dynamic fonts
     titleLabel?.font = .preferredFont(forTextStyle: .body)
     titleLabel?.adjustsFontForContentSizeCategory = true
     
     // label constraints was previously for the ErrorView: UIView not for ErrorView: UIButton
     
     //        addSubview(titleLabel)
     //        titleLabel.translatesAutoresizingMaskIntoConstraints = false
     //        NSLayoutConstraint.activate ([
     //            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
     //            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
     //            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
     //            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
     //        ])
     }
     */
    
}

extension UIColor {
    static var errorBackgroundColor: UIColor {
        UIColor(red: 0.99951404330000004, green: 0.41759261489999999, blue: 0.4154433012, alpha: 1)
    }
}
