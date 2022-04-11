//
//  MapViewController.swift
//  MetroRechka
//
//  Created by polykuzin on 15/03/2022.
//

import UIKit
import Rechka
import YandexMapsMobile

class MapViewController : UIViewController, YMKMapObjectTapListener {
    
    private class TerminalUserData {
        let terminal: _RiverStation
        
        init(terminal: _RiverStation) {
            self.terminal = terminal
        }
    }
    
    var delegate: RechkaMapReverceDelegate?
    
    public var terminals = [_RiverStation]()
    
    public var terminalsImages = [UIImage]() {
        didSet {
            self.showTerminalsOnMap(from: terminalsImages, and: terminals)
        }
    }
    
    public var shouldShowTerminalsButton = false
    
    @IBOutlet weak var mapView : YMKMapView!
    
    @IBOutlet weak var backButton : UIButton!
    
    @IBOutlet weak var terminalsButton : UIButton!
    
    @IBAction func onBackSelect() {
        delegate?.onMapBackSelect()
    }
    
    @IBAction func onTerminalsSelect() {
        delegate?.onTerminalsListSelect()
    }
    
    // типо координаты москвы
    var initialLatitude : Double = 55.7522200
    var initialLongitude : Double = 37.6155600
    
    override func viewDidLoad() {
        super.viewDidLoad()
        terminalsButton.titleLabel?.font = UIFont.customFont(forTextStyle: .body)
        mapView.mapWindow.map.move(
            with: YMKCameraPosition(
                target: YMKPoint(latitude: initialLatitude, longitude: initialLongitude),
                zoom: 15,
                azimuth: 0,
                tilt: 0
            ),
            animationType: YMKAnimation(type: YMKAnimationType.smooth, duration: 1),
            cameraCallback: nil
        )
        showTerminalsOnMap(from: terminalsImages, and: terminals)
        if shouldShowTerminalsButton {
            self.showTerminalListButton()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

extension MapViewController : RechkaMapController {
    
    func showTerminalListButton() {
        self.terminalsButton.isHidden = false
    }
    
    private func createNewPoint(with terminal: _RiverStation) -> YMKPoint {
        var point = YMKPoint()
        let clusterCenter = terminal
        let latitude = clusterCenter.latitude
        let longitude = clusterCenter.longitude
        point = YMKPoint(latitude: latitude, longitude: longitude)
        return point
    }
    
    func showTerminalsOnMap(from images: [UIImage], and terminals: [_RiverStation]) {
        DispatchQueue.main.async {
            guard
                images.count == terminals.count
            else { fatalError() }
            for (image, terminal) in zip(images, terminals) {
                let point = self.createNewPoint(with: terminal)
                let mapObjects = self.mapView.mapWindow.map.mapObjects
                let teminalObject = mapObjects.addPlacemark(with: point, image: image, style: YMKIconStyle())
                teminalObject.userData = TerminalUserData(terminal: terminal)
                teminalObject.addTapListener(with: self)
            }
        }
    }
    
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        if let data = mapObject.userData as? TerminalUserData {
            data.terminal.onSelect()
        }
        return true
    }
}
