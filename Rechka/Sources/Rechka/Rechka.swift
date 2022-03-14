import UIKit

public let fontBundle = Bundle.module

public struct Rechka {
    public private(set) var text = "Hello, World!"
    public init() { }
    /// Return first view controller of packge module
    public static func showRechkaFlow() -> UINavigationController {
        /// load data
        return UINavigationController(rootViewController: PopularStationController())
    }
    /// Need to call in AppDelegate or SceneDelegate to register custom fonts from package
    public static func registerFonts() {
        _ = UIFont.registerFont(bundle: .module, fontName: "MoscowSans-Bold", fontExtension: "otf")
        _ = UIFont.registerFont(bundle: .module, fontName: "MoscowSans-Regular", fontExtension: "otf")
    }
}
