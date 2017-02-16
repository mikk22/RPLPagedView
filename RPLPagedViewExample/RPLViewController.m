//
//  RPLViewController.m
//  RPLPagedViewExample
//
//  Created by user on 10.06.13.
//  Copyright (c) 2013 user. All rights reserved.
//

#import "RPLViewController.h"

#import "RPLPagedView.h"

@interface RPLViewController ()<RPLPagedViewDatasource, RPLPagedViewDelegate>

@property(nonatomic, strong) UIPageControl* pageControl;
@property(nonatomic, strong) RPLPagedView* pagedView;

@end

@implementation RPLViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor blackColor];
  [self setupPagedView];
  [self setupPageControl];
}

- (void)setupPagedView {
  RPLPagedView* pagedView = [[RPLPagedView alloc] init];
  pagedView.dataSource = self;
  pagedView.pagedViewDelegate = self;
  pagedView.continuousScroll = YES;

  [self.view addSubview:pagedView];
  self.pagedView = pagedView;
}

- (void)setupPageControl {
  self.pageControl = [[UIPageControl alloc] init];
  self.pageControl.numberOfPages = 5;
  self.pageControl.currentPage = 0;
  [self.view addSubview:self.pageControl];
}

- (void)viewWillLayoutSubviews {
  [super viewWillLayoutSubviews];
  self.pagedView.frame = self.view.bounds;
  self.pageControl.frame = CGRectMake(0.0, CGRectGetHeight(self.view.bounds) - 50.0, CGRectGetWidth(self.view.bounds), 50.0);
}

#pragma mark - RPLPagedViewDatasource

- (NSInteger)numberOfViewsInPagedView:(RPLPagedView *)pagedView {
  return 5;
}

- (UIView*)pagedView:(RPLPagedView *)pagedView viewForIndex:(NSInteger)index {
  NSArray* colors = @[ [UIColor redColor],
                       [UIColor greenColor],
                       [UIColor blueColor],
                       [UIColor yellowColor],
                       [UIColor brownColor] ];
  UIView* view = [[UIView alloc] init];
  view.bounds = self.view.bounds;
  view.backgroundColor = colors[index];
  return view;
}

#pragma mark - RPLPagedViewDelegate

- (void)pagedView:(RPLPagedView *)pagedView pageIndex:(NSInteger)index {
  NSLog(@"pageIndex %tu", index);
}

- (void)pagedView:(RPLPagedView *)pagedView didMoveToPageIndex:(NSInteger)index {
  NSLog(@"didMoveToPageIndex %tu", index);
  self.pageControl.currentPage = index;
}

@end
