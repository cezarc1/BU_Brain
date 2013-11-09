//
//  ClassCell.h
//  BU Brain
//
//  Created by Cezar Cocu on 11/8/13.
//  Copyright (c) 2013 Cezar Cocu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClassCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *className;

@property (weak, nonatomic) IBOutlet UILabel *time;


@property (weak, nonatomic) IBOutlet UILabel *days;

@property (weak, nonatomic) IBOutlet UILabel *where;

@end
