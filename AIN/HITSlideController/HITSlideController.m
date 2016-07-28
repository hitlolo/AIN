//
//  HITSlideController.m
//  UIViewTest
//
//  Created by Lolo.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "HITSlideController.h"
#import "HITSlideAnimationManager.h"


#pragma mark - SlideController's contentView


@interface HITCenterContainerView : UIView

@property(nonatomic, assign)HITCenterInteractionMode centerInteractionMode;
@property(nonatomic, assign)HITSlide openedSlide;

@end

@implementation HITCenterContainerView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultSetup];
    }
    return self;
}

- (void)defaultSetup{
    _centerInteractionMode = HITCenterInteractionModeNavigationBarOnly;
    _openedSlide = HITSlideNone;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    
    UIView *hitView = [super hitTest:point withEvent:event];
    
    //if a slide is opeded
    if( hitView && self.openedSlide != HITSlideNone ){
        UINavigationBar * navBar = [self navigationBarInView:self];
        CGRect navBarFrame = [navBar convertRect:navBar.bounds toView:self];
        BOOL pointOnBar = CGRectContainsPoint(navBarFrame, point);
        if ( self.centerInteractionMode == HITCenterInteractionModeNavigationBarOnly && !pointOnBar) {
            hitView = nil;
        }
        else if ( self.centerInteractionMode == HITCenterInteractionModeNone ){
            hitView = nil;
        }
    }
    return hitView;
}

- (UINavigationBar*)navigationBarInView:(UIView*)view{
    UINavigationBar * navBar = nil;
    for( UIView * subview in [view subviews] ){
        if( [view isKindOfClass:[UINavigationBar class] ]){
            navBar = (UINavigationBar*)view;
            break;
        }
        else {
            navBar = [self navigationBarInView:subview];
            if (navBar != nil) {
                break;
            }
        }
    }
    return navBar;
}

- (UITabBar*)tabBarInView:(UIView*)view{
    UITabBar* tabBar = nil;
    for( UIView * subview in [view subviews] ){
        if( [view isKindOfClass:[UITabBar class] ]){
            tabBar = (UITabBar*)view;
            break;
        }
        else {
            tabBar = [self tabBarInView:subview];
            if (tabBar != nil) {
                break;
            }
        }
    }
    return tabBar;
}

@end


#pragma mark - SlideController
@interface HITSlideController ()<UIGestureRecognizerDelegate>
@property(nonatomic, strong)UIView* containerView;
@property(nonatomic, strong)HITCenterContainerView* centerView;
@property(nonatomic, assign, readwrite)HITSlide openedSlide;
@property(nonatomic, assign, getter=isAnimating)BOOL animating;
@property(nonatomic, assign)CGRect centerOriginalRect;
@property(nonatomic, copy)HITSlideAnimationBlock animationBlock;

@end

@implementation HITSlideController

@synthesize  maximumLeftSlideWidth = _maximumLeftSlideWidth;
@synthesize maximumRightSlideWidth = _maximumRightSlideWidth;

#pragma mark - initialization


- (instancetype)initWithCenterViewController:(UIViewController *)centerViewController
                          leftViewController:(UIViewController *)leftViewController
                         rightViewController:(UIViewController *)rightViewController{
    
    self = [super init];
    if (self) {
        [self defaultSetup];
        [self setCenterViewController:centerViewController];
        [self setLeftViewController:leftViewController];
        [self setRightViewController:rightViewController];
    }
    return self;
}

- (instancetype)initWithCenterViewController:(UIViewController *)centerViewController
                          leftViewController:(UIViewController *)leftViewController{
    
    return [self initWithCenterViewController:centerViewController
                           leftViewController:leftViewController
                          rightViewController:nil];
}

- (instancetype)initWithCenterViewController:(UIViewController *)centerViewController
                         rightViewController:(UIViewController *)rightViewController{
    
    return [self initWithCenterViewController:centerViewController
                           leftViewController:nil
                          rightViewController:rightViewController];
}

- (instancetype)initWithCenterViewController:(UIViewController *)centerViewController{
    
    return [self initWithCenterViewController:centerViewController
                           leftViewController:nil
                          rightViewController:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self defaultSetup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self defaultSetup];
    }
    return self;
}


- (instancetype)init{
    
    return [self initWithCenterViewController:nil leftViewController:nil rightViewController:nil];
}

#pragma mark - set default values
- (void)defaultSetup{
    
    //size
    _maximumLeftSlideWidth = 280.0f;
    _maximumRightSlideWidth = 280.0f;
    
    //animation
    _animating = NO;
    _animationType = HITAnimationParallax;
    _animationVelocity = 840.0f;
    
    //shadow
    _showsShadow = YES;
    _shadowColor = [UIColor blackColor];
    _shadowOffset = CGSizeMake(0, -2);
    _shadowRadius = 10.0f;
    _shadowOpacity = 0.7f;
    
    //gesture
    _panVelocityAnimationThreshold = 200.0f;
    
    //interaction control: Navigation bar
    _centerInteractionMode = HITCenterInteractionModeNavigationBarOnly;
    
    //current opened side: none
    _openedSlide = HITSlideNone;
    
    
}

#pragma mark - Set Controllers


- (void)setCenterViewController:(UIViewController *)centerViewController{
    
    [self performOperation:HITOperationSetCenterController withViewController:centerViewController];

}

- (void)setLeftViewController:(UIViewController *)leftViewController{
    
    [self performOperation:HITOperationSetLeftController withViewController:leftViewController];
    
}

- (void)setRightViewController:(UIViewController *)rightViewController{
    
    [self performOperation:HITOperationSetRightController withViewController:rightViewController];
}


#pragma mark - View Controllers Switch handle

- (void)performOperation:(HITOperationType)operationType withViewController:(UIViewController*)newViewController{
    //nil
    if( newViewController == nil ){
        return;
    }
    //no change
    UIViewController* oldViewController = nil;
    
    if ( operationType == HITOperationNone ) {
        return;
    }
    else if( operationType == HITOperationSetCenterController ){
        
        if ([newViewController isEqual:self.centerViewController]){
            return;
        }
        oldViewController = self.centerViewController;
    }
    else if( operationType == HITOperationSetLeftController ){
        
        if ([newViewController isEqual:self.leftViewController]) {
            return;
        }
        oldViewController = self.leftViewController;
    }
    else if( operationType == HITOperationSetRightController){
        
        if ([newViewController isEqual:self.rightViewController]) {
            return;
        }
        oldViewController = self.rightViewController;
    }
    
    //ELSE Go change
    [self updateFromViewController:oldViewController toViewController:newViewController operationType:operationType];
}

- (void)updateFromViewController:(UIViewController *)fromViewController
                    toViewController:(UIViewController *)toViewController
                       operationType:(HITOperationType)operationType{
    
    //remove old viewController
    if (fromViewController != nil) {
        [fromViewController willMoveToParentViewController:nil];
        [fromViewController.view removeFromSuperview];
        [fromViewController removeFromParentViewController];
    }
    
    //set instance var
    if (operationType == HITOperationSetCenterController) {
        _centerViewController = toViewController;
    }
    else if(operationType == HITOperationSetLeftController){
        _leftViewController = toViewController;
    }
    else if(operationType == HITOperationSetRightController){
        _rightViewController = toViewController;
    }
    
    //add child viewcontroller
    
    [self addChildViewController:toViewController];
    
    UIViewAutoresizing autoResizingMask = 0;
    CGRect frame = CGRectZero;
    //add subview
    //center'view add to centerView
    if (operationType == HITOperationSetCenterController) {
        autoResizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        frame = self.centerView.bounds;
        [_centerViewController.view setFrame:frame];
        [self.centerView addSubview:_centerViewController.view];
    }
    //left and right view add to containerView
    else if(operationType == HITOperationSetLeftController){
        autoResizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        frame = self.containerView.bounds;
        frame.size.width = self.maximumLeftSlideWidth;
        [_leftViewController.view setFrame:frame];
        [self.containerView addSubview:_leftViewController.view];
    }
    else if(operationType == HITOperationSetRightController){
        autoResizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        frame = self.containerView.bounds;
        frame.size.width = self.maximumRightSlideWidth;
        [_rightViewController.view setFrame:frame];
        [self.containerView addSubview:_rightViewController.view];
    }
    [self.containerView bringSubviewToFront:self.centerView];
    
    //did added
    [toViewController didMoveToParentViewController:self];
    [toViewController.view setAutoresizingMask:autoResizingMask];

}


- (UIViewController*)getViewControllerWithSlide:(HITSlide)slide{
    
    UIViewController* viewController = nil;
    switch (slide) {
        case HITSlideLeft:
            viewController = self.leftViewController;
            break;
        case HITSlideRight:
            viewController = self.rightViewController;
            break;
        default:
            viewController = nil;
            break;
    }
    return viewController;
    
}

#pragma mark - Open & Close & Animations

- (IBAction)toggleLeftSlide:(id)sender{
    [self toggleSlide:HITSlideLeft animated:YES completion:nil];
}

- (IBAction)toggleRightSlide:(id)sender{
    [self toggleSlide:HITSlideRight animated:YES completion:nil];
}

- (void)toggleLeftSlideAnimated:(BOOL)animated completion:(void (^)(BOOL))completion{
    [self toggleSlide:HITSlideLeft animated:animated completion:completion];
}

- (void)toggleRightSlideAnimated:(BOOL)animated completion:(void (^)(BOOL))completion{
    [self toggleSlide:HITSlideRight animated:animated completion:completion];
}


- (void)toggleSlide:(HITSlide)slide animated:(BOOL)animated completion:(void (^)(BOOL finished))completion{
    
    if (slide == HITSlideNone) {
        return;
    }
    
    //new open
    if(self.openedSlide == HITSlideNone){
        [self openSlide:slide animated:animated completion:completion];
    }
    //opened one but now open another one
    else if( self.openedSlide != slide ){
        [self closeSlide:self.openedSlide animated:NO completion:nil];
        [self openSlide:slide animated:animated completion:completion];
    }
    //close the opened one
    else{
        [self closeSlide:slide animated:animated completion:completion];
    }
}


- (void)openSlide:(HITSlide)slide animated:(BOOL)animated completion:(void (^)(BOOL finished))completion{
    
    if ( slide == HITSlideNone)
        return;
    
    UIViewController* controllerToShow = [self getViewControllerWithSlide:slide];
    if ( controllerToShow == nil ) {
        return;
    }
    
    [self openSlide:slide
           animated:animated
           velocity:self.animationVelocity
   animationOptions:UIViewAnimationOptionCurveEaseInOut
         completion:completion];
}

- (void)openSlide:(HITSlide)slideToShow animated:(BOOL)animated velocity:(CGFloat)velocity animationOptions:(UIViewAnimationOptions)options completion:(void (^)(BOOL finished))completion{
    
    if (self.isAnimating) {
        if(completion){
            completion(NO);
        }
    }
    else {
        if (self.openedSlide != slideToShow) {
            [self prepareToPresentSlide:slideToShow animated:animated];
        }
        [self setAnimating:animated];
        
        [self presentSlide:slideToShow animated:animated velocity:velocity animationOptions:options completion:completion];
        
    }
}

- (void)closeSlide:(HITSlide)slide animated:(BOOL)animated completion:(void (^)(BOOL finished))completion{
  
    if ( slide == HITSlideNone ) {
        return;
    }
    UIViewController* controllerToHide = [self getViewControllerWithSlide:slide];
    if ( controllerToHide == nil ) {
        return;
    }
    if ( self.openedSlide == HITSlideNone ) {
        return;
    }
    if ( self.openedSlide != slide ) {
        return;
    }
    
   
    
    [self closeSlide:slide
            animated:animated
            velocity:self.animationVelocity
    animationOptions:UIViewAnimationOptionCurveEaseInOut
          completion:completion];
}

- (void)closeSlide:(HITSlide)slideToHide animated:(BOOL)animated velocity:(CGFloat)velocity animationOptions:(UIViewAnimationOptions)options completion:(void (^)(BOOL finished))completion{
    if(self.isAnimating){
        if(completion){
            completion(NO);
        }
    }
    else {
        //no opened slide
        if ( self.openedSlide == HITSlideNone) {
            return;
        }
        //the opened slide is not the close one
        if ( self.openedSlide != slideToHide ) {
            return;
        }
        [self setAnimating:animated];
        
        
        CGFloat distance = ABS(CGRectGetMinX(self.centerView.frame));
        NSTimeInterval duration = MAX(distance/ABS(velocity),0.15f);
        
        CGFloat percentVisble = 0.0;
        
        if( slideToHide == HITSlideLeft ){
            CGFloat visibleWidth = CGRectGetMinX(self.centerView.frame);
            percentVisble = MAX(0.0,visibleWidth / self.maximumLeftSlideWidth);
        }
        else if( slideToHide == HITSlideRight ){
            CGFloat visibleWidth = CGRectGetWidth(self.centerView.frame) - CGRectGetMaxX(self.centerView.frame);
            percentVisble = MAX(0.0,visibleWidth / self.maximumRightSlideWidth);
        }
        
        UIViewController * viewControllerToHide = [self getViewControllerWithSlide:slideToHide];
        
        [self updateAnimationForSlide:slideToHide percentVisible:percentVisble];
        
        [viewControllerToHide beginAppearanceTransition:NO animated:animated];
        CGRect toFrame = self.containerView.bounds;
        
        [UIView
         animateWithDuration:(animated?duration:0.0)
         delay:0.0
         options:options
         animations:^{
            
             [self.centerView setFrame:toFrame];
             [self updateAnimationForSlide:slideToHide percentVisible:0.0f];
        }
         completion:^(BOOL finished) {
             [viewControllerToHide endAppearanceTransition];
             [viewControllerToHide.view setHidden:YES];
             [self setOpenedSlide:HITSlideNone];
             [self resetDefaultStateForSlide:slideToHide];
             [self setAnimating:NO];
             if(completion){
                 completion(finished);
             }
         }];
    }
}


- (void)prepareToPresentSlide:(HITSlide)slideToShow animated:(BOOL)animated{
    
    HITSlide slideToHide = HITSlideNone;
    if(slideToShow == HITSlideLeft){
        slideToHide = HITSlideRight;
    }
    else if(slideToShow == HITSlideRight){
        slideToHide = HITSlideLeft;
    }
    
    UIViewController* viewControllerToShow = [self getViewControllerWithSlide:slideToShow];
    UIViewController* viewControllerToHide = [self getViewControllerWithSlide:slideToHide];
    
    [self.containerView sendSubviewToBack:viewControllerToHide.view];
    //[self.containerView bringSubviewToFront:viewControllerToShow.view];
    [self steadyInPositionForSlide:slideToShow];
    [viewControllerToHide.view setHidden:YES];
    [viewControllerToShow.view setHidden:NO];
    
    
    [self resetDefaultStateForSlide:slideToShow];
    [self updateAnimationForSlide:slideToShow percentVisible:0.0f];
    
}

- (void)presentSlide:(HITSlide)slideToShow
            animated:(BOOL)animated
            velocity:(CGFloat)velocity
    animationOptions:(UIViewAnimationOptions)options
          completion:(void (^)(BOOL finished))completion{
    
    UIViewController* viewControllerToShow = [self getViewControllerWithSlide:slideToShow];
    if (viewControllerToShow == nil) {
        return;
    }
    // if openedSlide == slideToShow
    // means the opened one opened by pan,but now need to finish open process by animation
    // so ,there is no need to appear/disappear again
    if (self.openedSlide != slideToShow) {
        [viewControllerToShow beginAppearanceTransition:YES animated:animated];
    }
    
    
    CGRect toFrame = CGRectZero;;
    CGRect fromFrame = self.centerView.frame;
    if( slideToShow == HITSlideLeft ){
        toFrame = self.centerView.frame;
        toFrame.origin.x = self.maximumLeftSlideWidth;
    }
    else if ( slideToShow == HITSlideRight ) {
        toFrame = self.centerView.frame;
        toFrame.origin.x = -self.maximumRightSlideWidth;
    }
    
    CGFloat distance = ABS( CGRectGetMinX(fromFrame) - CGRectGetMinX(toFrame) );
    NSTimeInterval duration = MAX( distance / ABS(velocity),0.15f );
    
    [UIView
     animateWithDuration:(animated?duration:0.0)
     delay:0.0
     options:options
     animations:^{
         [self.centerView setFrame:toFrame];
         [self updateAnimationForSlide:slideToShow percentVisible:1.0f];
     }
     completion:^(BOOL finished) {
         //End the appearance transition if it already wasn't open.
         // if openedSlide == slideToShow
         // means the opened one opened by pan,but now need to finish open process by animation
         // so ,there is no need to appear/disappear again
         if (self.openedSlide != slideToShow) {
             [viewControllerToShow endAppearanceTransition];
         }
         
         [self setOpenedSlide:slideToShow];
         
         [self resetDefaultStateForSlide:slideToShow];
         [self setAnimating:NO];
         if(completion){
             completion(finished);
         }
     }];
}




- (void)resetDefaultStateForSlide:(HITSlide)slideToShow{
    
    UIViewController * viewControllerToShow = [self getViewControllerWithSlide:slideToShow];
    
    [viewControllerToShow.view.layer setAnchorPoint:CGPointMake(0.5f, 0.5f)];
    [viewControllerToShow.view.layer setTransform:CATransform3DIdentity];
    [viewControllerToShow.view setAlpha:1.0];
}

- (void)updateAnimationForSlide:(HITSlide)sildeToShow percentVisible:(CGFloat)percentVisible{
    if(self.animationBlock){
        self.animationBlock(self,sildeToShow,percentVisible);
    }
}


- (void)steadyInPositionForSlide:(HITSlide)slide{
    if (slide == HITSlideNone)
        return;
    
    UIView* view = [self getViewControllerWithSlide:slide].view;
    CGRect rect = CGRectZero;
    if ( slide == HITSlideRight ){
        rect = [self rightSlidePosition];
    }
    else if ( slide == HITSlideLeft ){
        rect = [self leftSlidePosition];
    }
    
    [view setFrame:rect];
}

- (CGRect)leftSlidePosition{
    CGRect rect = self.view.bounds;
    rect.size.width = self.maximumLeftSlideWidth;
    return rect;
}

- (CGRect)rightSlidePosition{
    CGRect rect = self.view.bounds;
    rect.size.width = self.maximumRightSlideWidth;
    rect.origin.x = CGRectGetWidth(self.view.bounds) - rect.size.width;
    return rect;
}

- (void)setOpenedSlide:(HITSlide)openedSlide{
    if (_openedSlide == openedSlide) {
        return;
    }  
    _openedSlide = openedSlide;
    if (openedSlide == HITSlideNone ){
        [self resetDefaultStateForSlide:HITSlideLeft];
        [self resetDefaultStateForSlide:HITSlideRight];
    }
    [self.centerView setOpenedSlide:openedSlide];
}

- (void)setCenterInteractionMode:(HITCenterInteractionMode)centerInteractionMode{
    if( _centerInteractionMode == centerInteractionMode ){
        return;
    }
    _centerInteractionMode = centerInteractionMode;
    [self.centerView setCenterInteractionMode:centerInteractionMode];
    
}


#pragma mark - getters

- (UIView*)containerView{
    
    if (_containerView == nil) {
        
        CGRect frame = [[UIScreen mainScreen]bounds];
        _containerView = [[UIView alloc]initWithFrame:frame];
        _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _containerView.backgroundColor = [UIColor blackColor];
    }
    
    return _containerView;
}

- (HITCenterContainerView*)centerView{
    
    if (_centerView == nil) {
        CGRect frame = self.containerView.frame;
        _centerView = [[HITCenterContainerView alloc]initWithFrame:frame];
        _centerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _centerView.backgroundColor = [UIColor clearColor];
        [self updateShadowForCenterView];
        [self.containerView addSubview:_centerView];
        
    }
    return _centerView;
}

- (CGFloat)maximumLeftSlideWidth{
    if(self.leftViewController){
        return _maximumLeftSlideWidth;
    }
    else{
        return 0;
    }
}

- (CGFloat)maximumRightSlideWidth{
    if(self.rightViewController){
        return _maximumRightSlideWidth;
    }
    else {
        return 0;
    }
}

//current visible left slide's width
-(CGFloat)visibleLeftSlideWidth{
    return MAX(0.0,CGRectGetMinX(self.centerView.frame));
}

//current visible right slide width
-(CGFloat)visibleRightSlideWidth{
    if(CGRectGetMinX(self.centerView.frame) < 0){
        return CGRectGetWidth(self.containerView.bounds) - CGRectGetMaxX(self.centerView.frame);
    }
    else {
        return 0.0f;
    }
}

- (HITSlideAnimationBlock)animationBlock{
    return [[HITSlideAnimationManager manager]getAnimationBlockWithType:self.animationType];
}






#pragma mark - Gesture

- (UIPanGestureRecognizer*)panGesture{
    if (_panGesture == nil) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(screenPaned:)];
    }
    return _panGesture;
}

- (UITapGestureRecognizer*)tapGesture{
    if (_tapGesture == nil) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(screenTapped:)];
        [_tapGesture setNumberOfTapsRequired:1];
        [_tapGesture setDelegate:self];
    }
    return _tapGesture;
}

- (UIScreenEdgePanGestureRecognizer*)leftEdgeGeture{
    if (_leftEdgeGeture == nil) {
        _leftEdgeGeture = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(screenPaned:)];
        _leftEdgeGeture.edges = UIRectEdgeLeft;
        //_leftEdgeGeture.delegate = self;
    }
    return _leftEdgeGeture;
}

- (UIScreenEdgePanGestureRecognizer*)rightEdgeGeture{
    if (_rightEdgeGeture == nil) {
        _rightEdgeGeture = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(screenPaned:)];
        _rightEdgeGeture.edges = UIRectEdgeLeft;
       // _rightEdgeGeture.delegate = self;
    }
    return _rightEdgeGeture;
}

-(void)setupGestureRecognizers{
    
    [self.view addGestureRecognizer:self.panGesture];
    [self.view addGestureRecognizer:self.tapGesture];
    //[self.view addGestureRecognizer:self.leftEdgeGeture];
}


- (void)screenTapped:(UITapGestureRecognizer*)sender{
    if(self.openedSlide != HITSlideNone && self.isAnimating == NO){
        [self toggleSlide:self.openedSlide animated:YES completion:nil];
    }
    
}

- (void)screenPaned:(UIGestureRecognizer*)gesture{
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:{
            [self handlePanGestureBegin:gesture];
            break;
        }
        case UIGestureRecognizerStateChanged:{
            [self handlePanGestureChanged:gesture];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:{
            CGPoint velocity = [(UIPanGestureRecognizer*)gesture velocityInView:self.containerView];
            [self finishAnimationForPanGestureWithXVelocity:velocity.x];
            self.view.userInteractionEnabled = YES;
            break;
        }
        default:
            break;
    }
}

- (void)handlePanGestureBegin:(UIGestureRecognizer*)gesture{
    if(self.isAnimating){
        [gesture setEnabled:NO];
    }
    else {
        self.view.userInteractionEnabled = NO;
        
    }
    self.centerOriginalRect = self.centerView.frame;
}

- (void)handlePanGestureChanged:(UIGestureRecognizer*)gesture{
    
    UIPanGestureRecognizer* panGesture = (UIPanGestureRecognizer*)gesture;
    CGRect toFrame = self.centerView.frame;
    CGPoint translationPoint = [panGesture translationInView:self.containerView];
    toFrame.origin.x = [self translationLimited:translationPoint.x + self.centerOriginalRect.origin.x];
    CGFloat xOffset = toFrame.origin.x;
    
    HITSlide visibleSide = HITSlideNone;
    CGFloat percentVisible = 0.0;
    if( xOffset >= 0 ){
        visibleSide = HITSlideLeft;
        percentVisible = xOffset / self.maximumLeftSlideWidth;
    }
    else if( xOffset < 0 ){
        visibleSide = HITSlideRight;
        percentVisible = ABS(xOffset) / self.maximumRightSlideWidth;
    }
    
    if( visibleSide == HITSlideNone ){
        [self setOpenedSlide:HITSlideNone];
    }
    if( self.openedSlide != visibleSide ){
        //Handle disappearing the visible slide
        
        UIViewController * viewControllerToHide = [self getViewControllerWithSlide:self.openedSlide];
        [viewControllerToHide beginAppearanceTransition:NO animated:NO];
        [self resetDefaultStateForSlide:self.openedSlide];
        [viewControllerToHide endAppearanceTransition];
        
        //Drawer is about to become visible
        UIViewController * viewControllerToShow = [self getViewControllerWithSlide:visibleSide];
        [viewControllerToShow beginAppearanceTransition:YES animated:NO];
        [self prepareToPresentSlide:visibleSide animated:NO];
        [viewControllerToShow endAppearanceTransition];
        
        [self setOpenedSlide:visibleSide];
    }
    
    
    [self updateAnimationForSlide:visibleSide percentVisible:percentVisible];
    
    [self.centerView setCenter:CGPointMake(CGRectGetMidX(toFrame), CGRectGetMidY(toFrame))];
    
    toFrame = self.centerView.frame;
    toFrame.origin.x = floor(toFrame.origin.x);
    toFrame.origin.y = floor(toFrame.origin.y);
    self.centerView.frame = toFrame;

}


- (CGFloat)translationLimited:(CGFloat)originX{
    
    if (originX < -self.maximumRightSlideWidth) {
        return -self.maximumRightSlideWidth;
    }
    else if(originX > self.maximumLeftSlideWidth){
        return self.maximumLeftSlideWidth;
    }
    
    return originX;
}

- (void)finishAnimationForPanGestureWithXVelocity:(CGFloat)xVelocity{
    CGFloat currentOriginX = CGRectGetMinX(self.centerView.frame);
    
    CGFloat animationVelocity = MAX(ABS(xVelocity),self.panVelocityAnimationThreshold * 2);
    
    if(self.openedSlide == HITSlideLeft) {
        CGFloat midPoint = self.maximumLeftSlideWidth / 2.0;
        if ( xVelocity > self.panVelocityAnimationThreshold ){
            [self openSlide:HITSlideLeft animated:YES velocity:animationVelocity animationOptions:UIViewAnimationOptionCurveEaseOut completion:nil];
        }
        else if( xVelocity < -self.panVelocityAnimationThreshold ){
            [self closeSlide:HITSlideLeft animated:YES velocity:animationVelocity animationOptions:UIViewAnimationOptionCurveEaseOut completion:nil];
        }
        else if(currentOriginX < midPoint){
            [self closeSlide:HITSlideLeft animated:YES completion:nil];
        }
        else {
            [self openSlide:HITSlideLeft animated:YES completion:nil];
        }
    }
    else if( self.openedSlide == HITSlideRight ){
        currentOriginX = CGRectGetMaxX(self.centerView.frame);
        CGFloat midPoint = (CGRectGetWidth(self.containerView.bounds) - self.maximumRightSlideWidth) + (self.maximumRightSlideWidth / 2.0);
        if( xVelocity > self.panVelocityAnimationThreshold ){
            [self closeSlide:HITSlideRight animated:YES velocity:animationVelocity animationOptions:UIViewAnimationOptionCurveEaseOut completion:nil];
        }
        else if (xVelocity < -self.panVelocityAnimationThreshold){
            [self openSlide:HITSlideRight animated:YES velocity:animationVelocity animationOptions:UIViewAnimationOptionCurveEaseOut completion:nil];
        }
        else if(currentOriginX > midPoint){
            [self closeSlide:HITSlideRight animated:YES completion:nil];
        }
        else {
            [self openSlide:HITSlideRight animated:YES completion:nil];
        }
    }

}


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer == self.tapGesture) {
        if (self.openedSlide == HITSlideNone) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - Life Circle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupGestureRecognizers];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated{
   
    [super viewWillDisappear:animated];
}

- (void)loadView{
    //check if self is load from storyboard
    if (self.storyboard) {
        [self loadControllersFromStoryboard];
    }
    self.view = self.containerView;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Shoadow
-(void)setShowsShadow:(BOOL)showsShadow{
    _showsShadow = showsShadow;
    [self updateShadowForCenterView];
}

- (void)setShadowRadius:(CGFloat)shadowRadius{
    _shadowRadius = shadowRadius;
    [self updateShadowForCenterView];
}

- (void)setShadowOpacity:(CGFloat)shadowOpacity{
    _shadowOpacity = shadowOpacity;
    [self updateShadowForCenterView];
}

- (void)setShadowOffset:(CGSize)shadowOffset{
    _shadowOffset = shadowOffset;
    [self updateShadowForCenterView];
}

- (void)setShadowColor:(UIColor *)shadowColor{
    _shadowColor = shadowColor;
    [self updateShadowForCenterView];
}

-(void)updateShadowForCenterView{
    UIView * centerView = self.centerView;
    if(self.showsShadow){
        centerView.layer.masksToBounds = NO;
        centerView.layer.shadowRadius = self.shadowRadius;
        centerView.layer.shadowOpacity = self.shadowOpacity;
        centerView.layer.shadowOffset = self.shadowOffset;
        centerView.layer.shadowColor = [self.shadowColor CGColor];
        
        /** In the event this gets called a lot, we won't update the shadowPath
         unless it needs to be updated (like during rotation) */
        if (centerView.layer.shadowPath == NULL) {
            centerView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:self.centerView.bounds] CGPath];
        }
        else{
            CGRect currentPath = CGPathGetPathBoundingBox(centerView.layer.shadowPath);
            if (CGRectEqualToRect(currentPath, centerView.bounds) == NO){
                centerView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:self.centerView.bounds] CGPath];
            }
        }
    }
    else if (centerView.layer.shadowPath != NULL) {
        centerView.layer.shadowRadius = 0.f;
        centerView.layer.shadowOpacity = 0.f;
        centerView.layer.shadowOffset = CGSizeMake(0, -2);
        centerView.layer.shadowPath = NULL;
        centerView.layer.masksToBounds = YES;
    }
}

#pragma mark - Left & Right size


- (void)setMaximumRightSlideWidth:(CGFloat)maximumRightSlideWidth{
    [self setMaximumRightSlideWidth:maximumRightSlideWidth animated:NO];
}

- (void)setMaximumRightSlideWidth:(CGFloat)maximumRightSlideWidth animated:(BOOL)animated{
    [self setMaximumSlideWidth:maximumRightSlideWidth forSlide:HITSlideRight animated:animated];
}

- (void)setMaximumLeftSlideWidth:(CGFloat)maximumLeftSlideWidth{
    [self setMaximumLeftSlideWidth:maximumLeftSlideWidth animated:NO];
}

-(void)setMaximumLeftSlideWidth:(CGFloat)maximumLeftSlideWidth animated:(BOOL)animated{
    [self setMaximumSlideWidth:maximumLeftSlideWidth forSlide:HITSlideLeft animated:animated];
}

- (void)setMaximumSlideWidth:(CGFloat)maximumWidth forSlide:(HITSlide)slide animated:(BOOL)animated{
    if ( slide == HITSlideNone ) {
        return;
    }
    
    UIViewController *viewControllerToShow = [self getViewControllerWithSlide:slide];
    CGFloat oldWidth = 0.f;
    NSInteger slideOriginCorrection = 1;
    if (slide == HITSlideLeft) {
        oldWidth = _maximumLeftSlideWidth;
        _maximumLeftSlideWidth = maximumWidth;
    }
    else if(slide == HITSlideRight){
        oldWidth = _maximumRightSlideWidth;
        _maximumRightSlideWidth = maximumWidth;
        slideOriginCorrection = -1;
    }
    
    CGFloat distance = ABS(maximumWidth - oldWidth);
    NSTimeInterval duration = [self animationDurationForAnimationDistance:distance];
    
    CGRect newSlideFrame = [self getMaximumFrameForSlide:slide];
    if(self.openedSlide == slide){
        CGRect newCenterRect = self.centerView.frame;
        newCenterRect.origin.x =  slideOriginCorrection * maximumWidth;
        [UIView animateWithDuration:(animated?duration:0) animations:^{
            [self.centerView setFrame:newCenterRect];
            [viewControllerToShow.view setFrame:newSlideFrame];
        }];
    }
    else{
        [viewControllerToShow.view setFrame:newSlideFrame];
    }
}

- (CGRect)getMaximumFrameForSlide:(HITSlide)slide{
    CGRect frame = CGRectZero;
    if (slide == HITSlideNone) {
        frame = CGRectZero;
    }
    else if (slide == HITSlideRight) {
        frame = [self getViewControllerWithSlide:HITSlideRight].view.bounds;
        frame.size.width = self.maximumRightSlideWidth;
    }
    else if (slide == HITSlideLeft) {
        frame = [self getViewControllerWithSlide:HITSlideLeft].view.bounds;
        frame.size.width = self.maximumLeftSlideWidth;
    }
    
    return frame;
}

-(NSTimeInterval)animationDurationForAnimationDistance:(CGFloat)distance{
    NSTimeInterval duration = MAX(distance/self.animationVelocity,0.15f);
    return duration;
}
#pragma mark - Storyboard support

- (void)loadControllersFromStoryboard{
    
    if (!self.storyboard) {
        return;
    }
    
    
    //Try each segue separately so it doesn't break prematurely if either Rear or Right views are not used.
    @try
    {
        [self performSegueWithIdentifier:HITSegueCenterIdentifier sender:self];
    }
    @catch(NSException *exception) {}
    
    @try
    {
        [self performSegueWithIdentifier:HITSegueLeftIdentifier sender:self];
    }
    @catch(NSException *exception) {}
    
    @try
    {
        [self performSegueWithIdentifier:HITSegueRightIdentifier sender:self];
    }
    @catch(NSException *exception) {}


}


@end

#pragma mark - Category

@implementation UIViewController (HITSlideController)

- (HITSlideController*)slideController{
    UIViewController *parent = self;
    Class slideClass = [HITSlideController class];
    while ( parent != nil  ) {
        if( [parent isKindOfClass:slideClass] ){
            break;
        }
        parent = [parent parentViewController];
    }
    return (id)parent;
}

@end

#pragma mark - Segue

#pragma mark - Segue identifiers

NSString* const HITSegueCenterIdentifier = @"hit_center";  // this is @"hit_center"
NSString* const HITSegueLeftIdentifier   = @"hit_left";      // this is @"hit_left"
NSString* const HITSegueRightIdentifier  = @"hit_right";    // this is @"hit_right"


#pragma mark - SWRevealViewControllerSegueSetController class

@implementation HITSlideControllerSetSegue

- (void)perform
{
    HITOperationType operationType = HITOperationNone;
    
   
    NSString *identifier = self.identifier;
    HITSlideController* slideController = self.sourceViewController;
    UIViewController *destinationViewController = self.destinationViewController;
    if ( [identifier isEqualToString:HITSegueCenterIdentifier] ){
        operationType = HITOperationSetCenterController;

    }
    else if ( [identifier isEqualToString:HITSegueLeftIdentifier] ){
         operationType = HITOperationSetLeftController;
    }
    
    else if ( [identifier isEqualToString:HITSegueRightIdentifier] ){
        operationType = HITOperationSetRightController;

    }
    
    [slideController performOperation:operationType withViewController:destinationViewController];
}

@end



