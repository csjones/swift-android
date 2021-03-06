//
//  MainActivity.swift
//  swiftandroid
//
//  Created by Marco Estrella on 5/21/18.
//

import Foundation

import java_swift
import java_lang
import java_util
import Android

/// Needs to be implemented by app.
@_silgen_name("SwiftAndroidMainActivity")
public func SwiftAndroidMainActivity() -> SwiftSupportAppCompatActivity.Type {
    NSLog("Swift \(#function)")
    return MainActivity.self
}

// Like AppDelegate in iOS
final class MainActivity: SwiftSupportAppCompatActivity {
    
    override func onCreate(savedInstanceState: Android.OS.Bundle?) {
        
        NSLog("Swift \(#function)")
    }
    
    override func onResume() {
        
        NSLog("Swift \(#function)")
    }
    
    override func onPause() {
        
        NSLog("Swift \(#function)")
    }
    
    override func onRequestPermissionsResult(requestCode: Int, permissions: [String], grantResults: [Int]) {
        
        NSLog("Swift \(#function)")
    }
}

final class SwiftBluetoothScannerBinding_ListenerImpl: SwiftBluetoothScannerBinding_ListenerBase {
    
    // one-off call to bind the Java and Swift sections of app
    @_silgen_name("Java_com_millertechnology_android_MainActivity_bind")
    public static func bind( __env: UnsafeMutablePointer<JNIEnv?>, __this: jobject?, __self: jobject? )-> jobject? {
        
        // This Swift instance forwards to Java through JNI
        let responder = SwiftBluetoothScannerBinding_ResponderForward( javaObject: __self )
        
        // This Swift instance receives native calls from Java
        var locals = [jobject]()
        return SwiftBluetoothScannerBinding_ListenerImpl(responder: responder).localJavaObject( &locals )
    }
    
    let responder: SwiftBluetoothScannerBinding_ResponderForward
    
    private lazy var layoutInflater: Android.View.LayoutInflater = Android.View.LayoutInflater(casting: self.responder.getLayoutInflater())!
    
    private lazy var listAdapter: ListAdapter = ListAdapter(layoutInflater: self.layoutInflater,
                                                            cellResource: self.responder.getCellResource(),
                                                            textViewResource: self.responder.getTextViewResource())
    
    private var data = [Android.Bluetooth.LE.ScanResult]() {
        
        didSet {
            NSLog("\(type(of: self)): \(#function)")
            
        }
    }
    
    init(responder: SwiftBluetoothScannerBinding_ResponderForward) {
        
        NSLog("\(type(of: self)): \(#function)")
        
        self.responder = responder
    }
    
    deinit {
        
        NSLog("\(type(of: self)): \(#function)")
    }
    
    override func viewDidLoad() {
        
        NSLog("\(type(of: self)): \(#function)")
        
        listAdapter.withJavaObject { [unowned self] in
            self.responder.setAdapter(adapter: JavaObject(javaObject: $0))
        }
 
        let scanCallback = ScanCallback { [weak self] in
            
            self?.listAdapter.data.append($0)
            
            // FIXME: Properly refresh list view
            self?.listAdapter.withJavaObject {
                self?.responder.setAdapter(adapter: JavaObject(javaObject: $0))
            }
        }
        
        Android.Bluetooth.Adapter.default?.lowEnergyScanner?.startScan(callback: scanCallback)
        
        Android.Bluetooth.Adapter.default?.lowEnergyScanner?.stopScan(callback: scanCallback)
        /*
        let scanCallback = ScanCallback { [weak self] in
            NSLog("\(type(of: self)): \(#function)")
            self?.data.append($0)
        }
        // = Android.Bluetooth.LE.ScanSettings.Builder().build()
        Android.Bluetooth.Adapter.default?.lowEnergyScanner?.startScan(callback: scanCallback)
        */
    }
}

extension SwiftBluetoothScannerBinding_ListenerImpl {
    
    struct ScanCallback: Android.Bluetooth.LE.ScanCallback {
        
        var scanResult: (Android.Bluetooth.LE.ScanResult) -> ()
        
        func onScanResult(callbackType: Android.Bluetooth.LE.ScanCallbackType, result: Android.Bluetooth.LE.ScanResult) {
            
            scanResult(result)
            
            NSLog("\(#function) \(result.device.address)")
        }
        
        func onScanFailed(error: AndroidBluetoothLowEnergyScanCallback.Error) {
            
            NSLog("\(#function) \(error)")
        }
        
        func onBatchScanResults(results: [Android.Bluetooth.LE.ScanResult]) {
            
            NSLog("\(#function) \(results.count)")
        }
    }
}

extension SwiftBluetoothScannerBinding_ListenerImpl {
    
    class ListAdapter: Android.Widget.BaseAdapter {
        
        var layoutInflater: Android.View.LayoutInflater? = nil
        
        var cellResource: Int = 0
        
        var textViewResource: Int = 0
        
        public convenience init(layoutInflater: Android.View.LayoutInflater,
             cellResource: Int,
             textViewResource: Int) {
            
            self.init(javaObject: nil)
            self.bindNewJavaObject()
            
            self.layoutInflater = layoutInflater
            self.cellResource = cellResource
            self.textViewResource = textViewResource
        }
        
        public required init(javaObject: jobject?){
            super.init(javaObject: javaObject)
        }
        
        var data = [Android.Bluetooth.LE.ScanResult]() {
            
            didSet {
                NSLog("\(type(of: self)): \(#function)")
                self.notifyDataSetChanged()
            }
        }
        
        override func getCount() -> Int {
            
            NSLog("\(type(of: self)): \(#function)")
            
            return data.count
        }
        
        override func getView(position row: Int, convertView: Android.View.View?, parent: Android.View.ViewGroup) -> Android.View.View {
            
            NSLog("\(type(of: self)): \(#function)")
            
            let itemViewId = Android.R.Layout.init(rawValue: cellResource)
            
            let view: Android.View.View = /* convertView ?? */ layoutInflater!.inflate(resource: itemViewId,
                                                                                      root: parent,
                                                                                      attachToRoot: false)
            
            //NSLog("view.")
            
            guard let textViewObject = view.findViewById(textViewResource)
                else { fatalError("No view for \(textViewResource)") }
            
            let textView = Android.Widget.TextView(casting: textViewObject)
            
            let item = self.data[row]
            
            textView?.text = item.device.address.description
            
            return view
        }
    }
}
