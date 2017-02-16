//
//  RPLPagedView.h
//  
//
//  Created by user on 5/17/12.
//  Copyright (c) 2013 RedPandazLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RPLPagedViewDatasource;
@protocol RPLPagedViewDelegate;

@interface RPLPagedView : UIScrollView

@property(nonatomic, weak) id<RPLPagedViewDatasource> dataSource;
@property(nonatomic, weak) id<RPLPagedViewDelegate> pagedViewDelegate;

@property(nonatomic, assign) BOOL continuousScroll;
@property(nonatomic, assign) NSInteger currentPage;
@property(nonatomic, assign, readonly) NSInteger pagesCount;

- (void)reloadData;

- (UIView*)viewForPageAtIndex:(NSUInteger)index;
- (UIView*)dequeueReusableViewWithTag:(NSInteger)tag;

- (void)setCurrentPage:(NSInteger)currentPage animated:(BOOL)animated;

- (void)nextPage;
- (void)previousPage;
- (void)firstPage;
- (void)lastPage;
- (void)switchToPage:(NSNumber*)pageNumber;

@end

@protocol RPLPagedViewDelegate<NSObject>

@optional
- (void)pagedView:(RPLPagedView*)pagedView pageIndex:(NSInteger)index;
- (void)pagedView:(RPLPagedView*)pagedView didMoveToPageIndex:(NSInteger)index;

@end

@protocol RPLPagedViewDatasource<NSObject>

- (NSInteger)numberOfViewsInPagedView:(RPLPagedView*)pagedView;
- (UIView*)pagedView:(RPLPagedView*)pagedView viewForIndex:(NSInteger)index;

@end
