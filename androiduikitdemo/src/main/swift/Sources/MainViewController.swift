//
//  ViewController.swift
//  iOSDemo
//
//  Created by Carlos Duclos on 7/19/18.
//

import Foundation

#if os(iOS)
import UIKit
#else
import Android
//import AndroidUIKit
#endif

final class MainViewController: UIViewController {
    
    private(set) weak var view1: UIView!
    
    private(set) weak var view2: UIView!
    
    private(set) weak var view3: UIView!
    
    private(set) weak var view4: UIView!
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    #if os(iOS)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    #endif
    
    //override var prefersStatusBarHidden: Bool { return true }
    
    override func loadView() {
        
        self.view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSLog("\(#function) \(view.frame)")
        
        view.backgroundColor = .blue
        
        let view1 = UIView(frame: CGRect(x: 20, y: 20,
                                         width: view.bounds.size.width - 40,
                                         height: view.bounds.size.height / 2.0))
        view1.autoresizingMask = [.flexibleWidth]
        view1.backgroundColor = .red
        view.addSubview(view1)
        self.view1 = view1
        
        let view2 = UIView(frame: CGRect(x: 10, y: 10,
                                         width: view1.bounds.size.width - 20,
                                         height: view1.bounds.size.height - 20))
        view2.autoresizingMask = [.flexibleWidth]
        view2.backgroundColor = .green
        view1.addSubview(view2)
        self.view2 = view2
        
        let view3 = UIView(frame: CGRect(x: 50, y: 50,
                                         width: view2.bounds.size.width - 100,
                                         height: view2.bounds.size.height - 100))
        view3.autoresizingMask = [.flexibleWidth]
        view3.backgroundColor = .yellow
        view2.addSubview(view3)
        self.view3 = view3
        
        let view4 = UIView(frame: CGRect(x: view1.frame.origin.x + 40,
                                         y: view1.frame.origin.y + view1.frame.size.height + 20,
                                         width: view1.frame.size.width - 80,
                                         height: 100))
        view4.autoresizingMask = [.flexibleWidth]
        view4.backgroundColor = .white
        view.addSubview(view4)
        self.view4 = view4
        
        printViews()
    }
    
    /*
    override func viewWillLayoutSubviews() {
        
        NSLog("\(#function) \(view.frame)")
        
        view1.frame = CGRect(x: 20, y: 20,
                             width: view.bounds.size.width - 40,
                             height: view.bounds.size.height / 2.0)
    }*/
    
    override func viewDidLayoutSubviews() {
        
        NSLog("\(#function)")
        
        printViews()
    }
    
    private func printViews() {
        
        NSLog("\(#function)")
        NSLog("View: \(view.frame)")
        NSLog("View1: \(view1.frame)")
        NSLog("View2: \(view2.frame)")
        NSLog("View3: \(view3.frame)")
        NSLog("View4: \(view4.frame)")
    }
    
    /*
    @objc func tapped(gesture: UITapGestureRecognizer) {
        print("tapped")
    }
    */
}
