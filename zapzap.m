#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// Declarações forward
@interface FRSSwitchCell : UITableViewCell
- (void)setLayoutBlock:(id)block;
@end

@interface WSSettingsSectionHelper : NSObject
+ (FRSSwitchCell *)switchCellWithKey:(NSString *)key title:(NSString *)title;
@end

// Variáveis globais para armazenar IMP original
static id (*original_switchCellWithKey_title)(id, SEL, NSString *, NSString *) = NULL;

// Set de keys protegidas que queremos desbloquear
static NSSet *protectedKeys = nil;

/*
 * Hook da fábrica
 * Intercepta antes da membership test (+134c9c) e força unlock
 */
static id hooked_switchCellWithKey_title(id self, SEL _cmd, NSString *key, NSString *title) {
    // Se a key está no conjunto protegido, fazemos o seguinte:
    // 1. Chamamos a fábrica original
    // 2. NÃO deixamos instalar o layoutBlock
    // 3. Retornamos a célula sem restrição
    
    if ([protectedKeys containsObject:key]) {
        NSLog(@"[Watusi Bypass] Desbloqueando key: %@", key);
        
        // Chamada original para montar a célula base
        FRSSwitchCell *cell = (FRSSwitchCell *)original_switchCellWithKey_title(self, _cmd, key, title);
        
        // A célula retorna com layoutBlock já instalado pela fábrica
        // Precisamos remover o layoutBlock ou substituir por um vazio
        
        // Opção 1: Instalar um layoutBlock vazio (dummy)
        // que não executa a verificação de license
        __weak FRSSwitchCell *weakCell = cell;
        void (^dummyBlock)(void) = ^{
            // Block vazio - não executa nada, permitindo acesso total
            NSLog(@"[Watusi Bypass] Layout dummy para %@", key);
        };
        
        [cell setLayoutBlock:dummyBlock];
        
        return cell;
    }
    
    // Para keys não-protegidas, comportamento normal
    return original_switchCellWithKey_title(self, _cmd, key, title);
}

/*
 * Inicialização do hook
 */
__attribute__((constructor))
static void init_watusi_bypass(void) {
    NSLog(@"[Watusi Bypass] Inicializando hook...");
    
    // Inicializar set de protected keys
    protectedKeys = [NSSet setWithObjects:
        @"wManuallyMarkViewOnceOpened",
        @"wScreenshotAndRecordViewOnce",
        nil
    ];
    
    // Obter classe
    Class helperClass = NSClassFromString(@"WSSettingsSectionHelper");
    if (!helperClass) {
        NSLog(@"[Watusi Bypass] ERRO: Classe WSSettingsSectionHelper não encontrada");
        return;
    }
    
    // Obter SEL
    SEL targetSEL = @selector(switchCellWithKey:title:);
    
    // Obter IMP original
    Method originalMethod = class_getClassMethod(helperClass, targetSEL);
    if (!originalMethod) {
        NSLog(@"[Watusi Bypass] ERRO: Método switchCellWithKey:title: não encontrado");
        return;
    }
    
    original_switchCellWithKey_title = (id (*)(id, SEL, NSString *, NSString *))
        method_getImplementation(originalMethod);
    
    NSLog(@"[Watusi Bypass] IMP original: %p", original_switchCellWithKey_title);
    
    // Substituir IMP
    class_replaceMethod(
        object_getClass(helperClass),  // metaclass para class method
        targetSEL,
        (IMP)hooked_switchCellWithKey_title,
        method_getTypeEncoding(originalMethod)
    );
    
    NSLog(@"[Watusi Bypass] Hook instalado com sucesso!");
}
