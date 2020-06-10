#import "CBInstantiablePeripheral.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
@implementation CBInstantiablePeripheral
- init {
    [self addObserver:self forKeyPath:@"delegate" options:0 context:nil];
    return self;
}
@end
#pragma clang diagnostic pop
