//
//  StationCell.swift
//  
//
//  Created by Слава Платонов on 08.03.2022.
//

import UIKit
import CoreTableView

protocol _StationCell: CellData {
    var title: String { get }
    var jetty: String { get }
    var time: String { get }
    var tickets: Bool { get }
    var price: String { get }
}

extension _StationCell {
    
    func prepare(cell: UITableViewCell, for tableView: UITableView, indexPath: IndexPath) {
        guard let cell = cell as? StationCell else { return }
        cell.configure(with: self)
    }
    
    func cell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        tableView.register(StationCell.self, forCellReuseIdentifier: StationCell.identifire)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StationCell.identifire, for: indexPath) as? StationCell else { return .init() }
        return cell
    }
}

class StationCell: UITableViewCell {
    
    private var onSelect: (() -> ())?
    private let lowTicketsCount = "🔥 Осталось мало билетов"
        
    private let backgroundContent: UIView = {
        let view = UIView()
        view.backgroundColor = Appearance.colors[.content]
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let posterImage: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 10
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "test title text"
        label.numberOfLines = 0
        label.font = .customFont(forTextStyle: .title3)
        label.textAlignment = .left
        label.textColor = Appearance.colors[.textPrimary]
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let jettyLabel: UILabel = {
        let label = UILabel()
        label.text = "test jetty text"
        label.font = .customFont(forTextStyle: .headline)
        label.textAlignment = .left
        label.textColor = Appearance.colors[.textPrimary]
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "test time text"
        label.font = .customFont(forTextStyle: .headline)
        label.textAlignment = .left
        label.textColor = Appearance.colors[.textPrimary]
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let ticketsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .customFont(forTextStyle: .headline)
        label.textAlignment = .left
        label.textColor = Appearance.colors[.textPrimary]
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [jettyLabel, timeLabel, ticketsLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 11
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()
    
    private let priceButton: UIButton = {
        let button = UIButton(type: .system)
        button.clipsToBounds = true
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        earaseData()
    }
    
    @objc private func buttonTapped() {
        onSelect?()
    }
    
    public func configure(with data: _StationCell) {
        titleLabel.text = data.title
        jettyLabel.text = "🛥️ \(data.jetty)"
        timeLabel.text = "🕖 \(data.time)"
        if data.tickets {
            ticketsLabel.text = lowTicketsCount
        }
        posterImage.image = UIImage(named: "poster", in: .module, with: nil)
        priceButton.setTitle("От \(data.price)", for: .normal)
        priceButton.titleLabel?.font = UIFont(name: "MoscowSans-Regular", size: 16)
        onSelect = data.onSelect
    }
    
    public func earaseData() {
        titleLabel.text = nil
        jettyLabel.text = nil
        timeLabel.text = nil
        ticketsLabel.text = nil
        posterImage.image = nil
    }
}

extension StationCell {
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        priceButton.addHorizontalGradientLayer()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.bounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0))
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selectionStyle = .none
    }
    
    private func setupConstrains() {
        contentView.addSubview(posterImage)
        contentView.addSubview(backgroundContent)
        backgroundContent.addSubview(titleLabel)
        backgroundContent.addSubview(descriptionStackView)
        backgroundContent.addSubview(priceButton)
        
        NSLayoutConstraint.activate([
            posterImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            posterImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            posterImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            posterImage.widthAnchor.constraint(equalToConstant: contentView.bounds.width / 2.5),
                
            backgroundContent.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            backgroundContent.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            backgroundContent.leadingAnchor.constraint(equalTo: posterImage.trailingAnchor, constant: 10),
            backgroundContent.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
                
            titleLabel.topAnchor.constraint(equalTo: backgroundContent.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: backgroundContent.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: backgroundContent.trailingAnchor, constant: -12),
            titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 18),
                
            descriptionStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            descriptionStackView.leadingAnchor.constraint(equalTo: backgroundContent.leadingAnchor, constant: 12),
            descriptionStackView.trailingAnchor.constraint(equalTo: backgroundContent.trailingAnchor, constant: -12),
                
            priceButton.leadingAnchor.constraint(equalTo: backgroundContent.leadingAnchor, constant: 12),
            priceButton.trailingAnchor.constraint(equalTo: backgroundContent.trailingAnchor, constant: -12),
            priceButton.bottomAnchor.constraint(equalTo: backgroundContent.bottomAnchor, constant: -16),
            priceButton.heightAnchor.constraint(equalToConstant: 38)
        ])
    }
}


