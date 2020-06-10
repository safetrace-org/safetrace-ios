#import <CoreBluetooth/CoreBluetooth.h>

/// CBPeripheral with accessible initializer
/// *For use in test mocks only.*
NS_ASSUME_NONNULL_BEGIN
@interface CBInstantiablePeripheral: CBPeripheral
- init;
@end
NS_ASSUME_NONNULL_END
