//
//  ModalTestViewController.m
//  FRDLivelyButtonDemo
//
//  Created by Sebastien Windal on 7/17/14.
//  Copyright (c) 2014 Sebastien Windal. All rights reserved.
//

#import "ModalTestViewController.h"
#import "FRDLivelyButton.h"

@interface ModalTestViewController ()

@end

@implementation ModalTestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    FRDLivelyButton *button = [[FRDLivelyButton alloc] initWithFrame:CGRectMake(0,0,36,28)];
    [button setOptions:@{ kFRDLivelyButtonLineWidth: @(2.0f),
                          kFRDLivelyButtonHighlightAnimationDuration: @(1.0f),
                          kFRDLivelyButtonHighlightedColor: [UIColor colorWithRed:0.5 green:0.8 blue:1.0 alpha:1.0],
                          kFRDLivelyButtonColor: [UIColor blueColor]
                          }];
    [button setStyle:kFRDLivelyButtonStyleArrowLeft animated:NO];
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = buttonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)buttonAction:(FRDLivelyButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) dealloc
{
    
}

@end
