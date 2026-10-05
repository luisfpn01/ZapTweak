#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// Forward declare para %c()
@interface FRSSwitchCell : UITableViewCell
- (void)setLayoutBlock:(id)block;
@end

%hook WSSettingsSectionHelper

+ (id)switchCellWithKey:(NSString *)key title:(NSString *)title {
    id cell = %orig(key, title);

    static NSSet *protectedKeys = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        protectedKeys = [NSSet setWithObjects:
            @"wManuallyMarkViewOnceOpened",
            @"wScreenshotAndRecordViewOnce",
            nil];
    });

    if ([protectedKeys containsObject:key]) {
        NSLog(@"[ZapTweak] Desbloqueando: %@", key);
        %c(FRSSwitchCell) *swCell = (%c(FRSSwitchCell) *)cell;
        if ([swCell respondsToSelector:@selector(setLayoutBlock:)]) {
            [swCell setLayoutBlock:^{}]; // block vazio = unlocked
        }
    }

    return cell;
}

%end
