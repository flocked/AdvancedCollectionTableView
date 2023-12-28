//
//  NSTableRowView+NSItemConfigurationState.m
//  Tester
//
//  Created by Florian Zand on 28.12.23.
//

#import "NSItemConfigurationStateObjc.h"

@implementation NSItemConfigurationStateObjc

- (instancetype)initWithIsSelected:(BOOL)isSelected isEditing:(BOOL)isEditing isEmphasized:(BOOL)isEmphasized isHovered:(BOOL)isHovered isEnabled:(BOOL)isEnabled isFocused:(BOOL)isFocused isExpanded:(BOOL)isExpanded highlight:(int)highlight customStates:(NSDictionary<NSString *,id> *)customStates {
    self = [super init];
    if (self != nil) {
        self.isSelected = isSelected;
        self.isEditing = isEditing;
        self.isEmphasized = isEmphasized;
        self.isHovered = isHovered;
        self.isEnabled = isEnabled;
        self.isFocused = isFocused;
        self.isExpanded = isExpanded;
        self.highlight = highlight;
        self.customStates = customStates;
    }
    return self;
}

@end
