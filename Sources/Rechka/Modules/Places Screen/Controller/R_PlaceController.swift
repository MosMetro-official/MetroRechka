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
    
    //var onSeatSelect: ((BusSeat) -> ())?
    
    var trip: R_Trip? {
        didSet {
            guard let trip = trip else { return }
            loadPlaces(for: trip)
        }
    }
    
    var places: [Int] = [] {
        didSet {
            Task.detached { [weak self] in
                await self?.makeState()
            }
        }
    }
    
    var selectedPlace: Int? {
        didSet {
            Task.detached { [weak self] in
                await self?.makeState()
            }
        }
    }
    
    private func loadPlaces(for trip: R_Trip) {
        self.mainView.viewState = .init(title: "Выберите место", subtitle: "Схема может не совпадать", dataState: .loading, items: [])
        Task.detached { [weak self] in
            do {
                let freePlaces = try await trip.getFreePlaces()
                try await Task.sleep(nanoseconds: 0_300_000_000)
                await MainActor.run { [weak self] in
                    self?.places = freePlaces
                }
            } catch {
                
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
    
    private func makeState() async {
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
        await MainActor.run { [weak self] in
            self?.mainView.viewState = .init(title: "Выберите место", subtitle: "Схема может не совпадать", dataState: .loaded, items: seatsData)
        }
        
    }
}
