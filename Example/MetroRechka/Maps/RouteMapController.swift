//
//  RouteMapController.swift
//  MetroRechka
//
//  Created by guseyn on 15.04.2022.
//

import UIKit
import Rechka
import YandexMapsMobile

class RouteMapController: UIViewController, R_RouteLineController {
    
    @IBOutlet weak var mapView: YMKMapView!
    
    var route: R_Route?
    
    @IBOutlet weak var titleLabelTopAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var mainTitleLabel: UIOutlinedLabel!
    private var isDarkMode: Bool = false
    
    init(route: R_Route) {
        self.route = route
        super.init(nibName: "RouteMapController", bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let height = view.window?.windowScene?.statusBarManager?.statusBarFrame.height else { return }
        self.titleLabelTopAnchor.constant = height + 11
        self.view.layoutSubviews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let f = mapView.mapWindow.map
        switch traitCollection.userInterfaceStyle {
        case .light, .unspecified:
            self.isDarkMode = false
        case .dark:
            self.isDarkMode = true
        }
        f.isNightModeEnabled = isDarkMode
        f.setMapLoadedListenerWith(self)
    }
    
    

    




}

extension RouteMapController: YMKMapLoadedListener {
    
    func onMapLoaded(with statistics: YMKMapLoadStatistics) {
        self.prepareDrawings()
    }
    
    
}

extension UIView {
    
    /**
     Load the view from a nib file called with the name of the class;
      - note: The first object of the nib file **must** be of the matching class
      - parameters:
        - none
     */
    static internal func loadFromNib() -> Self {
        //let bundle = Bundle.module
        let nib = UINib(nibName: String(describing: self), bundle: nil)
        return nib.instantiate(withOwner: nil, options: nil).first as! Self
    }
}

extension RouteMapController {
    
    
    private func zoomToRoute(polyline: YMKPolyline) {
        guard let bounds = YMKGetPolylineBounds(polyline) else { return }
        
        var cameraPosition = mapView.mapWindow.map.cameraPosition(with: bounds)
        cameraPosition = YMKCameraPosition(target: cameraPosition.target, zoom: cameraPosition.zoom, azimuth: cameraPosition.azimuth, tilt: cameraPosition.tilt)
        mapView.mapWindow.map.move(with: cameraPosition, animationType: YMKAnimation(type: YMKAnimationType.smooth, duration: 0.25), cameraCallback: nil)

    }
    
    private func addStations(_ stations: [R_Station]) {
        for station in stations {
            let riverStationPin = RiverStationPinView.loadFromNib()
            riverStationPin.nameLabel.text = station.name
            riverStationPin.nameLabel.sizeToFit()
            riverStationPin.nameLabel.textColor = isDarkMode ? .white : .black
            riverStationPin.nameLabel.outlineColor = isDarkMode ? .black : .white
            let dark = UIImage(named: "riverStation_dark")!
            let light = UIImage(named: "riverStation_light")!
            riverStationPin.imageView.image = isDarkMode ? dark : light
            let width = riverStationPin.nameLabel.intrinsicContentSize.width
            riverStationPin.frame = CGRect(x: 0, y: 0, width: width + 4, height: 69)
            let style = YMKIconStyle()
            style.scale = 0.7
            riverStationPin.isOpaque = false
            riverStationPin.layoutIfNeeded()
            let point = YMKPoint(latitude: station.latitude, longitude: station.longitude)
            let _ = mapView.mapWindow.map.mapObjects.addPlacemark(with: point, view: YRTViewProvider(uiView: riverStationPin), style: style)
        }
        
    }
    
    private func prepareDrawings() {
        guard let route = route else { return }
        let sortedPoints = route.polyline.sorted(by: { $0.position > $1.position })
        let points: [YMKPoint] = sortedPoints.map { point in
            return YMKPoint(latitude: point.latitude, longitude: point.longitude)
        }
        let polyline = YMKPolyline(points: points)
        let coloredPolyline = self.mapView.mapWindow.map.mapObjects.addColoredPolyline()
        coloredPolyline.geometry = polyline
        coloredPolyline.setPaletteColorWithColorIndex(0, color: .systemBlue)
        coloredPolyline.outlineWidth = 3
        coloredPolyline.outlineColor = Appearance.colors[.base] ?? .systemBackground
        var colors: [NSNumber] = points.map { _ in  return 0 }
        colors.removeLast()
        coloredPolyline.setColorsWithColors(colors)
        addStations(route.stations)
        zoomToRoute(polyline: polyline)
        
        
    }
    
}
