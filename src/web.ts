import { WebPlugin } from '@capacitor/core';

import type { DeviceOptions, MetawearCapacitorPlugin } from './definitions';

export class MetawearCapacitorWeb
	extends WebPlugin
	implements MetawearCapacitorPlugin {
		constructor() {
			super();
		}
	async startAccelData(): Promise<null> {
		throw new Error('Method not implemented.');
	}
	async stopAccelData(): Promise<null> {
		throw new Error('Method not implemented.');
	}
	async testFunc(data?:DeviceOptions): Promise<null> {
		throw new Error('Method not implemented.');
	}
	async search(): Promise<null> {
		throw new Error('Method not implemented.');
	}
	async startGyroData(): Promise<null> {
		throw new Error('Method not implemented.');
	}
	async stopGyroData(): Promise<null> {
		throw new Error('Method not implemented.');
	}
	async startData(): Promise<null> {
		throw new Error('Method not implemented.');
	}
	async stopData(): Promise<null> {
		throw new Error('Method not implemented.');
	}
	async connect(data?:DeviceOptions): Promise<null> {
		throw new Error('Method not implemented.');
	}
	async connectSensor1(data?:DeviceOptions): Promise<null> {
		throw new Error('Method not implemented.');
	}
	async connectSensor2(data?:DeviceOptions): Promise<null> {
		throw new Error('Method not implemented.');
	}
	async disconnect(): Promise<null> {
		throw new Error('Method not implemented.');
	}
	async downloadData(): Promise<null> {
		throw new Error('Method not implemented.');
	}
	async stopLogs(): Promise<null> {
		throw new Error('Method not implemented.');
	}
}
const Metawear = new MetawearCapacitorWeb();
export { Metawear };