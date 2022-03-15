import UIKit

public let fontBundle = Bundle.module

public struct Rechka {
    
    public static var isMapsAvailable : Bool = true
    private var delegate : RechkaMapDelegate? = nil
    
    public init(isMapsAvailable: Bool = true, delegate: RechkaMapDelegate? = nil) {
        self.delegate = delegate
        Rechka.isMapsAvailable = isMapsAvailable
    }
    
    /// Return first view controller of packge module
    public func showRechkaFlow() -> UINavigationController {
        /// load data
        let controller = PopularStationController()
        controller.delegate = self.delegate
        return UINavigationController(rootViewController: controller)
    }
    
    /// Need to call in AppDelegate or SceneDelegate to register custom fonts from package
    public static func registerFonts() {
        _ = UIFont.registerFont(bundle: .module, fontName: "MoscowSans-Bold", fontExtension: "otf")
        _ = UIFont.registerFont(bundle: .module, fontName: "MoscowSans-Regular", fontExtension: "otf")
    }
}
