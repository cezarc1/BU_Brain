//
//  ClassCell.m
//  BU Brain
//
//  Created by Cezar Cocu on 11/9/13.
//  Copyright (c) 2013 Cezar Cocu. All rights reserved.
//

#import "ClassCell.h"

@implementation ClassCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
