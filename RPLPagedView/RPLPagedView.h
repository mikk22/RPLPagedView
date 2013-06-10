//
//  RPLPagedView.h
//  
//
//  Created by user on 5/17/12.
//  Copyright (c) 2013 RedPandazLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RPLPagedView;

@protocol RPLPagedViewDelegate <UIScrollViewDelegate>
@optional
- (void)pagedView:(RPLPagedView *)pagedView pageIndex:(NSInteger)index;
- (void)pagedView:(RPLPagedView *)pagedView didMoveToPageIndex:(NSInteger)index;
@end

@protocol RPLPagedViewDatasource <NSObject>
- (NSInteger)numberOfViewsInPagedView:(RPLPagedView *)pagedView;
- (UIView*)pagedView:(RPLPagedView *)pagedView viewForIndex:(NSInteger)index;
@end

@interface RPLPagedView : UIScrollView <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak)         id<RPLPagedViewDatasource>          dataSource;
@property (nonatomic, weak)         id<RPLPagedViewDelegate>            delegate;

@property (nonatomic)               BOOL                                continuousScroll;
@property (nonatomic)               NSInteger                           currentPage;
@property (nonatomic, readonly)     NSInteger                           pagesCount;

-(void)reloadData;

- (UIView *)viewForPageAtIndex:(NSUInteger)index;
- (UIView *)dequeueReusableViewWithTag:(NSInteger)tag;

-(void)setCurrentPage:(NSInteger)currentPage animated:(BOOL)animated;

-(void)nextPage;
-(void)previousPage;
-(void)firstPage;
-(void)lastPage;
-(void)switchToPage:(NSNumber*)pageNumber;

@end



