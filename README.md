# metawear-capacitor

Capacitor plugin for metawear's swift sdk.

Used by the open-source app [kyntic](https://github.com/TheEnquirer/kyntic).

## Install

```bash
npm install metawear-capacitor
npx cap sync
```

## API

<docgen-index>

* [`search()`](#search)
* [`testFunc(...)`](#testfunc)
* [`connect(...)`](#connect)
* [`disconnect()`](#disconnect)
* [`startData()`](#startdata)
* [`startAccelData()`](#startacceldata)
* [`stopAccelData()`](#stopacceldata)
* [`startGyroData()`](#startgyrodata)
* [`stopGyroData()`](#stopgyrodata)
* [`stopData()`](#stopdata)
* [`downloadData()`](#downloaddata)
* [`stopLogs()`](#stoplogs)
* [Interfaces](#interfaces)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### search()

```typescript
search() => Promise<null>
```

Connects to the metawear sensor.

**Returns:** <code>Promise&lt;null&gt;</code>

--------------------


### testFunc(...)

```typescript
testFunc(data: DeviceOptions) => Promise<null>
```

| Param      | Type                                                    |
| ---------- | ------------------------------------------------------- |
| **`data`** | <code><a href="#deviceoptions">DeviceOptions</a></code> |

**Returns:** <code>Promise&lt;null&gt;</code>

--------------------


### connect(...)

```typescript
connect(data: DeviceOptions) => Promise<null>
```

Connects to the metawear sensor.

| Param      | Type                                                    |
| ---------- | ------------------------------------------------------- |
| **`data`** | <code><a href="#deviceoptions">DeviceOptions</a></code> |

**Returns:** <code>Promise&lt;null&gt;</code>

--------------------


### disconnect()

```typescript
disconnect() => Promise<null>
```

Disconnect metawear sensor.

**Returns:** <code>Promise&lt;null&gt;</code>

--------------------


### startData()

```typescript
startData() => Promise<null>
```

Start accel and gryo data streaming and on-board logging.

**Returns:** <code>Promise&lt;null&gt;</code>

--------------------


### startAccelData()

```typescript
startAccelData() => Promise<null>
```

Start accel data streaming and on-board logging. 

Listen in JS for the logging ID with:
MetawearCapacitor.addListener('accelLogID', (logID) -&gt; { ... });

Listen in JS with:
MetawearCapacitor.addListener('accelData', (accel) =&gt; { ... });

**Returns:** <code>Promise&lt;null&gt;</code>

--------------------


### stopAccelData()

```typescript
stopAccelData() => Promise<null>
```

**Returns:** <code>Promise&lt;null&gt;</code>

--------------------


### startGyroData()

```typescript
startGyroData() => Promise<null>
```

Start gyro data streaming and on-board logging.

Listen in JS for the logging ID with:
MetawearCapacitor.addListener('gyroLogID', (logID) -&gt; { ... });

Listen in JS for data stream with:
MetawearCapacitor.addListener('gyroData', (gyro) =&gt; { ... });

**Returns:** <code>Promise&lt;null&gt;</code>

--------------------


### stopGyroData()

```typescript
stopGyroData() => Promise<null>
```

**Returns:** <code>Promise&lt;null&gt;</code>

--------------------


### stopData()

```typescript
stopData() => Promise<null>
```

Stop data streaming and on-board logging.

**Returns:** <code>Promise&lt;null&gt;</code>

--------------------


### downloadData()

```typescript
downloadData() => Promise<null>
```

Downloads one of the two logs from the metawear sensor.

Listen in JS for the log data with:
MetawearCapacitor.addListener('logData-ID', (logData) -&gt; { ... });
(logData["x"], logData["y"], logData["z"] are floats.)

Listen in JS for the log progress with:
MetawearCapacitor.addListener('logProgress-ID', (progress) -&gt; { ... });
(progress["progress"] is a number between 0 and 1.)

Listen in JS for log finish with:
MetawearCapacitor.addListener('logFinished-ID', () =&gt; { ... });

**Returns:** <code>Promise&lt;null&gt;</code>

--------------------


### stopLogs()

```typescript
stopLogs() => Promise<null>
```

Stop on-board logging.

**Returns:** <code>Promise&lt;null&gt;</code>

--------------------


### Interfaces


#### DeviceOptions

| Prop       | Type                |
| ---------- | ------------------- |
| **`freq`** | <code>number</code> |
| **`name`** | <code>string</code> |
| **`mac`**  | <code>string</code> |

</docgen-api>
