//
//  ViewController.m
//  MD_Peripheral_iOS
//
//  Created by Christian Giordano on 14/11/2012.
//  Copyright (c) 2012 Christian Giordano. All rights reserved.
//

#import "PeripheralViewController.h"

@interface PeripheralViewController ()<CBPeripheralManagerDelegate>
{
    CBPeripheralManager *_manager;
    CBMutableService *_vcardService;
    CBMutableCharacteristic *_vcardCharacteristic;
    
    NSData *_dataToSend;
    NSString *range;
}
@end

@implementation PeripheralViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _manager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    [self log:@"Peripheral Started"];
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    [self log:[NSString stringWithFormat:@"%@ with state = %i", NSStringFromSelector(_cmd), peripheral.state]];
    
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            [self setupService];
            break;
            
        default:
            break;
    }
}

- (void)setupService
{
    [self log:NSStringFromSelector(_cmd)];
    
    CBUUID *cbuuidService = [CBUUID UUIDWithString:SERVICE_UUID];
    CBUUID *cbuuidPipe = [CBUUID UUIDWithString:CHARACTERISTIC_UUID];
    
    _vcardCharacteristic = [[CBMutableCharacteristic alloc] initWithType:cbuuidPipe
                                                              properties:CBCharacteristicPropertyWrite
                                                                   value:nil
                                                             permissions:0];
    _vcardService = [[CBMutableService alloc] initWithType:cbuuidService primary:YES];
    _vcardService.characteristics = @[_vcardCharacteristic];
    
    [_manager addService:_vcardService];
}

- (void) peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    [self log:NSStringFromSelector(_cmd)];
    
    [self advertise];
}

- (void)advertise
{
    [self log:NSStringFromSelector(_cmd)];
    
    CBUUID *cbuuidService = [CBUUID UUIDWithString:SERVICE_UUID];
    
    NSDictionary *advertisingDict = [NSDictionary dictionaryWithObject:@[cbuuidService] forKey:CBAdvertisementDataServiceDataKey];
    [_manager startAdvertising:advertisingDict];
}

- (void) peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    [self log:[NSString stringWithFormat:@"%@ with error:%@", NSStringFromSelector(_cmd), error]];
}

- (void) peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    [self log:NSStringFromSelector(_cmd)];
    
    NSDictionary *dict = @{ @"NAME" : @"Khaos Tian",@"EMAIL":@"khaos.tian@gmail.com" };
    _dataToSend = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSData *nextChunk = [self getNextChunk];
        while (nextChunk) {
            [_manager updateValue:nextChunk forCharacteristic:_vcardCharacteristic onSubscribedCentrals:nil];
            nextChunk = [self getNextChunk];
        }
        nextChunk = [@"ENDVAL" dataUsingEncoding:NSUTF8StringEncoding];
        [_manager updateValue:nextChunk forCharacteristic:_vcardCharacteristic onSubscribedCentrals:nil];
        
    });
}

- (NSData *)getNextChunk
{
    NSData *data;
    if(!_dataToSend || [_dataToSend length]==0){
        return nil;
    }else if ([_dataToSend length]>19) {
        int datarest = [_dataToSend length]-20;
        data = [_dataToSend subdataWithRange:NSRangeFromString(@"{0,20}")];
        range = [NSString stringWithFormat:@"{20,%i}",datarest];
    }else{
        int datarest = [_dataToSend length];
        range = [NSString stringWithFormat:@"{0,%i}",datarest];
        data = [_dataToSend subdataWithRange:NSRangeFromString(range)];
    }
    [self ridData];
    return data;
}

- (void)ridData
{
    if ([_dataToSend length]>19) {
        _dataToSend = [_dataToSend subdataWithRange:NSRangeFromString(range)];
    }else{
        _dataToSend = nil;
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    [self log:NSStringFromSelector(_cmd)];
    
    NSString *mainString = [NSString stringWithFormat:@"GN123"];
    NSData *cmainData= [mainString dataUsingEncoding:NSUTF8StringEncoding];
    request.value = cmainData;
    [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests
{
    [self log:NSStringFromSelector(_cmd)];
    
    for (CBATTRequest *aReq in requests)
    {
        [self log:[NSString stringWithFormat:@"received data: %@",[[NSString alloc]initWithData:aReq.value encoding:NSUTF8StringEncoding]]];
        [peripheral respondToRequest:aReq withResult:CBATTErrorSuccess];
    }
}

- (void) applicationDidEnterBackground
{
    [self log:NSStringFromSelector(_cmd)];
    
    [_manager stopAdvertising];
}

- (void) applicationWillEnterForeground
{
    [self log:NSStringFromSelector(_cmd)];
    
    NSDictionary *advertisingData = @{CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:SERVICE_UUID]]};
    [_manager startAdvertising:advertisingData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
