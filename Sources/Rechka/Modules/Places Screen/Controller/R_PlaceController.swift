//
//  BusPlaceController.swift
//  MosmetroNew
//
//  Created by Гусейн on 03.12.2021.
//  Copyright © 2021 Гусейн Римиханов. All rights reserved.
//

import UIKit
import CoreTableView

class R_PlaceController: UIViewController {
    
    let mainView = R_PlaceView.loadFromNib()
    
//    var seats: [BusSeat] = [] {
//        didSet {
//            makeState()
//        }
//    }
    
    var onPlaceSelect: Command<Int>?
    
    var trip: R_Trip? {
        didSet {
            guard let trip = trip else { return }
            loadPlaces(for: trip)
        }
    }
    
    var places: [Int] = [] {
        didSet {
            shouldPerformFirstSet = true
            self.makeState()
        }
    }
    /// Говорит о том, что если уже было выбрано место и мы открываем контроллер с этим местом, то не трогать стейт
    var shouldPerformFirstSet = true
    
    var selectedPlace: Int? {
        didSet {
            if shouldPerformFirstSet {
                self.makeState()
                if let selectedPlace = self.selectedPlace {
                    self.onPlaceSelect?.perform(with: selectedPlace)
                    self.dismiss(animated: true, completion: nil)
                }
                shouldPerformFirstSet = false
            }
            
            
        }
    }
    
    private func loadPlaces(for trip: R_Trip) {
        self.mainView.viewState = .init(title: "Выберите место", subtitle: "Схема может не совпадать", dataState: .loading, items: [])
        Task {
            do {
                let places = try await trip.getFreePlaces()
                self.places = places
            } catch {
                print(error)
            }
            
        }
      
    }
    
    override func loadView() {
        super.loadView()
        self.view = mainView
        mainView.backgroundColor = Appearance.colors[.content]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Appearance.colors[.content]
        
    }
    
}

extension R_PlaceController {
    
    private func makeState() {
        let seatsData: [R_PlaceView.ViewState.Seat] = places.map { place in
            var isSelected = false
            if let currentlySelected = self.selectedPlace {
                isSelected = place == currentlySelected
            }
            let onSelect = Command { [weak self] in
                self?.selectedPlace = place
            }
            
            return .init(text: "\(place)", isSelected: isSelected, isUnvailable: false, onSelect: onSelect)
        }
        
        self.mainView.viewState = .init(title: "Выберите место", subtitle: "Схема может не совпадать с реальной", dataState: .loaded, items: seatsData)
    }
}
