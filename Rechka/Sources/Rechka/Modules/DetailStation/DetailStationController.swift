//
//  DetailStationController.swift
//  
//
//  Created by Слава Платонов on 11.03.2022.
//

import UIKit

class DetailStationController: UIViewController {
    
    var model: FakeModel? {
        didSet {
            print(model?.title ?? "nil")
        }
    }
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = "\(model?.title ?? "") \nЦена - \(model?.price ?? "")"
        label.font = UIFont.customFont(forTextStyle: .largeTitle)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = .gray
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(label)
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 150).isActive = true
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
    }
}
