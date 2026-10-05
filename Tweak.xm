#import <UIKit/UIKit.h>

@interface FRSSwitchCell : NSObject
- (void)setLayoutBlock:(void (^)(void))block;
@end

@interface UISwitch : UIView
- (void)setEnabled:(BOOL)enabled;
@end

// Keys exatas que precisam desbloqueio
static NSSet<NSString *> *lockedKeys = nil;

%hook WSSettingsSectionHelper

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lockedKeys = [NSSet setWithObjects:
            // Privacy section
            @"wManuallyMarkViewOnceOpened",
            @"wScreenshotAndRecordViewOnce",
            
            // Force Receipts on... section
            @"wSendReadReceiptsOnTyping",
            @"wSendReadReceiptsOnReply",
            @"wSendReadReceiptsFromChatPlugin",
            nil];
    });
}

+ (id)switchCellWithKey:(NSString *)key title:(NSString *)title {
    
    // Chamar original mantendo a key original
    id cell = %orig(key, title);
    
    // Se a key é uma das locked, desbloquear
    if ([lockedKeys containsObject:key]) {
        NSLog(@"[ZapTweak] Desbloqueando: %@", key);
        
        // Neutralizar layoutBlock que renderiza overlay "locked"
        FRSSwitchCell *swCell = (FRSSwitchCell *)cell;
        if ([swCell respondsToSelector:@selector(setLayoutBlock:)]) {
            [swCell setLayoutBlock:^{}];  // layoutBlock vazio
        }
    }
    
    return cell;
}

%end

// Hook secundário: interceptar setEnabled:NO que desabilita os switches
%hook UISwitch

- (void)setEnabled:(BOOL)enabled {
    // Forçar habilitado se este switch está dentro de FRSSwitchCell locked
    UIView *parent = self.superview;
    while (parent) {
        if ([parent isKindOfClass:%c(FRSSwitchCell)]) {
            // Se encontrou FRSSwitchCell, deixa como enabled
            // (já foram desbloqueados pela factory acima)
            %orig(YES);
            return;
        }
        parent = parent.superview;
    }
    
    // Para outros switches, passa original
    %orig(enabled);
}

%end
