
/// generated by: genswift.java 'java/lang|java/util|java/sql' 'Sources' '../java' ///

/// interface com.johnholdsworth.swiftbindings.DevicesActivityBinding$Listener ///

package org.swiftjava.com_johnholdsworth;

@SuppressWarnings("JniMissingFunction")
public class DevicesActivityBinding_ListenerProxy implements com.johnholdsworth.swiftbindings.DevicesActivityBinding.Listener {

    // address of proxy object
    long __swiftObject;

    DevicesActivityBinding_ListenerProxy( long __swiftObject ) {
        this.__swiftObject = __swiftObject;
    }

    /// public abstract void com.johnholdsworth.swiftbindings.DevicesActivityBinding$Listener.connectToDevice(java.lang.Object,java.lang.Object)

    public native void __connectToDevice( long __swiftObject, java.lang.Object context, java.lang.Object device );

    public void connectToDevice( java.lang.Object context, java.lang.Object device ) {
        __connectToDevice( __swiftObject, context, device );
    }

    /// public abstract void com.johnholdsworth.swiftbindings.DevicesActivityBinding$Listener.startScan()

    public native void __startScan( long __swiftObject );

    public void startScan() {
        __startScan( __swiftObject  );
    }

    /// public abstract void com.johnholdsworth.swiftbindings.DevicesActivityBinding$Listener.stopScan()

    public native void __stopScan( long __swiftObject );

    public void stopScan() {
        __stopScan( __swiftObject  );
    }

    /// public abstract void com.johnholdsworth.swiftbindings.DevicesActivityBinding$Listener.validateBluetooth()

    public native void __validateBluetooth( long __swiftObject );

    public void validateBluetooth() {
        __validateBluetooth( __swiftObject  );
    }

    public native void __finalize( long __swiftObject );

    public void finalize() {
        __finalize( __swiftObject );
    }

}
