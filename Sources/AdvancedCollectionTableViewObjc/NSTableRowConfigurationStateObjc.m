//
//  NSTableRowView+NSItemConfigurationState.m
//  
//
//  Created by Florian Zand on 28.12.23.
//

#import "NSTableRowConfigurationStateObjc.h"

@implementation NSTableRowConfigurationStateObjc

- (instancetype)initWithIsSelected:(BOOL)isSelected isEditing:(BOOL)isEditing isEmphasized:(BOOL)isEmphasized isHovered:(BOOL)isHovered isEnabled:(BOOL)isEnabled isFocused:(BOOL)isFocused isExpanded:(BOOL)isExpanded isNextRowSelected:(BOOL)isNextRowSelected isPreviousRowSelected:(BOOL)isPreviousRowSelected customStates:(NSDictionary<NSString *,id> *)customStates {
    self = [super init];
    if (self != nil) {
        self.isSelected = isSelected;
        self.isEditing = isEditing;
        self.isEmphasized = isEmphasized;
        self.isHovered = isHovered;
        self.isEnabled = isEnabled;
        self.isFocused = isFocused;
        self.isExpanded = isExpanded;
        self.isNextRowSelected = isNextRowSelected;
        self.isPreviousRowSelected = isPreviousRowSelected;
        self.customStates = customStates;
    }
    return self;
}

@end
