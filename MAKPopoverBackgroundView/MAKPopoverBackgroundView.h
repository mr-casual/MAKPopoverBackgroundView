//
//  MAKPopoverBackgroundView.h
//  MAKPopoverBackgroundView
//
//  Created by Martin Kloepfel on 30.08.15.
//  Copyright (c) 2014 Martin Klöpfel. All rights reserved.
//

#import <UIKit/UIKit.h>


/** BETA!
*/
@interface MAKPopoverBackgroundView : UIPopoverBackgroundView

//@property (nonatomic) CGPoint arrowPoint;

@property (nonatomic) BOOL shouldShowDimmingView;

@property (nonatomic, strong) UIView *contentView;

//+ (CGSize)sizeWithContentView:(UIView *)view;

@end
