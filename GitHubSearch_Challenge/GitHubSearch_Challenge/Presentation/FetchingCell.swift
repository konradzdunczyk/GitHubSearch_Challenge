//
//  FetchingCell.swift
//  GitHubSearch_Challenge
//
//  Created by Zduńczyk Konrad on 19/10/2021.
//

import UIKit

class FetchingCell: UITableViewCell {
    private let _indicator: UIActivityIndicatorView = {
        $0.translatesAutoresizingMaskIntoConstraints = false

        return $0
    }(UIActivityIndicatorView(style: .large))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupViews()
        setupConstraints()
    }

    @available(*, unavailable)
    init() { fatalError() }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()
        _indicator.startAnimating()
    }

    private func setupViews() {
        contentView.addSubview(_indicator)
        _indicator.startAnimating()
    }

    private func setupConstraints() {
        let c = [
            _indicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            _indicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            _indicator.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8)
        ]

        NSLayoutConstraint.activate(c)
    }

}
