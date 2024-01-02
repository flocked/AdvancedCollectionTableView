//
//  NSItemConfigurationStateObjc.m
//
//
//  Created by Florian Zand on 28.12.23.
//

#import "NSItemConfigurationStateObjc.h"

@implementation NSItemConfigurationStateObjc

- (instancetype)initWithIsSelected:(BOOL)isSelected isEditing:(BOOL)isEditing isEmphasized:(BOOL)isEmphasized isHovered:(BOOL)isHovered isEnabled:(BOOL)isEnabled isFocused:(BOOL)isFocused isExpanded:(BOOL)isExpanded highlight:(NSInteger)highlight customStates:(NSDictionary<NSString *,id> *)customStates {
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

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    return [[NSItemConfigurationStateObjc allocWithZone:zone] initWithIsSelected:self.isSelected isEditing:self.isEditing isEmphasized:self.isEmphasized isHovered:self.isHovered isEnabled:self.isEnabled isFocused:self.isFocused isExpanded:self.isExpanded highlight:self.highlight customStates:self.customStates];
}

@end
