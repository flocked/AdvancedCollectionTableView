//
//  NSTableRowView+NSItemConfigurationState.h
//  
//
//  Created by Florian Zand on 28.12.23.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTableRowConfigurationStateObjc : NSObject

- (instancetype)initWithIsSelected:(BOOL)isSelected isEditing:(BOOL)isEditing isEmphasized:(BOOL)isEmphasized isHovered:(BOOL)isHovered isEnabled:(BOOL)isEnabled isFocused:(BOOL)isFocused isExpanded:(BOOL)isExpanded isNextRowSelected:(BOOL)isNextRowSelected isPreviousRowSelected:(BOOL)isPreviousRowSelected customStates:(NSDictionary<NSString *,id> *)customStates;

@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, assign) BOOL isHovered;
@property (nonatomic, assign) BOOL isEmphasized;
@property (nonatomic, assign) BOOL isEnabled;
@property (nonatomic, assign) BOOL isFocused;
@property (nonatomic, assign) BOOL isExpanded;
@property (nonatomic, assign) BOOL isNextRowSelected;
@property (nonatomic, assign) BOOL isPreviousRowSelected;

@property (nonatomic, strong) NSDictionary<NSString *,id> *customStates;

@end

NS_ASSUME_NONNULL_END
