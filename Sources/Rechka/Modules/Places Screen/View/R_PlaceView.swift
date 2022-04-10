//
//  BusPlaceView.swift
//  MosmetroNew
//
//  Created by Гусейн on 03.12.2021.
//  Copyright © 2021 Гусейн Римиханов. All rights reserved.
//

import UIKit
import CoreTableView

class R_PlaceView: UIView {
    
    @IBOutlet private var titleLabel: UILabel!
    
    @IBOutlet private var subtitleLabel: UILabel!
    
    @IBOutlet private var collectionView: UICollectionView!
    
    
    
    struct ViewState {
        let title: String
        let subtitle: String
        let dataState: DataState
        let items: [Seat]
        
        enum DataState {
            case loading
            case loaded
            case error
        }
        
        struct Seat: _R_PlaceCollectionCell {
            var text: String
            
            var isSelected: Bool
            
            var isUnvailable: Bool
            
            var onSelect: Command<Void>
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    var viewState: ViewState = .init(title: "Выберите место", subtitle: "Схема может не совпадать", dataState: .loading, items: []) {
        didSet {
            DispatchQueue.main.async {
                self.render()
            }
         
        }
    }
    
    
}

extension R_PlaceView {
    
    
    private func render() {
        switch viewState.dataState {
        case .loading:
            self.showBlurLoading(on: self)
        case .loaded:
            self.removeBlurLoading(from: self)
        case .error:
            self.removeBlurLoading(from: self)
        }
        self.collectionView.reloadData()
        self.titleLabel.text = viewState.title
        self.subtitleLabel.text = viewState.subtitle
    }
    
    private func setup() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(R_PlaceCollectionCell.nib, forCellWithReuseIdentifier: R_PlaceCollectionCell.identifire)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: {
            //  swiftlint:disable force_cast
            let layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            //  swiftlint:enable force_cast
            layout.itemSize = self.itemSize()
        })
    }
    
    private func itemSize() -> CGSize {
        var width = (self.collectionView.frame.width - 40) / 5
        width -= 10
        return CGSize(width: width, height: width)
        
    }
}


extension R_PlaceView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewState.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let element = self.viewState.items[safe: indexPath.item] else { return .init() }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R_PlaceCollectionCell.identifire, for: indexPath) as? R_PlaceCollectionCell else { return .init() }
        cell.configure(data: element)
        return cell
    }
    
}

extension R_PlaceView: UICollectionViewDelegate {
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let element = self.viewState.items[safe: indexPath.item] {
            element.onSelect.perform(with: ())
        }
    }
}

extension R_PlaceView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return itemSize()
    }
    
}
