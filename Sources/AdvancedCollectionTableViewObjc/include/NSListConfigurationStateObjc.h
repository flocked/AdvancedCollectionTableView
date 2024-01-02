//
//  NSListConfigurationStateObjc.h
//  
//
//  Created by Florian Zand on 28.12.23.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSListConfigurationStateObjc : NSObject<NSCopying>

- (instancetype)initWithIsSelected:(BOOL)isSelected isEditing:(BOOL)isEditing isEmphasized:(BOOL)isEmphasized isHovered:(BOOL)isHovered isEnabled:(BOOL)isEnabled isFocused:(BOOL)isFocused isExpanded:(BOOL)isExpanded isNextSelected:(BOOL)isNextSelected isPreviousSelected:(BOOL)isPreviousSelected customStates:(NSDictionary<NSString *,id> *)customStates;

@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, assign) BOOL isHovered;
@property (nonatomic, assign) BOOL isEmphasized;
@property (nonatomic, assign) BOOL isEnabled;
@property (nonatomic, assign) BOOL isFocused;
@property (nonatomic, assign) BOOL isExpanded;
@property (nonatomic, assign) BOOL isNextSelected;
@property (nonatomic, assign) BOOL isPreviousSelected;

@property (nonatomic, strong) NSDictionary<NSString *,id> *customStates;

@end

NS_ASSUME_NONNULL_END
