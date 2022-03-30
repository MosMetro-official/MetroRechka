import UIKit

public let fontBundle = Bundle.module

public struct Rechka {
    
    public static var delegate : RechkaMapDelegate? = nil
    public static var isMapsAvailable : Bool!
    public static var isMapsRoutesAvailable : Bool!
    
    public init(isMapsAvailable: Bool = true, isMapsRoutesAvailable: Bool = true, delegate: RechkaMapDelegate? = nil) {
        Rechka.delegate = delegate
        Rechka.isMapsAvailable = isMapsAvailable
        Rechka.isMapsRoutesAvailable = isMapsRoutesAvailable
    }
    
    /// Return first view controller of packge module
    public func showRechkaFlow() -> UINavigationController {
        /// load data
        let controller = PopularStationController()
        controller.delegate = Rechka.delegate
        return UINavigationController(rootViewController: controller)
    }
    
    /// Need to call in AppDelegate or SceneDelegate to register custom fonts from package
    public static func registerFonts() {
        _ = UIFont.registerFont(bundle: .module, fontName: "MoscowSans-Bold", fontExtension: "otf")
        _ = UIFont.registerFont(bundle: .module, fontName: "MoscowSans-Regular", fontExtension: "otf")
    }
}

extension DateComponents: Comparable {
    public static func < (lhs: DateComponents, rhs: DateComponents) -> Bool {
        if let lhsDate = Date(components: lhs, region: nil), let rhsDate = Date(components: rhs, region: nil) {
            return lhsDate < rhsDate
        }
        return false
    }
}
