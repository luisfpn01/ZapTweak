#import <UIKit/UIKit.h>

// Forward declare FRSSwitchCell for clean typing
@interface FRSSwitchCell : NSObject
- (void)setLayoutBlock:(void (^)(void))block;
@end

%hook WSSettingsSectionHelper

+ (id)switchCellWithKey:(NSString *)key title:(NSString *)title {
    // Protected keys that trigger quota/locked layout
    NSArray *protectedKeys = @[@"wManuallyMarkViewOnceOpened", @"wScreenshotAndRecordViewOnce"];
    
    if ([protectedKeys containsObject:key]) {
        // Substitute with harmless key
        key = @"wDisableTyping";
    }
    
    id cell = %orig(key, title);
    
    // Strip layoutBlock to prevent locked overlay
    FRSSwitchCell *swCell = (FRSSwitchCell *)cell;
    if ([swCell respondsToSelector:@selector(setLayoutBlock:)]) {
        [swCell setLayoutBlock:^{}];
    }
    
    return cell;
}

%end
