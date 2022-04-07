import UIKit
import SwiftDate

public let fontBundle = Bundle.module

public class Rechka {
    
    public static let shared = Rechka()
    
    private init() { }
    
    public weak var delegate : RechkaMapDelegate? = nil
    public weak var networkDelegate: RechkaNetworkDelegate?
    public var isMapsAvailable : Bool!
    public var isMapsRoutesAvailable : Bool!
    public let returnURL =  "riverexample://main/riverPaymentSuccess"
    public let failURL =  "riverexample://main/riverPaymentFailure"
    public var token: String? = "46sibIi8xU7jSqjyHCAvZEkBGhBkvpAMVjMDdS0LWlU"
    public var refreshToken: String?
    public var clientID: String = ""
    public var clientSecret: String = ""
    public var applicationName = ""
    public var language = ""
    
    var deviceUUID: String {
        return UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
    
    private var deviceOS: String {
        return UIDevice.current.systemVersion
    }
    
    private var deviceAppVersion: String? {
        guard let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
              let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String else {
            return nil
        }
        return "\(version) (\(build))"
    }
    
    private var deviceModel: String {
        return UIDevice.modelName
    }
    
    private var deviceBundleSignature: String? {
        guard let infoPlistUrl = Bundle.main.url(forResource: "Info", withExtension: "plist") else {
            return nil
        }
        var signature = "00000000"
        do {
            let plistFile = try FileHandle(forReadingFrom: infoPlistUrl)
            let fileData = plistFile.readDataToEndOfFile()
            let dataLength = fileData.count
            fileData.withUnsafeBytes { ptr in
                guard
                    let bytes = ptr.baseAddress?.assumingMemoryBound(to: Int8.self)
                else { return }
                var crc = 0
                for i in 0..<dataLength {
                    crc ^= Int(bytes[i])
                    for _ in 0..<8 {
                        var b = 0
                        
                        if crc == 1 {
                            b = 0xd5828281
                        }
                        crc = ((crc>>1) & 0x7fffffff) ^ b
                    }
                    crc ^= 0xd202ef8d
                }
                signature = String(format: "%08X", crc)
            }
        } catch(let error) {
            print("Read Info.plist failed with error: \(error)")
            return nil
        }
        return signature
    }
    
    var deviceUserAgent: String {
        let defaultUserAgent = String(format: "Mozilla/5.0 (iPhone; CPU iPhone OS %@ like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/604.1", self.deviceOS)
        
        if #available(iOS 13, *) {
            guard let appVersion = self.deviceAppVersion,
                  let bundleSignature = self.deviceBundleSignature else {
                return defaultUserAgent
            }
            
            return String(format: "\(self.applicationName)/%@ (iOS; %@; %@; %@)", appVersion, self.deviceModel, self.deviceOS, bundleSignature)
        } else {
            return defaultUserAgent
        }
    }
    
    /// Return first view controller of packge module
    public func showRechkaFlow() -> UINavigationController {
        /// load data
        let controller = PopularStationController()
        controller.delegate = Rechka.shared.delegate
        return UINavigationController(rootViewController: controller)
    }
    
    /// Need to call in AppDelegate or SceneDelegate to register custom fonts from package
    public static func registerFonts() {
        _ = UIFont.registerFont(bundle: .module, fontName: "MoscowSans-Bold", fontExtension: "otf")
        _ = UIFont.registerFont(bundle: .module, fontName: "MoscowSans-Regular", fontExtension: "otf")
        _ = UIFont.registerFont(bundle: .module, fontName: "MoscowSans-Medium", fontExtension: "otf")
    }
}

extension DateComponents: Comparable {
    public static func < (lhs: DateComponents, rhs: DateComponents) -> Bool {
        
        if let lhsDate = Date(components: lhs, region: nil), let rhsDate = Date(components: rhs, region: nil) {
            let comp = lhsDate.compare(rhsDate)
            switch comp {
            case .orderedAscending:
                return true
            case .orderedSame:
                return false
            case .orderedDescending:
                return false
            }
        }
        return false
    }
}


extension UIColor {
    
    static func from(hex: String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    
}


struct Command<T> {
    
    private var action: (T) -> Void
    
    public init(action: @escaping (T) -> Void) {
        self.action = action
    }
    
    public func perform(with value: T) {
        self.action(value)
    }
    
}


@IBDesignable
extension UILabel
{

    @IBInspectable
    public var userFontName: String
    {
        set (userFont) {
            self.font = Appearance.customFonts[.init(rawValue: userFont) ?? .body]
        }

        get {
            return self.userFontName
        }
    }
}
