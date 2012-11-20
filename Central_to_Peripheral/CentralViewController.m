//
//  CentralViewController.m
//  MD_Peripheral_iOS
//
//  Created by Christian Giordano on 14/11/2012.
//  Copyright (c) 2012 Christian Giordano. All rights reserved.
//

#import "CentralViewController.h"

@interface CentralViewController ()<CBCentralManagerDelegate,CBPeripheralDelegate>
{
    CBCentralManager *_manager;
    CBPeripheral *_peripheral;
}

@end

@implementation CentralViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _manager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    [self log:[NSString stringWithFormat:@"%@ with state = %i", NSStringFromSelector(_cmd), central.state]];
    
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            [_manager scanForPeripheralsWithServices:nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : [NSNumber numberWithBool:YES] }];
            break;
            
        default:
//            NSLog(@"%i",central.state);
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)aPeripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if ([RSSI floatValue]>=-45.0f)
    {
        [self log:@"Greater than 45"];
        [_manager stopScan];
        _peripheral = aPeripheral;
        [central connectPeripheral:_peripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self log:[NSString stringWithFormat:@"%@ with error:%@", NSStringFromSelector(_cmd), error]];
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)aPeripheral
{
    [self log:[NSString stringWithFormat:@"%@ with with peripheral UUID:%@", NSStringFromSelector(_cmd), aPeripheral.UUID]];
    
    [_peripheral setDelegate:self];
    [_peripheral discoverServices:nil];
}

- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error
{
    [self log:[NSString stringWithFormat:@"%@ with error:%@", NSStringFromSelector(_cmd), error]];
          
    for (CBService *aService in aPeripheral.services){
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:SERVICE_UUID]]) {
            [aPeripheral discoverCharacteristics:nil forService:aService];
        }
    }
}

- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    [self log:NSStringFromSelector(_cmd)];
    
    for (CBCharacteristic *aChar in service.characteristics){
//        NSLog(@"characteristic %@",aChar.UUID);
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:CHARACTERISTIC_UUID]]) {
            [self log:@"Will write data"];
            NSString *mainString = [NSString stringWithFormat:@"DA12312"];
            NSData *mainData1= [mainString dataUsingEncoding:NSUTF8StringEncoding];
            [aPeripheral writeValue:mainData1 forCharacteristic:aChar type:CBCharacteristicWriteWithResponse];
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    [self log:[NSString stringWithFormat:@"%@ with error:%@", NSStringFromSelector(_cmd), error]];
    
    [_manager cancelPeripheralConnection:aPeripheral];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
