//
//  LoadingView.swift
//  GitHubSearch_Challenge
//
//  Created by Zduńczyk Konrad on 19/10/2021.
//

import UIKit

class LoadingView: UIView {
    private let _indicator: UIActivityIndicatorView = {
        $0.translatesAutoresizingMaskIntoConstraints = false

        return $0
    }(UIActivityIndicatorView(style: .large))

    init() {
        super.init(frame: CGRect())

        setupBlurBackground()
        setupViews()
        setupConstraints()
    }

    @available(*, unavailable)
    override init(frame: CGRect) { fatalError() }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    private func setupBlurBackground() {
        backgroundColor = .clear

        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurEffectView)
        sendSubviewToBack(blurEffectView)
    }

    private func setupViews() {
        clipsToBounds = true
        layer.cornerRadius = 8

        addSubview(_indicator)
        _indicator.startAnimating()
    }

    private func setupConstraints() {
        let constraints = [
            _indicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            _indicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            _indicator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            _indicator.topAnchor.constraint(equalTo: topAnchor, constant: 24)
        ]

        NSLayoutConstraint.activate(constraints)
    }
}
