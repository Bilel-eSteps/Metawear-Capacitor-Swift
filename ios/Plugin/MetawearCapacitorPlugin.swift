/**
    Made by Nicholas Assaderaghi for Kyntic, 2021-2022.
*/

import Foundation
import Capacitor
import MetaWear
import MetaWearCpp

@objc(MetawearCapacitorPlugin)
public class MetawearCapacitorPlugin: CAPPlugin {
    
    private var sensor: MetaWear? = nil
    private var sensor2: MetaWear? = nil
    private var accelSignal: OpaquePointer? = nil
    private var accelSignal2: OpaquePointer? = nil
    private var gyroSignal: OpaquePointer? = nil
    
    private var currentLogID: String = ""
    private var mac:String = ""
    private var mac2:String = ""
    private var finishedDownloadingGyro = false
    private var finishedDownloadingAccel = false

    override public func load() {
        
    }
    @objc func connect(_ call: CAPPluginCall) {
        print("Swift: Connect called.")
        if (call.getString("mac") == nil)
        {
            print("Swift: Mac adress undefined.")
            call.resolve()
            }
        self.mac = call.getString("mac") ?? ""
        print("Swift: device mac adress called.",mac)
        self.connect()
        call.resolve()
    }
    @objc func connectSensor1(_ call: CAPPluginCall) {
        print("Swift: Connect called.")
        if (call.getString("mac") == nil)
        {
            print("Swift: Mac adress undefined.")
            call.resolve()
            }
        self.mac = call.getString("mac") ?? ""
        print("Swift: device mac adress called.",mac)
        self.connectSensor1()
        call.resolve()
    }
    @objc func connectSensor2(_ call: CAPPluginCall) {
        print("Swift: Connect called.")
        if (call.getString("mac") == nil)
        {
            print("Swift: Mac adress undefined.")
            call.resolve()
            }
        self.mac2 = call.getString("mac") ?? ""
        print("Swift: device mac adress called.",mac2)
        self.connectSensor2()
        call.resolve()
    }
    @objc func disconnect(_ call: CAPPluginCall) {
        print("Swift: Disconnect called.")
        if (self.sensor != nil)
        {
            self.sensor!.cancelConnection()
            self.sensor = nil
        }
        call.resolve()
    }
    
    @objc func startData(_ call: CAPPluginCall) {
        print("Swift: StartData called.")
        self.startGyroData()
        self.startAccelData()
        call.resolve()
    }
    @objc func testFunc(_ call: CAPPluginCall) {
        //print("Swift: called test.",call.getString("name"))
        
        call.resolve()
    }
    
    @objc func startAccelData(_ call: CAPPluginCall) {
        print("Swift: StartAccelData called.")
        self.startAccelData()
        call.resolve()
    }
    @objc func stopAccelData(_ call: CAPPluginCall) {
        print("Swift: StartAccelData called.")
        self.stopAccelData()
        call.resolve()
    }

    @objc func startGyroData(_ call: CAPPluginCall) {
        print("Swift: StartGyroData called.")
        self.startGyroData()
        call.resolve()
    }
    @objc func stopGyroData(_ call: CAPPluginCall) {
        print("Swift: StartGyroData called.")
        self.stopGyroData()
        call.resolve()
    }
    
    @objc func stopData(_ call: CAPPluginCall) {
        print("Swift: StopData called.")
        self.stopAccelData()
        self.stopGyroData()
        call.resolve()
    }
    
    @objc func downloadData(_ call: CAPPluginCall) {
        print("Swift: DownloadData called.")
        self.newGetLogData()
        call.resolve()
    }
    
    @objc func stopLogs(_ call: CAPPluginCall) {
        print("Swift: StopLogs called.")
        self.stopLogging()
        call.resolve()
    }
     @objc func search(_ call: CAPPluginCall){
        print("Swift: StopLogs called.")
        self.search()
        call.resolve()
    }
    func search(){
        print("Swift: Searching for devices")
        if sensor != nil
        {
            print("Swift: silly JS, we're already connected!")
            self.notifyListeners("successfulConnection", data: nil) // JS is being silly, we are already connected :D
            return
        }
        MetaWearScanner.shared.startScan(allowDuplicates: false) { (device) in
           // MetaWearScanner.shared.stopScan()
        print(device)
            self.notifyListeners("deviceFound", data: ["device": device.mac])
        }
    }
    func connect() {
        print("Swift: time to connect!")
        if sensor != nil
        {
            print("Swift: silly JS, we're already connected!")
            self.notifyListeners("successfulConnection", data: nil) // JS is being silly, we are already connected :D
            return
        }
        MetaWearScanner.shared.startScan(allowDuplicates: false) { (device) in
            // sensor found
            MetaWearScanner.shared.stopScan() // stop searching for the sensor
            // Connect to the board we found
            if (device.mac == self.mac) {
            device.connectAndSetup().continueWith { t in
                if let error = t.error {
                    // Error while trying to connect
                    print("Swift: Device found, but could not be connected to: ")
                    print(error)
                    self.notifyListeners("unsuccessfulConnection", data: ["error": error])
                } else {
                    print("Swift: Device successfully connected to!")
                    self.sensor = device // so we can use it in the future
                    self.notifyListeners("successfulConnection", data: nil) // so js can respond to sensor connecting
                    
                    // Flash sensor LED blue to indicate successful connection
                    var pattern = MblMwLedPattern()
                    mbl_mw_led_load_preset_pattern(&pattern, MBL_MW_LED_PRESET_PULSE)
                    mbl_mw_led_stop_and_clear(device.board)
                    mbl_mw_led_write_pattern(device.board, &pattern, MBL_MW_LED_COLOR_RED)
                    mbl_mw_led_play(device.board)
                    mbl_mw_settings_set_connection_parameters(device.board, 7.5, 15, 0, 20000); // set the connection interval to extremely small (fast connection for log downloads)
                    mbl_mw_acc_set_odr(device.board, 100) // accel will sample 100hz
                    mbl_mw_acc_set_range(device.board, 16)
                    mbl_mw_gyro_bmi160_set_odr(device.board, MBL_MW_GYRO_BOSCH_ODR_100Hz) // gyro will sample 100hz
                }
            }
          }
        }
    }
    
    /**Start acceleration data stream and start logging acceleration data on-board.*/
    func startAccelData() {
        mbl_mw_logging_clear_entries(self.sensor!.board)
        mbl_mw_logging_clear_entries(self.sensor2!.board)
        // get signal
        let signal = mbl_mw_acc_get_acceleration_data_signal(self.sensor!.board)
        self.accelSignal = signal
        
        let signal2 = mbl_mw_acc_get_acceleration_data_signal(self.sensor2!.board)
        self.accelSignal2 = signal2
        
        // https://stackoverflow.com/questions/33260808/how-to-use-instance-method-as-callback-for-function-which-takes-only-func-or-lit
        let observer = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        
        // start log sensor 1
       
        mbl_mw_datasignal_log(self.accelSignal, observer) { observer, logger in
                // callback for starting log, gives us info about the log
                let mySelf = Unmanaged<MetawearCapacitorPlugin>.fromOpaque(observer!).takeUnretainedValue() // get back self
                print("Swift: Accel Log Num ID: \(mbl_mw_logger_get_id(logger))")
                let cString = mbl_mw_logger_generate_identifier(logger)!
                // the identifier is always "acceleration"
                let identifier = String(cString: cString)
                print("Swift: Accel Log String ID: \(identifier)")
                let timestamp = NSDate().timeIntervalSince1970
                mySelf.notifyListeners("accelLogID", data: ["ID": identifier, "time": timestamp])
            }
        // start log sensor 1
       // mbl_mw_datasignal_log(self.accelSignal2, observer) { observer, logger in
                // callback for starting log, gives us info about the log
         //       let mySelf = Unmanaged<MetawearCapacitorPlugin>.fromOpaque(observer!).takeUnretainedValue() // get back self
           //     print("Swift: Accel 2 Log Num ID: \(mbl_mw_logger_get_id(logger))")
             //   let cString = mbl_mw_logger_generate_identifier(logger)!
                // the identifier is always "acceleration"
               // let identifier = String(cString: cString)
               // print("Swift: Accel 2 Log String ID: \(identifier)")
               // let timestamp = NSDate().timeIntervalSince1970
                //mySelf.notifyListeners("accelLogID2", data: ["ID": identifier, "time": timestamp])
            //}
        mbl_mw_logging_start(self.sensor!.board, 1) // second param is nonzero to overwrite older log entries
        mbl_mw_logging_start(self.sensor2!.board, 1) // second param is nonzero to overwrite older log entries
        // subscribe to data stream
        mbl_mw_datasignal_subscribe(self.accelSignal, observer) { observer, data in
            // callback for each datapoint we get
            let obj: MblMwCartesianFloat = data!.pointee.valueAs() // convert to tuple of floats
            let mySelf = Unmanaged<MetawearCapacitorPlugin>.fromOpaque(observer!).takeUnretainedValue() // get back self
            let accelStr = String(format:"(%f,%f,%f),", obj.x, obj.y, obj.z)
            print("Swift: accel: " + accelStr) // print accel data to console
            mySelf.notifyListeners("accelDataSensor1", data: ["x": obj.x, "y": obj.y, "z": obj.z]) // give accel data to js
        }
        mbl_mw_datasignal_subscribe(self.accelSignal2, observer) { observer, data in
            // callback for each datapoint we get
            let obj: MblMwCartesianFloat = data!.pointee.valueAs() // convert to tuple of floats
            let time: Int64 = data!.pointee.epoch // convert to tuple of floats
            let mySelf = Unmanaged<MetawearCapacitorPlugin>.fromOpaque(observer!).takeUnretainedValue() // get back self
            let accelStr = String(format:"(%f,%f,%f),", obj.x, obj.y, obj.z)
            print("Swift: accel: " + accelStr) // print accel data to console
            mySelf.notifyListeners("accelDataSensor2", data: ["x": obj.x, "y": obj.y, "z": obj.z,"time":time]) // give accel data to js
        }
        
        // turn on accel on sensor
        mbl_mw_acc_enable_acceleration_sampling(self.sensor!.board)
        mbl_mw_acc_start(self.sensor!.board)
        // turn on accel on sensor 2
        mbl_mw_acc_enable_acceleration_sampling(self.sensor2!.board)
        mbl_mw_acc_start(self.sensor2!.board)
     }
    
    /**Start gyroscope data stream and start logging gyroscope data on-board.*/
    func startGyroData() {
        let signal = mbl_mw_gyro_bmi160_get_rotation_data_signal(self.sensor!.board)
        self.gyroSignal = signal
        
        // https://stackoverflow.com/questions/33260808/how-to-use-instance-method-as-callback-for-function-which-takes-only-func-or-lit
        let observer = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        
        // start log
        mbl_mw_datasignal_log(self.gyroSignal, observer) { observer, logger in
                // callback for starting log, gives us info about the log
                let mySelf = Unmanaged<MetawearCapacitorPlugin>.fromOpaque(observer!).takeUnretainedValue() // get back self
                print("Swift: Gyro Log Num ID: \(mbl_mw_logger_get_id(logger))")
                let cString = mbl_mw_logger_generate_identifier(logger)!
                // the identifier is always "angular-velocity"
                let identifier = String(cString: cString)
                print("Swift: Gyro Log String ID: \(identifier)")
                let timestamp = NSDate().timeIntervalSince1970
                mySelf.notifyListeners("gyroLogID", data: ["ID": identifier, "time": timestamp])
            }
        mbl_mw_logging_start(self.sensor!.board, 1) // second param is nonzero to overwrite older log entries
        
        // subscribe to data stream
        mbl_mw_datasignal_subscribe(self.gyroSignal, observer) { observer, data in
            // callback for each datapoint we get
            let obj: MblMwCartesianFloat = data!.pointee.valueAs() // convert to tuple of floats
            let mySelf = Unmanaged<MetawearCapacitorPlugin>.fromOpaque(observer!).takeUnretainedValue() // get back self
            let gyroStr = String(format:"(%f,%f,%f),", obj.x, obj.y, obj.z)
            print("Swift: gyro: " + gyroStr) // print gyro data to console
            mySelf.notifyListeners("gyroData", data: ["x": obj.x, "y": obj.y, "z": obj.z]) // give gyro data to js
        }
        
        // turn on gyro on sensor
        mbl_mw_gyro_bmi160_enable_rotation_sampling(self.sensor!.board)
        mbl_mw_gyro_bmi160_start(self.sensor!.board)
    }
    
    /** Download 1 log off of device. */
    func newGetLogData() {
        let observer = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
            mbl_mw_metawearboard_create_anonymous_datasignals(self.sensor!.board, observer) { observer, board, signals, numSignals in
            print("Swift: number of downloadable logs: \(numSignals)")
            if numSignals > 0
            {
                let buffer = UnsafeBufferPointer(start: signals, count: Int(numSignals));
                let signalPointersArr = Array(buffer)
                signalPointersArr.forEach {
                    let mySelf = Unmanaged<MetawearCapacitorPlugin>.fromOpaque(observer!).takeUnretainedValue()
                    let cString = mbl_mw_anonymous_datasignal_get_identifier($0)!
                    let identifier = String(cString: cString)
                    if (identifier == "angular-velocity" && mySelf.finishedDownloadingGyro == false) || (identifier == "acceleration" && mySelf.finishedDownloadingAccel == false)
                    {
                        print("Swift: downloading log \(identifier)")
                        mySelf.currentLogID = identifier
                        mbl_mw_anonymous_datasignal_subscribe($0, observer) { context, data in
                            let obj: MblMwCartesianFloat = data!.pointee.valueAs()
                            let mySelf = Unmanaged<MetawearCapacitorPlugin>.fromOpaque(context!).takeUnretainedValue()
                            mySelf.notifyListeners("logData-download", data: ["x": obj.x, "y": obj.y, "z": obj.z])
                        }
                        var handlers = MblMwLogDownloadHandler()
                        handlers.context = observer
                        handlers.received_progress_update = { (ctx, remainingEntries, totalEntries) in
                            let mySelf = Unmanaged<MetawearCapacitorPlugin>.fromOpaque(ctx!).takeUnretainedValue() // get back self
                            let progress = Double(totalEntries - remainingEntries) / Double(totalEntries)
                            print("Swift: Log download progress: \(progress)")
                            mySelf.notifyListeners("logProgress", data: ["progress": progress])
                            if remainingEntries == 0 {
                                print("Swift: Done downloading log :D")
                                mySelf.notifyListeners("logFinished", data: nil)
                                if mySelf.currentLogID == "angular-velocity"
                                {
                                    mySelf.finishedDownloadingGyro = true
                                }
                                else if mySelf.currentLogID == "acceleration"
                                {
                                    mySelf.finishedDownloadingAccel = true
                                }
                                mySelf.currentLogID = ""
                            }
                        }
                        handlers.received_unknown_entry = { (context, id, epoch, data, length) in
                            print("Swift: received_unknown_entry when downloading log")
                        }
                        handlers.received_unhandled_entry = { (context, data) in
                            print("Swift: received_unhandled_entry when downloading log")
                        }
                        mbl_mw_logging_download(mySelf.sensor!.board, 255, &handlers)
                    }
                }
            }
        }
        print("Swift: made callbacks for downloading logs.")
    }
    
    // DEPRECATED, newGetLogData is now used instead.
    
//    /**Given log IDs, download log data.**/
//    func getLogData(ID: String) {
//        self.currentLogID = ID
//        let log = mbl_mw_logger_lookup_id(self.sensor!.board, UInt8(Int(ID)!))
//
//        print("Swift: Yo here's the pointer to the log object: \(String(describing: log))")
//
//        mbl_mw_logging_stop(self.sensor!.board)
//
//        let observer = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
//
//        mbl_mw_logger_subscribe(log, observer, { (observer, data) in
//            let obj: MblMwCartesianFloat = data!.pointee.valueAs()
//            let mySelf = Unmanaged<MetawearCapacitorPlugin>.fromOpaque(observer!).takeUnretainedValue() // get back self
//            mySelf.notifyListeners("logData-\(mySelf.currentLogID)", data: ["x": obj.x, "y": obj.y, "z": obj.z]) // give log data point to js
//        })
//
//        var handlers = MblMwLogDownloadHandler()
//        handlers.context = Unmanaged.passRetained(self).toOpaque()
//        handlers.received_progress_update = { (observer, remainingEntries, totalEntries) in
//            let mySelf = Unmanaged<MetawearCapacitorPlugin>.fromOpaque(observer!).takeUnretainedValue() // get back self
//            let progress = Double(totalEntries - remainingEntries) / Double(totalEntries)
//            print("Swift: Log download progress: \(progress)")
//            if remainingEntries == 0 {
//                print("Swift: Done downloading log :D")
//                mySelf.notifyListeners("logFinished-\(mySelf.currentLogID)", data: nil)
//                mySelf.currentLogID = ""
//            }
//        }
//        handlers.received_unknown_entry = { (context, id, epoch, data, length) in
//            print("Swift: received_unknown_entry when downloading log")
//        }
//        handlers.received_unhandled_entry = { (context, data) in
//            print("Swift: received_unhandled_entry when downloading log")
//        }
//        mbl_mw_logging_download(self.sensor!.board, 100, &handlers)
//    }
    
    func stopAccelData() {
        //sensor 1
        mbl_mw_acc_stop(self.sensor!.board)
        mbl_mw_acc_disable_acceleration_sampling(self.sensor!.board)
        mbl_mw_datasignal_unsubscribe(self.accelSignal!)
        //sensor 2
        mbl_mw_acc_stop(self.sensor2!.board)
        mbl_mw_acc_disable_acceleration_sampling(self.sensor2!.board)
        mbl_mw_datasignal_unsubscribe(self.accelSignal2!)

    }
    
    func stopGyroData() {
        mbl_mw_gyro_bmi160_stop(self.sensor!.board)
        mbl_mw_gyro_bmi160_disable_rotation_sampling(self.sensor!.board)
        mbl_mw_datasignal_unsubscribe(self.gyroSignal!)
    }
    
    func stopLogging() {
        mbl_mw_logging_stop(self.sensor!.board)
    }
    func connectSensor1() {
        print("Swift: time to connect!")
        if sensor != nil
        {
            print("Swift: silly JS, we're already connected!")
            self.notifyListeners("successfulConnection", data: nil) // JS is being silly, we are already connected :D
            return
        }
        MetaWearScanner.shared.startScan(allowDuplicates: false) { (device) in
            // sensor found
            
            // Connect to the board we found
            print("received",self.mac)
            print("found",device.mac)
            self.notifyListeners("searching", data: ["mac": device.mac])
            if (device.mac == self.mac) {
                MetaWearScanner.shared.stopScan() // stop searching for the sensor
            device.connectAndSetup().continueWith { t in
                if let error = t.error {
                    // Error while trying to connect
                    print("Swift: Device found, but could not be connected to: ")
                    print(error)
                    self.notifyListeners("unsuccessfulConnection", data: ["error": error])
                } else {
                    print("Swift: Device successfully connected to!")
                    self.sensor = device // so we can use it in the future
                    mbl_mw_settings_set_tx_power(device.board,4)
                    print("Swift: Device info !",device.info)
                    self.notifyListeners("successfulConnection", data: ["msg": "Device 1 successfully connected "]) // so js can respond to sensor connecting
                    
                    // Flash sensor LED blue to indicate successful connection
                    var pattern = MblMwLedPattern()
                    mbl_mw_led_load_preset_pattern(&pattern, MBL_MW_LED_PRESET_PULSE)
                    mbl_mw_led_stop_and_clear(device.board)
                    mbl_mw_led_write_pattern(device.board, &pattern, MBL_MW_LED_COLOR_BLUE)
                    mbl_mw_led_play(device.board)
                    mbl_mw_settings_set_connection_parameters(device.board, 7.5, 15, 0, 20000); // set the connection interval to extremely small (fast connection for log downloads)
                    mbl_mw_acc_set_odr(device.board, 100) // accel will sample 100hz
                    mbl_mw_gyro_bmi160_set_odr(device.board, MBL_MW_GYRO_BOSCH_ODR_100Hz) // gyro will sample 100hz
                }
            }
          }
        }
    }
    func connectSensor2() {
        print("Swift: time to connect!")
        if sensor2 != nil
        {
            print("Swift: silly JS, we're already connected!")
            //self.notifyListeners("successfulConnection", data: ["msg": "Device 1 successfully connected "]) // JS is being silly, we are already connected :D
            return
        }
        MetaWearScanner.shared.startScan(allowDuplicates: false) { (device) in
            // sensor found
           
            // Connect to the board we found
            self.notifyListeners("searching", data: ["mac": device.mac])
            if (device.mac == self.mac2) {
                MetaWearScanner.shared.stopScan() // stop searching for the sensor
            device.connectAndSetup().continueWith { t in
                if let error = t.error {
                    // Error while trying to connect
                    print("Swift: Device found, but could not be connected to: ")
                    print(error)
                    self.notifyListeners("unsuccessfulConnection", data: ["error": error])
                } else {
                    print("Swift: Device successfully connected to!")
                    self.sensor2 = device // so we can use it in the future
                    self.notifyListeners("successfulConnection", data: nil) // so js can respond to sensor connecting
                    mbl_mw_settings_set_tx_power(device.board,4)
                    print("Swift: Device info !",device.info)
                    // Flash sensor LED blue to indicate successful connection
                    var pattern = MblMwLedPattern()
                    mbl_mw_led_load_preset_pattern(&pattern, MBL_MW_LED_PRESET_PULSE)
                    mbl_mw_led_stop_and_clear(device.board)
                    mbl_mw_led_write_pattern(device.board, &pattern, MBL_MW_LED_COLOR_RED)
                    mbl_mw_led_play(device.board)
                    mbl_mw_settings_set_connection_parameters(device.board, 7.5, 15, 0, 20000); // set the connection interval to extremely small (fast connection for log downloads)
                    mbl_mw_acc_set_odr(device.board, 100) // accel will sample 100hz
                    mbl_mw_gyro_bmi160_set_odr(device.board, MBL_MW_GYRO_BOSCH_ODR_100Hz) // gyro will sample 100hz
                }
            }
          }
        }
    }
}
