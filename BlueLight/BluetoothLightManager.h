//
//  BluetoothLightManager.h
//  BlueLight
//
//  Created by Philipp Waldhauer on 24/12/14.
//
//
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "Led.h"

@class BluetoothLightManager;

@protocol BluetoothLightCommand <NSObject>

- (NSData*)bluetoothLightCommandData;

@end

@protocol BluetoothLightManagerDelegate <NSObject>

- (void)bluetoothLightManagerDidFindPeripheral:(BluetoothLightManager*)manager;
- (void)bluetoothLightManagerDidConnectPeripheral:(BluetoothLightManager*)manager;
- (void)bluetoothLightManagerDidDisconnectPeripheral:(BluetoothLightManager*)manager;
- (void)bluetoothLightManager:(BluetoothLightManager*)manager didUpdateRSSI:(NSNumber*)RSSI;

@end

@interface BluetoothLightManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (copy, nonatomic) NSString *name;
@property (weak, nonatomic) id<BluetoothLightManagerDelegate> delegate;

+ (instancetype)managerWithPeripheralName:(NSString*)name;

- (void)startScanningForPeripheral;

- (void)sendCommand:(id<BluetoothLightCommand>)command;

@end
