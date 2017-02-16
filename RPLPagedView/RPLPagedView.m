//
//  RPLPagedView.m
//
//
//  Created by user on 5/17/12.
//  Copyright (c) 2013 RedPandazLabs. All rights reserved.
//

#import "RPLPagedView.h"

@interface RPLPagedView ()<UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property(nonatomic, strong, readonly) NSMutableArray* views;
@property(nonatomic, strong, readonly) NSMutableDictionary* queueViews;
@property(nonatomic, readonly) NSIndexSet* selectedPages;
@property(nonatomic, assign, readwrite) NSInteger pagesCount;

@end

@implementation RPLPagedView

@synthesize currentPage = _currentPage;

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.delegate = (id)self;
    self.userInteractionEnabled = YES;

    self.scrollEnabled = YES;
    self.pagingEnabled = YES;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.clipsToBounds = NO;

    self.delaysContentTouches = YES;
    self.canCancelContentTouches = YES;

    _queueViews = [[NSMutableDictionary alloc] init];
    _views = [[NSMutableArray alloc] init];
    _pagesCount = NSNotFound;
  }
  
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];

  if (self.pagesCount == NSNotFound) {
    [self initializeViews];
  } else {
    NSInteger pagesCount = self.continuousScroll ? self.pagesCount + 1 : self.pagesCount;
    self.contentSize = CGSizeMake(self.bounds.size.width * pagesCount, self.bounds.size.height);
    //for continuos
    [self correctContentOffset];
    [self _loadViews];
  }
}

- (void)initializeViews {
  //initialization
  self.pagesCount = [self.dataSource numberOfViewsInPagedView:self];
  NSInteger pagesCount = self.continuousScroll ? self.pagesCount + 1 : self.pagesCount;
  
  // Prepopulate views array
  while ([self.views count] < pagesCount) {
    [self.views addObject:[NSNull null]];
  }
  
  self.contentOffset = CGPointZero;
  self.contentSize = CGSizeMake(CGRectGetWidth(self.bounds) * pagesCount, CGRectGetHeight(self.bounds));
  [self _loadViews];
  
  //first time
  [self scrollToVisiblePageRectAnimated:NO];

  if ([self.pagedViewDelegate respondsToSelector:@selector(pagedView:pageIndex:)])
    [self.pagedViewDelegate pagedView:self pageIndex:self.currentPage];
  if ([self.pagedViewDelegate respondsToSelector:@selector(pagedView:didMoveToPageIndex:)])
    [self.pagedViewDelegate pagedView:self didMoveToPageIndex:self.currentPage];
}

#pragma mark - Properties -

- (NSInteger)currentPage {
  NSInteger currentPage = _currentPage;
  if (currentPage > (_pagesCount-1) ) {
    currentPage = 0;
  }

  if (currentPage < 0) {
    currentPage = 0;
  }

  return currentPage;
}

- (void)setCurrentPage:(NSInteger)currentPage {
  [self setCurrentPage:currentPage animated:NO];
}

- (void)setCurrentPage:(NSInteger)currentPage animated:(BOOL)animated {
  if (currentPage > (_pagesCount-1) ) {
    currentPage=(_pagesCount-1);
  }
  
  if (currentPage < 0) {
    currentPage = 0;
  }
  
  _currentPage = currentPage;
  [self scrollToVisiblePageRectAnimated:animated];
}

- (void)scrollToVisiblePageRectAnimated:(BOOL)animated {
  CGRect currentPageRect = CGRectMake(self.currentPage * CGRectGetWidth(self.frame),
                                      0.0,
                                      CGRectGetWidth(self.frame),
                                      CGRectGetHeight(self.frame));
  [self scrollRectToVisible:currentPageRect animated:animated];
}

- (NSIndexSet*)selectedPages {
  // Create index set for visible views
  NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndex:_currentPage];
  
  NSInteger leftIndex = _currentPage - 1;
  if (leftIndex < 0) {
    leftIndex = self.continuousScroll ? _pagesCount : 0;
  }
  [indexSet addIndex:leftIndex];
  
  // Add index of view to the right
  NSInteger rightIndex = _currentPage + 1;
  if (rightIndex > _pagesCount) {
    rightIndex = self.continuousScroll ? 0 : _pagesCount-1;
  }
  [indexSet addIndex:rightIndex];
  
  return [[NSIndexSet alloc] initWithIndexSet:indexSet];
}

#pragma mark - Queueing -

- (UIView*)dequeueReusableViewWithTag:(NSInteger)tag {
  if (![self.queueViews count]) {
		return nil;
  }
	
	// Remove view from queue and return it
  NSString* key = [NSString stringWithFormat:@"%ld",(long)tag];
	UIView* view = self.queueViews[key];
	[self.queueViews removeObjectForKey:key];
	return view;
}

- (void)queueView:(UIView*)view {
  NSString* key = [NSString stringWithFormat:@"%ld",(long)view.tag];
  [_queueViews setObject:view forKey:key];
}

- (UIView *)viewForPageAtIndex:(NSUInteger)index {
  UIView *view = _views[index];
  NSAssert([view isKindOfClass:[UIView class]], @"view should be kind of UIView class");
	if (![view isKindOfClass:[UIView class]]) {
		return nil;
	}

	return view;
}

-(void)_queueViews {
  for (NSInteger i = 0; i < _views.count; i++) {
    UIView *view = [_views objectAtIndex:i];
    if (![view isKindOfClass:[UIView class]]) {
      continue;
    }
    
    if ([self.selectedPages containsIndex:i]) {
      continue;
    }

    [view removeFromSuperview];
    [self queueView:view];
    [_views replaceObjectAtIndex:i withObject:[NSNull null]];
  }
}

-(void)_loadViews {
  if (self.pagesCount) {
    for (NSInteger i=0; i<_views.count; i++) {
      UIView *view=[self.views objectAtIndex:i];
      if ([self.selectedPages containsIndex:i]) {
        if (![view isKindOfClass:[UIView class]]) {
          NSInteger viewIndex=(self.continuousScroll && i==_pagesCount) ? 0 : i;
          view = [self.dataSource pagedView:self viewForIndex:viewIndex];
          [self.views replaceObjectAtIndex:i withObject:view];
          [self addSubview:view];
        }
        
        view.center = [self centerForViewForPageAtIndex:i];
      }
    }
  }
}

- (void)reloadData {
  _pagesCount = NSNotFound;
  [self.queueViews removeAllObjects];
  
  for (UIView* view in _views) {
    if ([view isKindOfClass:[UIView class]])
      [view removeFromSuperview];
  }

  [self.views removeAllObjects];
  [self setNeedsLayout];
}

#pragma mark - Scrolling behavior

- (void)correctContentOffset {
  // Correct content offset for continuous scrolling with multiple pages
  if (self.continuousScroll) {
    if (self.contentOffset.x >= _pagesCount * self.bounds.size.width) {
      self.contentOffset = CGPointMake(self.contentOffset.x - (_pagesCount * self.bounds.size.width), 0.0);
    } else if (self.contentOffset.x < 0.0) {
      self.contentOffset = CGPointMake(self.contentOffset.x + (_pagesCount * self.bounds.size.width), 0.0);
    }
  }
}

#pragma mark - Subview handling

- (CGPoint)centerForViewForPageAtIndex:(NSInteger)index {
	CGPoint point = CGPointMake((index + 0.5) * self.bounds.size.width, self.bounds.size.height / 2.0);
	return point;
}

- (void)nextPage {
  ++self.currentPage;
  [self scrollToVisiblePageRectAnimated:YES];
}

- (void)previousPage {
  --self.currentPage;
  [self scrollToVisiblePageRectAnimated:YES];
}

- (void)firstPage {
  self.currentPage = 0;
  [self scrollToVisiblePageRectAnimated:YES];
}

- (void)lastPage {
  self.currentPage = _pagesCount - 1;
  [self scrollToVisiblePageRectAnimated:YES];
}

- (void)switchToPage:(NSNumber*)pageNumber {
  [self setCurrentPage:pageNumber.integerValue animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  [self _queueViews];

  if ([self.pagedViewDelegate respondsToSelector:@selector(pagedView:didMoveToPageIndex:)]) {
    [self.pagedViewDelegate pagedView:self didMoveToPageIndex:self.currentPage];
  }
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
	CGFloat pageWidth = self.bounds.size.width ;
  CGFloat fractionalPage = self.contentOffset.x / pageWidth ;
	NSInteger nearestNumber = lround(fractionalPage) ;
    
	if ((_currentPage != nearestNumber)) {
    _currentPage=nearestNumber;
    // if we are dragging, we want to update the page control directly during the drag
    if (self.dragging) {
      if ([self.pagedViewDelegate respondsToSelector:@selector(pagedView:pageIndex:)]) {
        [self.pagedViewDelegate pagedView:self pageIndex:self.currentPage];
      }
    }
	}
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView*)aScrollView {
	// if we are animating (triggered by clicking on the page control), we update the page control
  if ([self.pagedViewDelegate respondsToSelector:@selector(pagedView:pageIndex:)]) {
    [self.pagedViewDelegate pagedView:self pageIndex:self.currentPage];
  }
}

@end
