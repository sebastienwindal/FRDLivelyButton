//
//  FRDLivelyButton.h.m
//  FRDLivelyButton.h
//
//  Created by Sebastien Windal on 2/24/14.
//  MIT license. See the LICENSE file distributed with this work.
//

#import "FRDLivelyButton.h"


NSString *const kFRDLivelyButtonHighlightScale = @"kFRDLivelyButtonHighlightScale";
NSString *const kFRDLivelyButtonLineWidth = @"kFRDLivelyButtonLineWidth";
NSString *const kFRDLivelyButtonColor = @"kFRDLivelyButtonColor";
NSString *const kFRDLivelyButtonHighlightedColor = @"kFRDLivelyButtonHighlightedColor";
NSString *const kFRDLivelyButtonHighlightAnimationDuration = @"kFRDLivelyButtonHighlightAnimationDuration";
NSString *const kFRDLivelyButtonUnHighlightAnimationDuration = @"kFRDLivelyButtonUnHighlightAnimationDuration";
NSString *const kFRDLivelyButtonStyleChangeAnimationDuration = @"kFRDLivelyButtonStyleChangeAnimationDuration";


@interface FRDLivelyButton()

@property (nonatomic) kFRDLivelyButtonStyle buttonStyle;
@property (nonatomic) CGFloat dimension;
@property (nonatomic) CGPoint offset;
@property (nonatomic) CGPoint centerPoint;

@property (nonatomic, strong) CAShapeLayer *circleLayer;
@property (nonatomic, strong) CAShapeLayer *line1Layer;
@property (nonatomic, strong) CAShapeLayer *line2Layer;
@property (nonatomic, strong) CAShapeLayer *line3Layer;

@property (nonatomic, strong) CAShapeLayer *line4Layer;
@property (nonatomic, strong) CAShapeLayer *line5Layer;
@property (nonatomic, strong) CAShapeLayer *line6Layer;

@property (nonatomic, strong) NSArray *shapeLayers;


@end

#define GOLDEN_RATIO 1.618

@implementation FRDLivelyButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInitializer];
    }
    return self;
}

-( id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInitializer];
    }
    return self;
}

-(void) commonInitializer
{
    
    self.line1Layer = [[CAShapeLayer alloc] init];
    self.line2Layer = [[CAShapeLayer alloc] init];
    self.line3Layer = [[CAShapeLayer alloc] init];

    self.line4Layer = [[CAShapeLayer alloc] init];
    self.line5Layer = [[CAShapeLayer alloc] init];
    self.line6Layer = [[CAShapeLayer alloc] init];

    self.circleLayer = [[CAShapeLayer alloc] init];
    
    self.options = [FRDLivelyButton defaultOptions];
    
    [@[ self.line1Layer, self.line2Layer, self.line3Layer, self.line4Layer, self.line5Layer, self.line6Layer, self.circleLayer ] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CAShapeLayer *layer = obj;
        layer.fillColor = [UIColor clearColor].CGColor;
        layer.anchorPoint = CGPointMake(0.0, 0.0);
        layer.lineJoin = kCALineJoinRound;
        layer.lineCap = kCALineCapRound;
        layer.contentsScale = self.layer.contentsScale;
        
        // initialize with an empty path so we can animate the path w/o having to check for NULLs. 
        CGPathRef dummyPath = CGPathCreateMutable();
        layer.path = dummyPath;
        CGPathRelease(dummyPath);

        [self.layer addSublayer:layer];
    }];
    
    
    [self addTarget:self action:@selector(showHighlight) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(showUnHighlight) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(showUnHighlight) forControlEvents:UIControlEventTouchUpOutside];
    
    // in case the button is not square, the offset will be use to keep our CGPath's centered in it.
    self.dimension = MIN(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    self.offset = CGPointMake((CGRectGetWidth(self.frame) - self.dimension) / 2.0f,
                              (CGRectGetHeight(self.frame) - self.dimension) / 2.0f);
    
    self.centerPoint = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

-(void) setOptions:(NSDictionary *)options
{
    _options = options;
    
    [@[ self.line1Layer, self.line2Layer, self.line3Layer, self.line4Layer, self.line5Layer, self.line6Layer, self.circleLayer ] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CAShapeLayer *layer = obj;
        layer.lineWidth = [[self valueForOptionKey:kFRDLivelyButtonLineWidth] floatValue];
        layer.strokeColor = [[self valueForOptionKey:kFRDLivelyButtonColor] CGColor];
    }];
}

-(id) valueForOptionKey:(NSString *)key
{
    if (self.options[key]) {
        return self.options[key];
    }
    return [FRDLivelyButton defaultOptions][key];
}

-(NSArray *) shapeLayers
{
    if (_shapeLayers == nil) {
        _shapeLayers = @[ self.circleLayer,
                          self.line1Layer,
                          self.line2Layer,
                          self.line3Layer,
                          self.line4Layer,
                          self.line5Layer,
                          self.line6Layer ];
    }
    return _shapeLayers;
}

+(NSDictionary *) defaultOptions
{
    return @{
             kFRDLivelyButtonColor: [UIColor blackColor],
             kFRDLivelyButtonHighlightedColor: [UIColor lightGrayColor],
             kFRDLivelyButtonHighlightAnimationDuration: @(0.1),
             kFRDLivelyButtonHighlightScale: @(0.9),
             kFRDLivelyButtonLineWidth: @(1.0),
             kFRDLivelyButtonUnHighlightAnimationDuration: @(0.15),
             kFRDLivelyButtonStyleChangeAnimationDuration: @(0.3)
             };
}


-(CGAffineTransform) transformWithScale:(CGFloat)scale
{
    CGAffineTransform transform = CGAffineTransformMakeTranslation((self.dimension + 2 * self.offset.x) * ((1-scale)/2.0f),
                                                                   (self.dimension + 2 * self.offset.y)  * ((1-scale)/2.0f));
    return CGAffineTransformScale(transform, scale, scale);
}

// you are responsible for releasing the return CGPath
-(CGPathRef) createCenteredCircleWithRadius:(CGFloat)radius
{
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, self.centerPoint.x + radius, self.centerPoint.y);
    // note: if clockwise is set to true, the circle will not draw on an actual device,
    // event hough it is fine on the simulator...
    CGPathAddArc(path, NULL, self.centerPoint.x, self.centerPoint.y, radius, 0, 2 * M_PI, false);
    
    return path;
}

// you are responsible for releasing the return CGPath
-(CGPathRef) createCenteredCircleWithRadius:(CGFloat)radius offset:(CGPoint)offset
{
    CGMutablePathRef path = CGPathCreateMutable();

    CGPathMoveToPoint(path, NULL, self.centerPoint.x + radius + offset.x, self.centerPoint.y + offset.y);
    // note: if clockwise is set to true, the circle will not draw on an actual device,
    // event hough it is fine on the simulator...
    CGPathAddArc(path, NULL, self.centerPoint.x + offset.x, self.centerPoint.y + offset.y, radius, 0, 2 * M_PI, false);

    return path;
}

// you are responsible for releasing the return CGPath
-(CGPathRef) createCenteredLineWithRadius:(CGFloat)radius angle:(CGFloat)angle offset:(CGPoint)offset
{
    CGMutablePathRef path = CGPathCreateMutable();
    
    float c = cosf(angle);
    float s = sinf(angle);
    
    CGPathMoveToPoint(path, NULL,
                      self.centerPoint.x + offset.x + radius * c,
                      self.centerPoint.y + offset.y + radius * s);
    CGPathAddLineToPoint(path, NULL,
                         self.centerPoint.x + offset.x - radius * c,
                         self.centerPoint.y + offset.y - radius * s);
    
    return path;
}

-(CGPathRef) createLineFromPoint:(CGPoint)p1 toPoint:(CGPoint)p2
{
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, self.offset.x + p1.x, self.offset.y + p1.y);
    CGPathAddLineToPoint(path, NULL, self.offset.x + p2.x, self.offset.y + p2.y);
    
    return path;
}

-(void) setStyle:(kFRDLivelyButtonStyle)style animated:(BOOL)animated
{
    self.buttonStyle = style;
    
    CGPathRef newCirclePath = NULL;
    CGPathRef newLine1Path = NULL;
    CGPathRef newLine2Path = NULL;
    CGPathRef newLine3Path = NULL;
    CGPathRef newLine4Path = NULL;
    CGPathRef newLine5Path = NULL;
    CGPathRef newLine6Path = NULL;

    CGFloat newCircleAlpha = 0.0f;
    CGFloat newLine1Alpha = 0.0f;
    CGFloat newLine2Alpha = 0.0f;
    CGFloat newLine3Alpha = 0.0f;
    CGFloat newLine4Alpha = 0.0f;
    CGFloat newLine5Alpha = 0.0f;
    CGFloat newLine6Alpha = 0.0f;

    // first compute the new paths for our 4 layers.
    if (style == kFRDLivelyButtonStyleHamburger) {
        newCirclePath = [self createCenteredCircleWithRadius:self.dimension/20.0f];

        newLine1Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];
        newLine1Alpha = 1.0f;
        newLine2Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, -self.dimension/2.0f/GOLDEN_RATIO)];
        newLine2Alpha = 1.0f;
        newLine3Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, self.dimension/2.0f/GOLDEN_RATIO)];
        newLine3Alpha = 1.0f;

        newLine4Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];
        newLine5Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];
        newLine6Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];

    } else if (style == kFRDLivelyButtonStylePlus) {
        newCirclePath = [self createCenteredCircleWithRadius:self.dimension/20.0f];

        newLine1Path = [self createCenteredLineWithRadius:self.dimension/20.0f angle:0 offset:CGPointMake(0, 0)];
        newLine1Alpha = 0.0f;
        newLine2Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:+M_PI_2 offset:CGPointMake(0, 0)];
        newLine2Alpha = 1.0f;
        newLine3Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];
        newLine3Alpha = 1.0f;

        newLine4Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];
        newLine5Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];
        newLine6Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];

    } else if (style == kFRDLivelyButtonStyleCirclePlus) {
        newCirclePath = [self createCenteredCircleWithRadius:self.dimension/2.0f];

        newLine1Path = [self createCenteredLineWithRadius:self.dimension/20.0f angle:0 offset:CGPointMake(0, 0)];
        newLine1Alpha = 0.0f;
        newLine2Path = [self createCenteredLineWithRadius:self.dimension/2.0f/GOLDEN_RATIO angle:M_PI_2 offset:CGPointMake(0, 0)];
        newLine2Alpha = 1.0f;
        newLine3Path = [self createCenteredLineWithRadius:self.dimension/2.0f/GOLDEN_RATIO angle:0 offset:CGPointMake(0, 0)];
        newLine3Alpha = 1.0f;

        newLine4Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];
        newLine5Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];
        newLine6Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];

    } else if (style == kFRDLivelyButtonStyleClose) {
        newCirclePath = [self createCenteredCircleWithRadius:self.dimension/20.0f];

        newLine1Path = [self createCenteredLineWithRadius:self.dimension/20.0f angle:0 offset:CGPointMake(0, 0)];
        newLine1Alpha = 0.0f;
        newLine2Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:+M_PI_4 offset:CGPointMake(0, 0)];
        newLine2Alpha = 1.0f;
        newLine3Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:-M_PI_4 offset:CGPointMake(0, 0)];
        newLine3Alpha = 1.0f;

        newLine4Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];
        newLine5Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];
        newLine6Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];

    } else if (style == kFRDLivelyButtonStyleCircleClose) {
        newCirclePath = [self createCenteredCircleWithRadius:self.dimension/2.0f];

        newLine1Path = [self createCenteredLineWithRadius:self.dimension/20.0f angle:0 offset:CGPointMake(0, 0)];
        newLine1Alpha = 0.0f;
        newLine2Path = [self createCenteredLineWithRadius:self.dimension/2.0f/GOLDEN_RATIO angle:+M_PI_4 offset:CGPointMake(0, 0)];
        newLine2Alpha = 1.0f;
        newLine3Path = [self createCenteredLineWithRadius:self.dimension/2.0f/GOLDEN_RATIO angle:-M_PI_4 offset:CGPointMake(0, 0)];
        newLine3Alpha = 1.0f;

        newLine4Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];
        newLine5Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];
        newLine6Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];

    } else if (style == kFRDLivelyButtonStyleCaretUp) {
        newCirclePath = [self createCenteredCircleWithRadius:self.dimension/20.0f];

        newLine1Path = [self createCenteredLineWithRadius:self.dimension/20.0f angle:0 offset:CGPointMake(0, 0)];
        newLine1Alpha = 0.0f;
        newLine2Path = [self createCenteredLineWithRadius:self.dimension/4.0f - self.line2Layer.lineWidth/2.0f angle:M_PI_4 offset:CGPointMake(self.dimension/6.0f,0.0f)];
        newLine2Alpha = 1.0f;
        newLine3Path = [self createCenteredLineWithRadius:self.dimension/4.0f - self.line3Layer.lineWidth/2.0f angle:3*M_PI_4 offset:CGPointMake(-self.dimension/6.0f,0.0f)];
        newLine3Alpha = 1.0f;

        newLine4Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];
        newLine5Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];
        newLine6Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];

    } else if (style == kFRDLivelyButtonStyleCaretDown) {
        newCirclePath = [self createCenteredCircleWithRadius:self.dimension/20.0f];

        newLine1Path = [self createCenteredLineWithRadius:self.dimension/20.0f angle:0 offset:CGPointMake(0, 0)];
        newLine1Alpha = 0.0f;
        newLine2Path = [self createCenteredLineWithRadius:self.dimension/4.0f - self.line2Layer.lineWidth/2.0f angle:-M_PI_4 offset:CGPointMake(self.dimension/6.0f,0.0f)];
        newLine2Alpha = 1.0f;
        newLine3Path = [self createCenteredLineWithRadius:self.dimension/4.0f - self.line3Layer.lineWidth/2.0f angle:-3*M_PI_4 offset:CGPointMake(-self.dimension/6.0f,0.0f)];
        newLine3Alpha = 1.0f;

        newLine4Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];
        newLine5Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];
        newLine6Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];

    } else if (style == kFRDLivelyButtonStyleCaretLeft) {
        newCirclePath = [self createCenteredCircleWithRadius:self.dimension/20.0f];

        newLine1Path = [self createCenteredLineWithRadius:self.dimension/20.0f angle:0 offset:CGPointMake(0, 0)];
        newLine1Alpha = 0.0f;
        newLine2Path = [self createCenteredLineWithRadius:self.dimension/4.0f - self.line2Layer.lineWidth/2.0f angle:-3*M_PI_4 offset:CGPointMake(0.0f,self.dimension/6.0f)];
        newLine2Alpha = 1.0f;
        newLine3Path = [self createCenteredLineWithRadius:self.dimension/4.0f - self.line3Layer.lineWidth/2.0f angle:3*M_PI_4 offset:CGPointMake(0.0f,-self.dimension/6.0f)];
        newLine3Alpha = 1.0f;

        newLine4Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];
        newLine5Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];
        newLine6Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];

    } else if (style == kFRDLivelyButtonStyleCaretRight) {
        newCirclePath = [self createCenteredCircleWithRadius:self.dimension/20.0f];

        newLine1Path = [self createCenteredLineWithRadius:self.dimension/20.0f angle:0 offset:CGPointMake(0, 0)];
        newLine1Alpha = 0.0f;
        newLine2Path = [self createCenteredLineWithRadius:self.dimension/4.0f - self.line2Layer.lineWidth/2.0f angle:-M_PI_4 offset:CGPointMake(0.0f,self.dimension/6.0f)];
        newLine2Alpha = 1.0f;
        newLine3Path = [self createCenteredLineWithRadius:self.dimension/4.0f - self.line3Layer.lineWidth/2.0f angle:M_PI_4 offset:CGPointMake(0.0f,-self.dimension/6.0f)];
        newLine3Alpha = 1.0f;

        newLine4Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];
        newLine5Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];
        newLine6Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];

    } else if (style == kFRDLivelyButtonStyleArrowLeft) {
        newCirclePath = [self createCenteredCircleWithRadius:self.dimension/20.0f];

        newLine1Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:M_PI offset:CGPointMake(0, 0)];
        newLine1Alpha = 1.0f;
        newLine2Path = [self createLineFromPoint:CGPointMake(0, self.dimension/2.0f)
                                         toPoint:CGPointMake(self.dimension/2.0f/GOLDEN_RATIO, self.dimension/2+self.dimension/2.0f/GOLDEN_RATIO)];
        newLine2Alpha = 1.0f;
        newLine3Path = [self createLineFromPoint:CGPointMake(0, self.dimension/2.0f)
                                         toPoint:CGPointMake(self.dimension/2.0f/GOLDEN_RATIO, self.dimension/2-self.dimension/2.0f/GOLDEN_RATIO)];
        newLine3Alpha = 1.0f;

        newLine4Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];
        newLine5Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];
        newLine6Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];

    } else if (style == kFRDLivelyButtonStyleArrowRight) {
        newCirclePath = [self createCenteredCircleWithRadius:self.dimension/20.0f];

        newLine1Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];
        newLine1Alpha = 1.0f;
        newLine2Path = [self createLineFromPoint:CGPointMake(self.dimension, self.dimension/2.0f)
                                         toPoint:CGPointMake(self.dimension - self.dimension/2.0f/GOLDEN_RATIO, self.dimension/2+self.dimension/2.0f/GOLDEN_RATIO)];
        newLine2Alpha = 1.0f;
        newLine3Path = [self createLineFromPoint:CGPointMake(self.dimension, self.dimension/2.0f)
                                         toPoint:CGPointMake(self.dimension - self.dimension/2.0f/GOLDEN_RATIO, self.dimension/2-self.dimension/2.0f/GOLDEN_RATIO)];
        newLine3Alpha = 1.0f;

        newLine4Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];
        newLine5Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];
        newLine6Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];

    } else if (style == kFRDLivelyButtonStyleChevronDown) {
        newCirclePath = [self createCenteredCircleWithRadius:self.dimension/20.0f];

        double  yStartAnchor    = self.dimension/2.0f - self.dimension/2.0f/GOLDEN_RATIO/4.0f;
        double  yEndAnchor      = self.dimension/2.0f + self.dimension/2.0f/GOLDEN_RATIO/4.0f;

        newLine1Path = [self createLineFromPoint:CGPointMake(0, yStartAnchor)
                                         toPoint:CGPointMake(self.dimension/2.0f, yEndAnchor)];
        newLine1Alpha = 1.0f;
        newLine2Path = [self createLineFromPoint:CGPointMake(0, yStartAnchor - self.dimension/2.0f/GOLDEN_RATIO)
                                         toPoint:CGPointMake(self.dimension/2.0f, yEndAnchor - self.dimension/2.0f/GOLDEN_RATIO)];
        newLine2Alpha = 1.0f;
        newLine3Path = [self createLineFromPoint:CGPointMake(0, yStartAnchor + self.dimension/2.0f/GOLDEN_RATIO)
                                         toPoint:CGPointMake(self.dimension/2.0f, yEndAnchor + self.dimension/2.0f/GOLDEN_RATIO)];
        newLine3Alpha = 1.0f;

        newLine4Path = [self createLineFromPoint:CGPointMake(self.dimension/2.0f, yEndAnchor)
                                         toPoint:CGPointMake(self.dimension, yStartAnchor)];
        newLine4Alpha = 1.0f;
        newLine5Path = [self createLineFromPoint:CGPointMake(self.dimension/2.0f, yEndAnchor - self.dimension/2.0f/GOLDEN_RATIO)
                                         toPoint:CGPointMake(self.dimension, yStartAnchor - self.dimension/2.0f/GOLDEN_RATIO)];
        newLine5Alpha = 1.0f;
        newLine6Path = [self createLineFromPoint:CGPointMake(self.dimension/2.0f, yEndAnchor + self.dimension/2.0f/GOLDEN_RATIO)
                                         toPoint:CGPointMake(self.dimension, yStartAnchor + self.dimension/2.0f/GOLDEN_RATIO)];
        newLine6Alpha = 1.0f;

    } else if (style == kFRDLivelyButtonStyleChevronUp) {
        newCirclePath = [self createCenteredCircleWithRadius:self.dimension/20.0f];

        double  yStartAnchor    = self.dimension/2.0f + self.dimension/2.0f/GOLDEN_RATIO/4.0f;
        double  yEndAnchor      = self.dimension/2.0f - self.dimension/2.0f/GOLDEN_RATIO/4.0f;

        newLine1Path = [self createLineFromPoint:CGPointMake(0, yStartAnchor)
                                         toPoint:CGPointMake(self.dimension/2.0f, yEndAnchor)];
        newLine1Alpha = 1.0f;
        newLine2Path = [self createLineFromPoint:CGPointMake(0, yStartAnchor - self.dimension/2.0f/GOLDEN_RATIO)
                                         toPoint:CGPointMake(self.dimension/2.0f, yEndAnchor - self.dimension/2.0f/GOLDEN_RATIO)];
        newLine2Alpha = 1.0f;
        newLine3Path = [self createLineFromPoint:CGPointMake(0, yStartAnchor + self.dimension/2.0f/GOLDEN_RATIO)
                                         toPoint:CGPointMake(self.dimension/2.0f, yEndAnchor + self.dimension/2.0f/GOLDEN_RATIO)];
        newLine3Alpha = 1.0f;

        newLine4Path = [self createLineFromPoint:CGPointMake(self.dimension/2.0f, yEndAnchor)
                                         toPoint:CGPointMake(self.dimension, yStartAnchor)];
        newLine4Alpha = 1.0f;
        newLine5Path = [self createLineFromPoint:CGPointMake(self.dimension/2.0f, yEndAnchor - self.dimension/2.0f/GOLDEN_RATIO)
                                         toPoint:CGPointMake(self.dimension, yStartAnchor - self.dimension/2.0f/GOLDEN_RATIO)];
        newLine5Alpha = 1.0f;
        newLine6Path = [self createLineFromPoint:CGPointMake(self.dimension/2.0f, yEndAnchor + self.dimension/2.0f/GOLDEN_RATIO)
                                         toPoint:CGPointMake(self.dimension, yStartAnchor + self.dimension/2.0f/GOLDEN_RATIO)];
        newLine6Alpha = 1.0f;

    } else if (style == kFRDLivelyButtonStyleSearch) {
        newCirclePath = [self createCenteredCircleWithRadius:self.dimension/3.0f offset:CGPointMake(0 - self.dimension/3.0f/GOLDEN_RATIO/3.0f, 0 - self.dimension/3.0f/GOLDEN_RATIO/2.0f)];
        newCircleAlpha = 1.0f;

        newLine1Path = [self createCenteredLineWithRadius:self.dimension/4.0f angle:45.0f offset:CGPointMake(0 + self.dimension/3.0f/GOLDEN_RATIO + self.dimension/3.0f/GOLDEN_RATIO/2.0f - self.dimension/3.0f/GOLDEN_RATIO/4.0f, 0 + self.dimension/3.0f/GOLDEN_RATIO + self.dimension/3.0f/GOLDEN_RATIO/2.0f + self.dimension/3.0f/GOLDEN_RATIO/4.0f)];
        newLine1Alpha = 1.0f;
        newLine2Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];
        newLine3Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];

        newLine4Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];
        newLine5Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];
        newLine6Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];

    } else {
        NSAssert(FALSE, @"unknown type");
    }
    
    NSTimeInterval duration = [[self valueForOptionKey:kFRDLivelyButtonStyleChangeAnimationDuration] floatValue];
    
    // animate all the layer path and opacity
    if (animated) {
        {
            CABasicAnimation *circleAnim = [CABasicAnimation animationWithKeyPath:@"path"];
            circleAnim.removedOnCompletion = NO;
            circleAnim.duration = duration;
            circleAnim.fromValue = (__bridge id)self.circleLayer.path;
            circleAnim.toValue = (__bridge id)newCirclePath;
            [circleAnim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [self.circleLayer addAnimation:circleAnim forKey:@"animateCirclePath"];
        }
        {
            CABasicAnimation *circleAlphaAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
            circleAlphaAnim.removedOnCompletion = NO;
            circleAlphaAnim.duration = duration;
            circleAlphaAnim.fromValue = @(self.circleLayer.opacity);
            circleAlphaAnim.toValue = @(newCircleAlpha);
            [circleAlphaAnim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [self.circleLayer addAnimation:circleAlphaAnim forKey:@"animateCircleOpacityPath"];
        }
        {
            CABasicAnimation *line1Anim = [CABasicAnimation animationWithKeyPath:@"path"];
            line1Anim.removedOnCompletion = NO;
            line1Anim.duration = duration;
            line1Anim.fromValue = (__bridge id)self.line1Layer.path;
            line1Anim.toValue = (__bridge id)newLine1Path;
            [line1Anim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [self.line1Layer addAnimation:line1Anim forKey:@"animateLine1Path"];
        }
        {
            CABasicAnimation *line1AlphaAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
            line1AlphaAnim.removedOnCompletion = NO;
            line1AlphaAnim.duration = duration;
            line1AlphaAnim.fromValue = @(self.line1Layer.opacity);
            line1AlphaAnim.toValue = @(newLine1Alpha);
            [line1AlphaAnim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [self.line1Layer addAnimation:line1AlphaAnim forKey:@"animateLine1OpacityPath"];
        }
        {
            CABasicAnimation *line2Anim = [CABasicAnimation animationWithKeyPath:@"path"];
            line2Anim.removedOnCompletion = NO;
            line2Anim.duration = duration;
            line2Anim.fromValue = (__bridge id)self.line2Layer.path;
            line2Anim.toValue = (__bridge id)newLine2Path;
            [line2Anim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [self.line2Layer addAnimation:line2Anim forKey:@"animateLine2Path"];
        }
        {
            CABasicAnimation *line2AlphaAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
            line2AlphaAnim.removedOnCompletion = NO;
            line2AlphaAnim.duration = duration;
            line2AlphaAnim.fromValue = @(self.line2Layer.opacity);
            line2AlphaAnim.toValue = @(newLine2Alpha);
            [line2AlphaAnim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [self.line2Layer addAnimation:line2AlphaAnim forKey:@"animateLine2OpacityPath"];
        }
        {
            CABasicAnimation *line3Anim = [CABasicAnimation animationWithKeyPath:@"path"];
            line3Anim.removedOnCompletion = NO;
            line3Anim.duration = duration;
            line3Anim.fromValue = (__bridge id)self.line3Layer.path;
            line3Anim.toValue = (__bridge id)newLine3Path;
            [line3Anim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [self.line3Layer addAnimation:line3Anim forKey:@"animateLine3Path"];
        }
        {
            CABasicAnimation *line3AlphaAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
            line3AlphaAnim.removedOnCompletion = NO;
            line3AlphaAnim.duration = duration;
            line3AlphaAnim.fromValue = @(self.line3Layer.opacity);
            line3AlphaAnim.toValue = @(newLine3Alpha);
            [line3AlphaAnim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [self.line3Layer addAnimation:line3AlphaAnim forKey:@"animateLine3OpacityPath"];
        }

        {
            CABasicAnimation *line4Anim = [CABasicAnimation animationWithKeyPath:@"path"];
            line4Anim.removedOnCompletion = NO;
            line4Anim.duration = duration;
            line4Anim.fromValue = (__bridge id)self.line4Layer.path;
            line4Anim.toValue = (__bridge id)newLine4Path;
            [line4Anim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [self.line4Layer addAnimation:line4Anim forKey:@"animateLine4Path"];
        }
        {
            CABasicAnimation *line4AlphaAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
            line4AlphaAnim.removedOnCompletion = NO;
            line4AlphaAnim.duration = duration;
            line4AlphaAnim.fromValue = @(self.line4Layer.opacity);
            line4AlphaAnim.toValue = @(newLine4Alpha);
            [line4AlphaAnim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [self.line4Layer addAnimation:line4AlphaAnim forKey:@"animateLine4OpacityPath"];
        }
        {
            CABasicAnimation *line5Anim = [CABasicAnimation animationWithKeyPath:@"path"];
            line5Anim.removedOnCompletion = NO;
            line5Anim.duration = duration;
            line5Anim.fromValue = (__bridge id)self.line5Layer.path;
            line5Anim.toValue = (__bridge id)newLine5Path;
            [line5Anim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [self.line5Layer addAnimation:line5Anim forKey:@"animateLine5Path"];
        }
        {
            CABasicAnimation *line5AlphaAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
            line5AlphaAnim.removedOnCompletion = NO;
            line5AlphaAnim.duration = duration;
            line5AlphaAnim.fromValue = @(self.line5Layer.opacity);
            line5AlphaAnim.toValue = @(newLine5Alpha);
            [line5AlphaAnim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [self.line5Layer addAnimation:line5AlphaAnim forKey:@"animateLine5OpacityPath"];
        }
        {
            CABasicAnimation *line6Anim = [CABasicAnimation animationWithKeyPath:@"path"];
            line6Anim.removedOnCompletion = NO;
            line6Anim.duration = duration;
            line6Anim.fromValue = (__bridge id)self.line6Layer.path;
            line6Anim.toValue = (__bridge id)newLine6Path;
            [line6Anim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [self.line6Layer addAnimation:line6Anim forKey:@"animateLine6Path"];
        }
        {
            CABasicAnimation *line6AlphaAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
            line6AlphaAnim.removedOnCompletion = NO;
            line6AlphaAnim.duration = duration;
            line6AlphaAnim.fromValue = @(self.line6Layer.opacity);
            line6AlphaAnim.toValue = @(newLine6Alpha);
            [line6AlphaAnim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [self.line6Layer addAnimation:line6AlphaAnim forKey:@"animateLine6OpacityPath"];
        }
    }
    
    self.circleLayer.path = newCirclePath;
    self.circleLayer.opacity = newCircleAlpha;

    self.line1Layer.path = newLine1Path;
    self.line1Layer.opacity = newLine1Alpha;
    self.line2Layer.path = newLine2Path;
    self.line2Layer.opacity = newLine2Alpha;
    self.line3Layer.path = newLine3Path;
    self.line3Layer.opacity = newLine3Alpha;

    self.line4Layer.path = newLine4Path;
    self.line4Layer.opacity = newLine4Alpha;
    self.line5Layer.path = newLine5Path;
    self.line5Layer.opacity = newLine5Alpha;
    self.line6Layer.path = newLine6Path;
    self.line6Layer.opacity = newLine6Alpha;

    CGPathRelease(newCirclePath);
    
    CGPathRelease(newLine1Path);
    CGPathRelease(newLine2Path);
    CGPathRelease(newLine3Path);

    CGPathRelease(newLine4Path);
    CGPathRelease(newLine5Path);
    CGPathRelease(newLine6Path);
}

// animate button pressed event.
-(void) showHighlight
{
    float highlightScale = [[self valueForOptionKey:kFRDLivelyButtonHighlightScale] floatValue];
    
    [self.shapeLayers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setStrokeColor:[[self valueForOptionKey:kFRDLivelyButtonHighlightedColor] CGColor]];
        
        CAShapeLayer *layer = obj;
        
        CGAffineTransform transform = [self transformWithScale:highlightScale];
        CGPathRef scaledPath =  CGPathCreateMutableCopyByTransformingPath(layer.path, &transform);
        
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"path"];
        anim.duration = [[self valueForOptionKey:kFRDLivelyButtonHighlightAnimationDuration] floatValue];
        anim.removedOnCompletion = NO;
        anim.fromValue = (__bridge id) layer.path;
        anim.toValue = (__bridge id) scaledPath;
        [anim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [layer addAnimation:anim forKey:nil];
        
        layer.path = scaledPath;
        CGPathRelease(scaledPath);
    }];
}

// animate button release events i.e. touch up inside or outside.
-(void) showUnHighlight
{
    float unHighlightScale = 1/[[self valueForOptionKey:kFRDLivelyButtonHighlightScale] floatValue];

    [self.shapeLayers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setStrokeColor:[[self valueForOptionKey:kFRDLivelyButtonColor] CGColor]];
        
        CAShapeLayer *layer = obj;
        CGPathRef path = layer.path;
        
        CGAffineTransform transform = [self transformWithScale:unHighlightScale];
        CGPathRef finalPath =  CGPathCreateMutableCopyByTransformingPath(path, &transform);
        
        CGAffineTransform uptransform = [self transformWithScale:unHighlightScale * 1.07];
        CGPathRef scaledUpPath = CGPathCreateMutableCopyByTransformingPath(path, &uptransform);
        
        CGAffineTransform downtransform = [self transformWithScale:unHighlightScale * 0.97];
        CGPathRef scaledDownPath = CGPathCreateMutableCopyByTransformingPath(path, &downtransform);
        
        NSArray *values = @[
                                (__bridge id) layer.path,
                                (id) CFBridgingRelease(scaledUpPath),
                                (id) CFBridgingRelease(scaledDownPath),
                                (__bridge id) finalPath
                           ];
        NSArray *times = @[ @(0.0), @(0.85), @(0.93), @(1.0) ];
        
        CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"path"];
        anim.duration = [[self valueForOptionKey:kFRDLivelyButtonUnHighlightAnimationDuration] floatValue];
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        anim.removedOnCompletion = NO;

        anim.values = values;
        anim.keyTimes = times;
        
        [layer addAnimation:anim forKey:nil];
        
        layer.path = finalPath;
        CGPathRelease(finalPath);
    }];
    
    return;
}


-(void) dealloc
{
    
}
@end
