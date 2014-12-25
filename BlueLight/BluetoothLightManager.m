//
//  BluetoothLightManager.m
//  BlueLight
//
//  Created by Philipp Waldhauer on 24/12/14.
//
//

#import "BluetoothLightManager.h"

@interface BluetoothLightManager ()

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) CBPeripheral *discoveredPeripheral;
@property (strong, nonatomic) CBCharacteristic *characteristic;
@property (strong, nonatomic) NSMutableData *data;
@end

@implementation BluetoothLightManager

+ (instancetype)managerWithPeripheralName:(NSString *)name {
    BluetoothLightManager *manager = [[BluetoothLightManager alloc] init];
    manager.name = name;
    
    return manager;
}

- (void)startScanningForPeripheral {
    self.discoveredPeripheral = nil;
    self.characteristic = nil;
    
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    self.data = [NSMutableData data];
}

- (void)sendCommand:(id<BluetoothLightCommand>)command {
    if(!self.discoveredPeripheral) {
        return;
    }
    
    if(!self.characteristic) {
        return;
    }
    
    [self.discoveredPeripheral readRSSI];
    
    if(self.discoveredPeripheral.state != CBPeripheralStateConnected) {
        self.discoveredPeripheral = nil;
        if(self.delegate && [self.delegate respondsToSelector:@selector(bluetoothLightManagerDidDisconnectPeripheral:)]) {
            [self.delegate bluetoothLightManagerDidDisconnectPeripheral:self];
        }
        
        return;
    }
    
    [self.discoveredPeripheral writeValue:[command bluetoothLightCommandData] forCharacteristic:self.characteristic type:CBCharacteristicWriteWithoutResponse];
    [self.discoveredPeripheral readValueForCharacteristic:self.characteristic];
}

#pragma mark - Central manager delegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state != CBCentralManagerStatePoweredOn) {
        return;
    }
    
    if (central.state == CBCentralManagerStatePoweredOn) {
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
        NSLog(@"BluetoothManager: Scanning started");
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    NSLog(@"BluetoothManager: Discovered %@ at %@", peripheral.name, RSSI);
    
    if([peripheral.name isEqualToString:self.name]) {
        self.discoveredPeripheral = peripheral;
        [self.centralManager stopScan];
        
        self.discoveredPeripheral.delegate = self;
        [self.centralManager connectPeripheral:peripheral options:nil];
        
        NSLog(@"BluetoothManager: Connecting to peripheral %@, %@", peripheral, advertisementData);
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(bluetoothLightManagerDidFindPeripheral:)]) {
            [self.delegate bluetoothLightManagerDidFindPeripheral:self];
        }
    }
    
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if(self.delegate && [self.delegate respondsToSelector:@selector(bluetoothLightManagerDidDisconnectPeripheral:)]) {
        [self.delegate bluetoothLightManagerDidDisconnectPeripheral:self];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    self.discoveredPeripheral = peripheral;
    self.discoveredPeripheral.delegate = self;
    [self.discoveredPeripheral discoverServices:nil];
    [self.discoveredPeripheral readRSSI];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(bluetoothLightManagerDidConnectPeripheral:)]) {
        [self.delegate bluetoothLightManagerDidConnectPeripheral:self];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if(self.delegate && [self.delegate respondsToSelector:@selector(bluetoothLightManagerDidDisconnectPeripheral:)]) {
        [self.delegate bluetoothLightManagerDidDisconnectPeripheral:self];
    }
}

#pragma mark - Peripheral delegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error) {
        return;
    }
    
    
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        return;
    }
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        self.characteristic = characteristic;
        
        if((CBCharacteristicPropertyWriteWithoutResponse & characteristic.properties) == CBCharacteristicPropertyWriteWithoutResponse) {
            NSLog(@"BluetoothManager: Has CBCharacteristicPropertyWriteWithoutResponse");
        }
        
        if((CBCharacteristicPropertyWrite & characteristic.properties) == CBCharacteristicPropertyWrite) {
            NSLog(@"BluetoothManager: Has CBCharacteristicPropertyWrite");
        }
        
        if((CBCharacteristicPropertyRead & characteristic.properties) == CBCharacteristicPropertyRead) {
            NSLog(@"BluetoothManager: Has CBCharacteristicPropertyRead");
        }
 
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"BluetoothManager: didUpdateValueForCharacteristic: %@", characteristic.value);
}


- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"BluetoothManager: didWriteValueForCharacteristic");
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    if(self.delegate && [self.delegate respondsToSelector:@selector(bluetoothLightManager:didUpdateRSSI:)]) {
        [self.delegate bluetoothLightManager:self didUpdateRSSI:RSSI];
    }
}





@end
