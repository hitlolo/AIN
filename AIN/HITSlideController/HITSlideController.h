//
//  HITSlideController.h
//
//  Created by Lolo.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, HITCenterInteractionMode) {
    HITCenterInteractionModeNone,
    HITCenterInteractionModeFull,
    HITCenterInteractionModeNavigationBarOnly
};

typedef NS_ENUM(NSInteger, HITSlide){
    HITSlideNone,
    HITSlideLeft,
    HITSlideRight
};

typedef NS_ENUM(NSInteger, HITOperationType){
    HITOperationNone,
    HITOperationSetCenterController,
    HITOperationSetLeftController,
    HITOperationSetRightController
};


// Enum values for toggleAnimationType
typedef NS_ENUM(NSInteger, HITAnimationType){
    HITAnimationDefault,
    HITAnimationSlide,
    HITAnimationSlideAndScale,
    HITAnimationSwingDoor,
    HITAnimationParallax


};

@interface HITSlideController : UIViewController

#pragma mark - ViewControllers
//---------------------------------------
/// @name Accessing Drawer Container View Controller Properties
///---------------------------------------

/**
 The center view controller.
 Can be nil at the initialization time but must be supplied by the time the view is loaded
 Can set via the init method, storyboard segue method, and `setCenterViewController:`method.
 
 The size of this view controller will automatically be set to the size of the slide container view controller, and it's position is modified from within this class. Do not modify the frame externally.
 */
@property (nonatomic, strong, null_resettable) UIViewController* centerViewController;

/**
 The left slide view controller.
 Can be nil if not used.
 
 The size of this view controller is managed within this class, and is automatically set to the appropriate size based on the `maximumLeftSlideWidth`. Do not modify the frame externally.
 */
@property (nonatomic, strong, nullable) UIViewController* leftViewController;

/**
 The right drawer view controller.
 Can be nil if not used.
 The size of this view controller is managed within this class, and is automatically set to the appropriate size based on the `maximumRightSlideWidth`. Do not modify the frame externally.
 */
@property (nonatomic, strong, nullable) UIViewController* rightViewController;



#pragma mark - Customizable Size Properties
//---------------------------------------
/// @name The following properties are provided for further customization, they are set to default values on initialization,
//        you do not generally have to set them
///---------------------------------------

/**
 The maximum width of the `leftViewController` and `rightViewController`.
 
 By default, this is set to 280. If the `leftViewController` or `rightViewController` is nil, this property will return 0.0;
 */
@property (nonatomic, assign) CGFloat maximumLeftSlideWidth;
@property (nonatomic, assign) CGFloat maximumRightSlideWidth;

/**
 The visible width of the `leftViewController` and `rightViewController`.
 
 Note this value can be greater than `maximumLeftDrawerWidth` during the full close animation when setting a new center view controller;
 */
@property (nonatomic, assign, readonly) CGFloat visibleLeftSlideWidth;
@property (nonatomic, assign, readonly) CGFloat visibleRightSlideWidth;



#pragma mark - Customizable Shadow Properties

/**
 The flag determining if a shadow should be drawn off of `centerViewController` when a drawer is open.
 
 By default, this is set to YES.
 */
@property (nonatomic, assign) BOOL showsShadow;

/**
 The shadow radius of `centerViewController` when a drawer is open.
 
 By default, this is set to 10.0f;
 */
@property (nonatomic, assign) CGFloat shadowRadius;

/**
 The shadow opacity of `centerViewController` when a drawer is open.
 
 By default, this is set to 0.8f;
 */
@property (nonatomic, assign) CGFloat shadowOpacity;

/**
 The shadow offset of `centerViewController` when a drawer is open.
 
 By default, this is set to (0, -2);
 */
@property (nonatomic, assign) CGSize shadowOffset;

/**
 The color of the shadow drawn off of 'centerViewController` when a drawer is open.
 
 By default, this is set to the systme default (opaque black).
 */
@property (nonatomic, strong, nonnull) UIColor* shadowColor;


#pragma mark - Customizable Gesture Properties
/**
 The value determining if the user can open or close drawer with panGesture velocity.
 
 By default, this is set 200.0f.
 */
@property (nonatomic, assign) CGFloat panVelocityAnimationThreshold;

@property (nonatomic, strong, nonnull)UIPanGestureRecognizer* panGesture;
@property (nonatomic, strong, nonnull)UITapGestureRecognizer* tapGesture;
@property (nonatomic, strong, nonnull)UIScreenEdgePanGestureRecognizer* leftEdgeGeture;
@property (nonatomic, strong, nonnull)UIScreenEdgePanGestureRecognizer* rightEdgeGeture;

#pragma mark - Customizable Animation Properties

/**
 AnimationType
 Default is HITAnimationDefault
 */
@property (nonatomic, assign) HITAnimationType animationType;


/**
 The animation velocity of the open and close methods, measured in points per second.
 
 By default, this is set to 840 points per second (three times the default drawer width), meaning it takes 1/3 of a second for the `centerViewController` to open/close across the default drawer width. Note that there is a minimum .1 second duration for built in animations, to account for small distance animations.
 */

@property (nonatomic, assign) CGFloat animationVelocity;

#pragma mark - Customizable Interaction Mode for center view
/**
 The  interaction mode is for center view.
 When left or right slide opened, use this property to decide the center view 's interaction ability.
 By default ,it set as `HITCenterInteractionModeNavigationBarOnly`
 */
@property (nonatomic, assign)HITCenterInteractionMode centerInteractionMode;

#pragma mark - UnCustomizable Current open slide
/**
 The current opened side: right or left or none.
 */
@property (nonatomic, assign, readonly)HITSlide openedSlide;
#pragma mark -  initialization methods

///---------------------------------------
/// @name Initializing
///---------------------------------------

/**
 Creates and initializes an `HITSlideController` object with the specified center view controller, left  view controller, and right  view controller.
 
 @param centerViewController The center view controller. 
 @param leftDrawerViewController The left drawer view controller.
 @param rightDrawerViewController The right drawer controller.
 
 @return The newly-initialized drawer container view controller.
 */
- (nullable instancetype)initWithCenterViewController:(nullable UIViewController*)centerViewController
                          leftViewController:(nullable UIViewController*)leftViewController
                         rightViewController:(nullable UIViewController*)rightViewController;


- (nullable instancetype)initWithCenterViewController:(nullable UIViewController*)centerViewController
                             leftViewController:(nullable UIViewController*)leftViewController;

- (nullable instancetype)initWithCenterViewController:(nullable UIViewController*)centerViewController
                            rightViewController:(nullable UIViewController*)rightViewController;


- (nullable instancetype)initWithCenterViewController:(nullable UIViewController*)centerViewController;



//TODO: auto rotation
//TODO: state restore
#pragma mark - open & close
- (IBAction)toggleLeftSlide:(nonnull id)sender;
- (IBAction)toggleRightSlide:(nonnull id)sender;

- (void)toggleRightSlideAnimated:(BOOL)animated completion:(nullable void (^)(BOOL finished))completion;
- (void)toggleLeftSlideAnimated:(BOOL)animated completion:(nullable void (^)(BOOL finished))completion;



#pragma mark - Helpers

- (nullable UIViewController*)getViewControllerWithSlide:(HITSlide)slide;

@end

#pragma mark - Category
#pragma mark - UIViewController(HITSlideController)
@interface UIViewController(HITSlideController)
- (nullable HITSlideController*)slideController;
@end
#pragma mark -
#pragma mark - StoryBoard support Classes

/* StoryBoard support */

// String identifiers to be applied to segues on a storyboard
extern NSString* _Nonnull const HITSegueCenterIdentifier;  // this is @"hit_center"
extern NSString* _Nonnull const HITSegueLeftIdentifier;    // this is @"hit_left"
extern NSString* _Nonnull const HITSegueRightIdentifier;   // this is @"hit_right"

/* This will allow the class to be defined on a storyboard */

// Use this along with one of the above segue identifiers to segue to the initial state
@interface HITSlideControllerSetSegue : UIStoryboardSegue
@end



