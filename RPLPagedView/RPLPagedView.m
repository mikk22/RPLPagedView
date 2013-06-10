//
//  RPLPagedView.m
//
//
//  Created by user on 5/17/12.
//  Copyright (c) 2013 RedPandazLabs. All rights reserved.
//

#import "RPLPagedView.h"


@interface RPLPagedView ()
{
    __weak  id<RPLPagedViewDelegate>        _pagedViewDelegate;
	NSInteger                               _currentPage;
}

@property (nonatomic, strong)   NSMutableArray          *views;
@property (nonatomic, strong)   NSMutableDictionary     *queueViews;
@property (nonatomic, readonly) NSIndexSet              *selectedPages;

@end


@implementation RPLPagedView

@synthesize pagesCount=_pagesCount;
@synthesize continuousScroll=_continuousScroll;

#pragma mark - Properties -

- (void)setDelegate:(id<RPLPagedViewDelegate>)delegate {
    _pagedViewDelegate = delegate;
}

- (id<RPLPagedViewDelegate>)delegate {
    return _pagedViewDelegate;
}




-(void)setCurrentPage:(NSInteger)currentPage
{
    
    if (currentPage>(_pagesCount-1))
        currentPage=(_pagesCount-1);
    
    if (currentPage<0)
        currentPage=0;

    _currentPage=currentPage;
}




-(NSInteger)currentPage
{
    NSInteger currentPage=_currentPage;
    if (currentPage>(_pagesCount-1))
        currentPage=0;
    
    if (currentPage<0)
        currentPage=0;
    
    return currentPage;
}




-(void)setCurrentPage:(NSInteger)currentPage animated:(BOOL)animated
{
    _currentPage=currentPage;

    if (_currentPage>(_pagesCount-1))
        _currentPage=0;
    
    if (_currentPage<0)
        _currentPage=0;
    
    NSLog(@"SELF_FRAME %@",NSStringFromCGRect(self.frame));
    NSLog(@"PAGE %d TARGET FRAME %@",self.currentPage,NSStringFromCGRect(CGRectMake(self.currentPage*CGRectGetWidth(self.frame), 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))));
    [self scrollRectToVisible:CGRectMake(self.currentPage*CGRectGetWidth(self.frame), 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)) animated:animated];
}






-(NSIndexSet*)selectedPages
{
    // Create index set for visible views
	NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndex:_currentPage];
    
	NSInteger leftIndex = _currentPage - 1;
    if (leftIndex<0)
        leftIndex= self.continuousScroll ? _pagesCount : 0;
    [indexSet addIndex:leftIndex];
	
	// Add index of view to the right
	NSInteger rightIndex = _currentPage + 1;
    if (rightIndex>_pagesCount)
        rightIndex=self.continuousScroll ? 0 : _pagesCount-1;
    [indexSet addIndex:rightIndex];
    
    return [[NSIndexSet alloc] initWithIndexSet:indexSet];
}



-(NSMutableDictionary*)queueViews
{
    if (!_queueViews)
        _queueViews=[NSMutableDictionary dictionary];
    return _queueViews;
}


-(NSMutableArray*)views
{
    if (!_views)
        _views=[NSMutableArray array];
    return _views;
}


-(void)dealloc
{
    self.views=nil;
    self.queueViews=nil;
}



-(id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self)
    {
        super.delegate=(id)self;
        self.userInteractionEnabled = YES;

        self.scrollEnabled = YES;
        self.pagingEnabled = YES;
        self.showsVerticalScrollIndicator=NO;
        self.showsHorizontalScrollIndicator=NO;
        self.clipsToBounds = NO;
        
        self.delaysContentTouches=YES;
        self.canCancelContentTouches=YES;
        
        _pagesCount=NSNotFound;
    
    }
    
    return self;
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_pagesCount==NSNotFound)
    {
        NSLog(@"CURRENT PAGE %d",_currentPage);
        //initialization
        _pagesCount=[self.dataSource numberOfViewsInPagedView:self];
        NSInteger pagesCount=self.continuousScroll ? _pagesCount+1 : _pagesCount;
        
		// Prepopulate views array
		while ([self.views count] < pagesCount)
        {
			[self.views addObject:[NSNull null]];
		}
        
        self.contentOffset = CGPointZero;
        

        self.contentSize = CGSizeMake(self.bounds.size.width * pagesCount, self.bounds.size.height);
        [self _loadViews];
        
        //first time 
        [self scrollRectToVisible:CGRectMake(self.currentPage*CGRectGetWidth(self.frame), 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)) animated:NO];
        if ([_pagedViewDelegate respondsToSelector:@selector(pagedView:pageIndex:)])
            [_pagedViewDelegate pagedView:self pageIndex:self.currentPage];
        if ([_pagedViewDelegate respondsToSelector:@selector(pagedView:didMoveToPageIndex:)])
            [_pagedViewDelegate pagedView:self didMoveToPageIndex:self.currentPage];
    } else
    {
        NSInteger pagesCount=self.continuousScroll ? _pagesCount+1 : _pagesCount;
        self.contentSize = CGSizeMake(self.bounds.size.width * pagesCount, self.bounds.size.height);
        //for continuos
        [self correctContentOffset];
        [self _loadViews];
    }
}


#pragma mark - Queueing -

- (UIView *)dequeueReusableViewWithTag:(NSInteger)tag
{
	if ([self.queueViews count] == 0)
		return nil;
	
	// Remove view from queue and return it
	UIView *view = [self.queueViews objectForKey:[NSString stringWithFormat:@"%d",tag]];
	[self.queueViews removeObjectForKey:[NSString stringWithFormat:@"%d",tag]];
	
	return view;
}

- (void)queueView:(UIView *)view
{
    [_queueViews setObject:view forKey:[NSString stringWithFormat:@"%d",view.tag]];
}




- (UIView *)viewForPageAtIndex:(NSUInteger)index
{
	UIView *view = [_views objectAtIndex:index];
	if (![view isKindOfClass:[UIView class]])
    {
		return nil;
	}
	
	return view;
}


-(void)_queueViews
{
	for (NSInteger i = 0; i < [_views count]; i++)
    {
		UIView *view = [_views objectAtIndex:i];
		if (![view isKindOfClass:[UIView class]])
			continue;
		
		if ([self.selectedPages containsIndex:i])
			continue;
		
		[view removeFromSuperview];
		[self queueView:view];
		[_views replaceObjectAtIndex:i withObject:[NSNull null]];
	}
}



-(void)_loadViews
{
    if (self.pagesCount)
    {
        for (NSInteger i=0; i<_views.count; i++)
        {
            UIView *view=[self.views objectAtIndex:i];
            if ([self.selectedPages containsIndex:i])
            {
            if (![view isKindOfClass:[UIView class]])
            {
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




-(void)reloadData
{
    _pagesCount=NSNotFound;
    _queueViews=nil;
    
    for (UIView *view in _views)
    {
        if ([view isKindOfClass:[UIView class]])
            [view removeFromSuperview];
    }
    
    _views=nil;
    [self setNeedsLayout];
}


#pragma mark - Scrolling behavior

- (void)correctContentOffset
{
	// Correct content offset for continuous scrolling with multiple pages
	if (self.continuousScroll)
    {
		if (self.contentOffset.x >= _pagesCount * self.bounds.size.width)
        {
			self.contentOffset = CGPointMake(self.contentOffset.x - (_pagesCount * self.bounds.size.width), 0.0);
		} else if (self.contentOffset.x < 0.0)
        {
			self.contentOffset = CGPointMake(self.contentOffset.x + (_pagesCount * self.bounds.size.width), 0.0);
		}
	}
}




#pragma mark - Subview handling

- (CGPoint)centerForViewForPageAtIndex:(NSInteger)index
{
	CGPoint point = CGPointMake((index + 0.5) * self.bounds.size.width, self.bounds.size.height / 2.0);
	return point;
}







-(void)nextPage
{
    ++self.currentPage;
    [self scrollRectToVisible:CGRectMake(self.currentPage*CGRectGetWidth(self.frame), 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)) animated:YES];
}





-(void)previousPage
{
    --self.currentPage;
    [self setContentSize:CGSizeMake(self.currentPage*CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
}


-(void)firstPage
{
    self.currentPage=0;
    [self scrollRectToVisible:CGRectMake(self.currentPage*CGRectGetWidth(self.frame), 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)) animated:YES];
}


-(void)lastPage
{
    self.currentPage=(_pagesCount-1);
    [self scrollRectToVisible:CGRectMake(self.currentPage*CGRectGetWidth(self.frame), 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)) animated:YES];
}




-(void)switchToPage:(NSNumber*)pageNumber
{
    [self setCurrentPage:[pageNumber integerValue] animated:YES];
}





#pragma mark -
#pragma mark UIScrollViewDelegate stuff

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self _queueViews];
    
    if ([_pagedViewDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)])
        [_pagedViewDelegate scrollViewDidEndDecelerating:scrollView];

    if ([_pagedViewDelegate respondsToSelector:@selector(pagedView:didMoveToPageIndex:)])
        [_pagedViewDelegate pagedView:self didMoveToPageIndex:self.currentPage];
}



- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
	CGFloat pageWidth = self.bounds.size.width ;
    float fractionalPage = self.contentOffset.x / pageWidth ;
	NSInteger nearestNumber = lround(fractionalPage) ;
    
	if ((_currentPage != nearestNumber))
	{
        _currentPage=nearestNumber;
		// if we are dragging, we want to update the page control directly during the drag
		if (self.dragging)
        {
            if ([_pagedViewDelegate respondsToSelector:@selector(pagedView:pageIndex:)])
                [_pagedViewDelegate pagedView:self pageIndex:self.currentPage];
        }
	}
    
    if ([_pagedViewDelegate respondsToSelector:@selector(scrollViewDidScroll:)])
        [_pagedViewDelegate scrollViewDidScroll:aScrollView];
}



- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)aScrollView
{
	// if we are animating (triggered by clicking on the page control), we update the page control
    if ([_pagedViewDelegate respondsToSelector:@selector(pagedView:pageIndex:)])
        [_pagedViewDelegate pagedView:self pageIndex:self.currentPage];

    if ([_pagedViewDelegate respondsToSelector:@selector(scrollViewDidScroll:)])
        [_pagedViewDelegate scrollViewDidScroll:aScrollView];
}



@end
