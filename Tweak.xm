#import <UIKit/UIKit.h>

/**
 * Watusi Full Unlock
 * Desbloqueia TODOS os switches Premium lockeados por quota
 * 
 * Switches desbloqueados:
 * - Marcar manualmente após abrir (Privacy)
 * - Screenshot & Record View Once (Privacy)
 * - Send on Typing/Recording (Force Receipts on...)
 * - Send After Reply (Force Receipts on...)
 * - Add Button in Chat Actions (Force Receipts on...)
 */

@interface FRSSwitchCell : NSObject
- (void)setLayoutBlock:(void (^)(void))block;
@end

%hook WSSettingsSectionHelper

+ (id)switchCellWithKey:(NSString *)key title:(NSString *)title {
    
    // LISTA MASTER: Todos os switches que precisam unlock
    NSArray *lockedKeys = @[
        // Privacy section
        @"wManuallyMarkViewOnceOpened",
        @"wScreenshotAndRecordViewOnce",
        
        // Force Receipts on... section
        @"wSendOnTypingRecording",
        @"wSendAfterReply",
        @"wAddButtonInChatActions"
    ];
    
    // Se a key está locked, substitui por uma sem quota
    if ([lockedKeys containsObject:key]) {
        NSLog(@"[Watusi Unlock] Desbloqueando: %@", key);
        key = @"wDisableTyping";  // Key harmless, sem proteção
    }
    
    // Chama o método original com a key substituída
    id cell = %orig(key, title);
    
    // Remove layoutBlock que renderiza o overlay "locked"
    FRSSwitchCell *swCell = (FRSSwitchCell *)cell;
    if ([swCell respondsToSelector:@selector(setLayoutBlock:)]) {
        [swCell setLayoutBlock:^{}];  // layoutBlock vazio = sem overlay
    }
    
    return cell;
}

%end
