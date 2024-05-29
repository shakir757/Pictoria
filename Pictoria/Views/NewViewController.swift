import Foundation
import UIKit
import WebKit
import CoreTelephony
import SnapKit
import SwiftUI

protocol RedirectDelegate {
    func attempted()
}

class NewViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    static let shared = NewViewController()
    var appDelegate: AppDelegate?
    var didFinishLoading: (() -> Void)?
    var failOpen: (() -> Void)?

    
    var someView = WKWebView()
    var lastVisited: String = ""
    var nextVisited: String = ""
    var isFirstPageOpening = true
    var isTestPageLoaded = false
    var someAddress = "https://www.google.com/"
    var timer = Timer()
    var redirectTimer = Timer()
    var isRedirected: Bool = false

    var delegate: RedirectDelegate?
    
    @State private var animatedLogo: Bool = false

    lazy var loading = UIHostingController(rootView: LoadingView(showed: $animatedLogo))
    
    var finishedLoading = false {
        didSet {
            if finishedLoading {
                loading.view.isHidden = true
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { _ in
            self.saveAction()
        })

        UserDefaults.standard.register(defaults: ["UserAgent" : "Mozilla/5.0 (Android 14; Mobile; rv:121.0) Gecko/121.0 Firefox/121.0"])
        
        print("Hi!")
        view.backgroundColor = .white
        let configuration = WKWebViewConfiguration()
        configuration.allowsPictureInPictureMediaPlayback = true

        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        configuration.allowsInlineMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = true
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        

        configuration.websiteDataStore = WKWebsiteDataStore.default()


        configuration.mediaTypesRequiringUserActionForPlayback = []
        someView = WKWebView(frame: .zero, configuration: configuration)
        self.view.addSubview(someView)

        someView.allowsLinkPreview = true
        someView.backgroundColor = .white
        someView.uiDelegate = self
        someView.navigationDelegate = self
        someView.allowsBackForwardNavigationGestures = true
        someView.translatesAutoresizingMaskIntoConstraints = false
        someView.configuration.userContentController.addUserScript(self.getZoomDisableScript())



        someView.evaluateJavaScript(
            "navigator.userAgent",
            completionHandler: { (result, error) in
                debugPrint(result as Any)
                debugPrint(error as Any)

                if let unwrappedUserAgent = result as? String {
                    print("userAgent: \(unwrappedUserAgent)")
                } else {
                    print("failed to get the user agent")
                }
            }
        )
        someView.evaluateJavaScript(
            "localStorage.setItem(\"newpage\", \"true\");",
            completionHandler: { (result, error) in
                debugPrint(result as Any)
                debugPrint(error as Any)
                
                if let unwrappedUserAgent = result as? String {
                    print("success")
                } else {
                    print("failed")
                }
            }
        )
        someView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36"
        setUpConstraints()
            print("END1 ")
        openSomeView(value: someAddress)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    }
    
    @objc func saveAction(){
        if let cookies = HTTPCookieStorage.shared.cookies {
            let cookiesData = try? NSKeyedArchiver.archivedData(withRootObject: cookies, requiringSecureCoding: false)
            UserDefaults.standard.set(cookiesData, forKey: "savedCookies")
        }
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
     if (error as NSError).code == -999 {
        return
     }
        print("ERROR \(error.localizedDescription)")
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        
        if let url = webView.url?.absoluteString{
            print("KJKJK url = \(url)")
            if someAddress == url {
            } else  {
                lastVisited = someAddress
                someAddress = url
                guard let url1 = URL(string: someAddress) else { return }
                
                if someAddress == "http://afsub.com/testpage" || someAddress == "http://afsub.com/testpage/" {
                    if isTestPageLoaded {
                    } else {
                        reInitWebView(url: someAddress)
                        isTestPageLoaded = true
                        
//                        someView.load(URLRequest(url: url1))
                    }
                } else {
                    someView.load(URLRequest(url: url1))
                }
            }
        }
    }
    

    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        
        print("LLL DECISION HANDLER \(navigationAction.request.url?.absoluteString)")
        
        if let url = navigationAction.request.url, let urlScheme = url.scheme?.lowercased() {
            if urlScheme != "https" && urlScheme != "http" {
                UIApplication.shared.open(url)
                decisionHandler(.allow)
                return
            }
        }
        if let url = navigationAction.request.url, url.absoluteString.contains("google.com") {
            isRedirected = true
            failOpen?()
        }
        
        if navigationAction.navigationType == WKNavigationType.linkActivated {
            if !webView.isLoading {
                webView.load(navigationAction.request)
            }
            decisionHandler(.allow)
                return
        }
        decisionHandler(.allow)
    }
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard
          navigationAction.targetFrame == nil,
          let url = navigationAction.request.url else {
            return nil
        }

        let request = URLRequest(url: url)
        webView.load(request)

        return nil
    }
    override func viewWillDisappear(_ animated: Bool) {
        saveCookies()
    }
    
    func isValidString(_ input: String) -> Bool {
        let pattern = #"^[a-zA-Z]+://[a-zA-Z]+$"#
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: input.utf16.count)
        return regex.firstMatch(in: input, options: [], range: range) != nil
    }
    
    private func getZoomDisableScript() -> WKUserScript {
        let source: String = "var meta = document.createElement('meta');" +
            "meta.name = 'viewport';" +
            "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
            "var head = document.getElementsByTagName('head')[0];" + "head.appendChild(meta);"
        return WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        view.backgroundColor = .white
        navigationController?.setNavigationBarHidden(true, animated: animated)

    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
              super.viewWillTransition(to: size, with: coordinator)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addChild(loading)
        view.addSubview(loading.view)
        view.bringSubviewToFront(loading.view)
        loading.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        loading.didMove(toParent: self)

        
        print("END4 ")

    }
    
    func setUpConstraints() {
        someView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
    }

    }
    func openSomeView(value: String) {
        if someAddress == "https://www.google.com/" {
            failOpen?()
        } else {
            print("KJKJK NO GOOGLE OPEN \(someAddress)")
            loadCookies()
                guard let url = URL(string: someAddress) else { return }
            print("END6 ")

            someView.load(URLRequest(url: url))
            print("END7 ")
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            saveCookies()
        print("KJKJK navigation \(navigation.debugDescription)")
        print("KJKJK NEWLINK NEWLINK")
        
        if !isRedirected {
            didFinishLoading?()
        }
        
        finishedLoading = true
        
        }
        
        func saveCookies() {
            if let cookies = HTTPCookieStorage.shared.cookies {
                
                let cookiesData = try? NSKeyedArchiver.archivedData(withRootObject: cookies, requiringSecureCoding: false)
                UserDefaults.standard.set(cookiesData, forKey: "savedCookies")
            }
        }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
    }
        
    func loadCookies() {
        if let cookiesData = UserDefaults.standard.data(forKey: "savedCookies"),
           let cookies = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(cookiesData) as? [HTTPCookie] {
            for cookie in cookies {
                print("\(cookie.value) ------ \(cookie.name)")
                HTTPCookieStorage.shared.setCookie(cookie)
            }
        }
    }
    
    
    func reInitWebView(url: String) {
        let configuration = WKWebViewConfiguration()
        configuration.allowsPictureInPictureMediaPlayback = true

        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        configuration.allowsInlineMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = true
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        

        configuration.websiteDataStore = WKWebsiteDataStore.default()


        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        someView = WKWebView(frame: .zero, configuration: configuration)
        self.view.addSubview(someView)
        someView.allowsLinkPreview = true
        someView.backgroundColor = .white
        someView.uiDelegate = self
        someView.navigationDelegate = self
        someView.allowsBackForwardNavigationGestures = true
        someView.translatesAutoresizingMaskIntoConstraints = false
        someView.configuration.userContentController.addUserScript(self.getZoomDisableScript())
        
        let script = "localStorage.setItem('yourKey', 'yourValue');"

        someView.evaluateJavaScript(
            "navigator.userAgent",
            completionHandler: { (result, error) in
                debugPrint(result as Any)
                debugPrint(error as Any)

                if let unwrappedUserAgent = result as? String {
                    print("userAgent: \(unwrappedUserAgent)")
                } else {
                    print("failed to get the user agent")
                }
            }
        )
        someView.evaluateJavaScript(
            "localStorage.setItem(\"newpage\", \"true\");",
            completionHandler: { (result, error) in
                debugPrint(result as Any)
                debugPrint(error as Any)
                
                if let unwrappedUserAgent = result as? String {
                    print("success")
                } else {
                    print("failed")
                }
            }
        )
        someView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36"
        setUpConstraints()
            print("END1 ")
        
        openSomeView(value: someAddress)
    }
    
    func startRedirectTimer() {
        // Создаем таймер, который будет запускать функцию timerAction каждые 3 секунды
        redirectTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: false)
        print("LLL Started")
    }
    
    @objc func timerAction() {
        if !isRedirected {

        }
    }
    
    func stopTimer() {
        redirectTimer.invalidate()
        print("LLL Attempted google")
        isRedirected = true
        failOpen?()
    }
    

}
