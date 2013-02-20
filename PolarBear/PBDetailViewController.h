//
//  PBDetailViewController.h
//  PolarBear
//
//  Created by HengHong on 20/2/13.
//  Copyright (c) 2013 HengHong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PBDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
