import Foundation
import UIKit
import SwiftUI

struct WrapperView: UIViewControllerRepresentable {
    var appDelegate: AppDelegate
    
    typealias UIViewControllerType = NewViewController
    @Binding var didFinishLoading: Bool

    func makeUIViewController(context: Context) -> NewViewController {
        let newVC = NewViewController.shared
        newVC.appDelegate = appDelegate
        newVC.didFinishLoading = {
            didFinishLoading = false
        }
        newVC.failOpen = {
            didFinishLoading = true
        }
        return newVC
    }
    
    func updateUIViewController(_ uiViewController: NewViewController, context: Context) {
    }
}
