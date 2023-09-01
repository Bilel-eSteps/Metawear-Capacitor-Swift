export interface MetawearCapacitorPlugin {
	/**
	 * Connects to the metawear sensor.
	 */
	search(): Promise<null>;
	testFunc(data:DeviceOptions): Promise<null>;
	/**
	 * Connects to the metawear sensor.
	 */
	connect(data:DeviceOptions): Promise<null>;
	/**
	 * Disconnect metawear sensor.
	 */
	disconnect(): Promise<null>;
	/**
	 * Start accel and gryo data streaming and on-board logging.
	 */
	startData(): Promise<null>;
	/**
	 * Start accel data streaming and on-board logging. 
	 * 
	 * Listen in JS for the logging ID with:
	 * MetawearCapacitor.addListener('accelLogID', (logID) -> { ... });
	 * 
	 * Listen in JS with:
	 * MetawearCapacitor.addListener('accelData', (accel) => { ... });
	 */
	startAccelData(): Promise<null>;
	stopAccelData(): Promise<null>;
	/**
	 * Start gyro data streaming and on-board logging.
	 * 
	 * Listen in JS for the logging ID with:
	 * MetawearCapacitor.addListener('gyroLogID', (logID) -> { ... });
	 * 
	 * Listen in JS for data stream with:
	 * MetawearCapacitor.addListener('gyroData', (gyro) => { ... });
	 */
	startGyroData(): Promise<null>;
	stopGyroData(): Promise<null>;
	/**
	 * Stop data streaming and on-board logging.
	 */
	stopData(): Promise<null>;
	/**
	 * Downloads one of the two logs from the metawear sensor.
	 * 
	 * Listen in JS for the log data with:
	 * MetawearCapacitor.addListener('logData-ID', (logData) -> { ... });
	 * (logData["x"], logData["y"], logData["z"] are floats.)
	 * 
	 * Listen in JS for the log progress with:
	 * MetawearCapacitor.addListener('logProgress-ID', (progress) -> { ... });
	 * (progress["progress"] is a number between 0 and 1.)
	 * 
	 * Listen in JS for log finish with:
	 * MetawearCapacitor.addListener('logFinished-ID', () => { ... });
	 */
	downloadData(): Promise<null>;
	/**
	 * Stop on-board logging.
	 */
	stopLogs(): Promise<null>;
}
export interface DeviceOptions {
  freq?:number;
  name?:string;
  mac?:string;
}
