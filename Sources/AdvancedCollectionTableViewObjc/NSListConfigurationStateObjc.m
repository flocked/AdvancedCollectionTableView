//
//  NSListConfigurationStateObjc.m
//  
//
//  Created by Florian Zand on 28.12.23.
//

#import "NSListConfigurationStateObjc.h"

@implementation NSListConfigurationStateObjc

- (instancetype)initWithIsSelected:(BOOL)isSelected isEditing:(BOOL)isEditing isEmphasized:(BOOL)isEmphasized isHovered:(BOOL)isHovered isEnabled:(BOOL)isEnabled isFocused:(BOOL)isFocused isExpanded:(BOOL)isExpanded isNextSelected:(BOOL)isNextSelected isPreviousSelected:(BOOL)isPreviousSelected customStates:(NSDictionary<NSString *,id> *)customStates {
    self = [super init];
    if (self != nil) {
        self.isSelected = isSelected;
        self.isEditing = isEditing;
        self.isEmphasized = isEmphasized;
        self.isHovered = isHovered;
        self.isEnabled = isEnabled;
        self.isFocused = isFocused;
        self.isExpanded = isExpanded;
        self.isNextSelected = isNextSelected;
        self.isPreviousSelected = isPreviousSelected;
        self.customStates = customStates;
    }
    return self;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    return [[NSListConfigurationStateObjc allocWithZone:zone] initWithIsSelected:self.isSelected isEditing:self.isEditing isEmphasized:self.isEmphasized isHovered:self.isHovered isEnabled:self.isEnabled isFocused:self.isFocused isExpanded:self.isExpanded isNextSelected:self.isNextSelected isPreviousSelected:self.isPreviousSelected customStates:self.customStates];
}

@end
