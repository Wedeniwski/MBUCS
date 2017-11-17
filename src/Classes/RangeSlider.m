//
//  RangeSlider.m
//  MercedesCarBoard
//
//  Created by Sebastian Wedeniwski on 01.11.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RangeSlider.h"

#define SLIDER_HEIGHT 60
#define CONTROL_WIDTH 30
#define CONTROL_HEIGHT 30

@interface RangeSlider ()

-(void)calculateMinMax;
-(void)setupSliders;
-(void)updateTrackImageViews;
-(void)updateThumbViews;

@end

@implementation RangeSlider

@synthesize min, max, preferred;
@synthesize attributeId;
@synthesize titleLabel, fromLabel, toLabel, preferredLabel;

-(id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, SLIDER_HEIGHT)];
  if (self != nil) {
		preferred = min = max = 0.0;
    attributeId = nil;
    
		backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, SLIDER_HEIGHT)];
		backgroundImageView.contentMode = UIViewContentModeScaleToFill;
		[self addSubview:backgroundImageView];
		
		subRangeTrackImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, min*frame.size.width, SLIDER_HEIGHT)];
		inRangeTrackImageView = [[UIImageView alloc] initWithFrame:CGRectMake(min*frame.size.width, 0, (max-min)*frame.size.width, SLIDER_HEIGHT)];
		superRangeTrackImageView = [[UIImageView alloc] initWithFrame:CGRectMake(max*frame.size.width, 0, frame.size.width-frame.size.width*max, SLIDER_HEIGHT)];
    UIImage *image = [UIImage imageNamed:@"subRangeTrack.png"];
    subRangeTrackImageView.image = [image stretchableImageWithLeftCapWidth:image.size.width-2 topCapHeight:3];
    image = [UIImage imageNamed:@"inRangeTrack.png"];
    inRangeTrackImageView.image = [image stretchableImageWithLeftCapWidth:image.size.width/2.0-2 topCapHeight:image.size.height-2];
    image = [UIImage imageNamed:@"superRangeTrack.png"];
    image = [image stretchableImageWithLeftCapWidth:3 topCapHeight:0];
    superRangeTrackImageView.image = [image stretchableImageWithLeftCapWidth:image.size.width/2.0-2 topCapHeight:image.size.height-2];

    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, -6, 142, 21)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:13];
    titleLabel.backgroundColor = [UIColor clearColor];
    fromLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 40, 100, 21)];
    fromLabel.textColor = [UIColor whiteColor];
    fromLabel.font = [UIFont systemFontOfSize:11];
    fromLabel.backgroundColor = [UIColor clearColor];
    toLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width-140, 40, 120, 21)];
    toLabel.textColor = [UIColor whiteColor];
    toLabel.textAlignment = UITextAlignmentRight;
    toLabel.font = [UIFont systemFontOfSize:11];
    toLabel.backgroundColor = [UIColor clearColor];
    preferredLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width/2-70, 40, 140, 21)];
    preferredLabel.textColor = [UIColor whiteColor];
    preferredLabel.textAlignment = UITextAlignmentRight;
    preferredLabel.font = [UIFont systemFontOfSize:11];
    preferredLabel.backgroundColor = [UIColor clearColor];

    [self addSubview:titleLabel];
    [self addSubview:fromLabel];
    [self addSubview:toLabel];
    [self addSubview:preferredLabel];

		[self addSubview:subRangeTrackImageView];
		[self addSubview:inRangeTrackImageView];
		[self addSubview:superRangeTrackImageView];
		
		[self setupSliders];
		[self updateTrackImageViews];
	}
  return self;
}

-(void)setupSliders {
  CGRect minRect = CGRectMake(min*self.frame.size.width, (SLIDER_HEIGHT-CONTROL_HEIGHT)/2.0, CONTROL_WIDTH, CONTROL_HEIGHT);
	minSlider = [[UIImageView alloc] initWithFrame:minRect];
	minSlider.contentMode = UIViewContentModeScaleToFill;
	minSlider.backgroundColor = [UIColor clearColor];
	minSlider.image = [UIImage imageNamed:@"sliderControl.png"];	
	CGRect maxRect = CGRectMake(max*self.frame.size.width, (SLIDER_HEIGHT-CONTROL_HEIGHT)/2.0, CONTROL_WIDTH, CONTROL_HEIGHT);
	maxSlider = [[UIImageView alloc] initWithFrame:maxRect];
	maxSlider.contentMode = UIViewContentModeScaleToFill;
	maxSlider.backgroundColor = [UIColor clearColor];
	maxSlider.image = [UIImage imageNamed:@"sliderControl.png"];
	CGRect preferredRect = CGRectMake(preferred*self.frame.size.width, (SLIDER_HEIGHT-CONTROL_HEIGHT)/2.0, CONTROL_WIDTH, CONTROL_HEIGHT);
	preferredSlider = [[UIImageView alloc] initWithFrame:preferredRect];
	preferredSlider.contentMode = UIViewContentModeScaleToFill;
	preferredSlider.backgroundColor = [UIColor clearColor];
	preferredSlider.image = [UIImage imageNamed:@"sliderControl.png"];
	
  [self addSubview:minSlider];
	[self addSubview:maxSlider];
  [self addSubview:preferredSlider];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
	UITouch *touch = [touches anyObject];
	if (CGRectContainsPoint(minSlider.frame, [touch locationInView:self])) { //if touch is beginning on min slider
		trackingSlider = minSlider;
		//NSLog(@"tracking min slider");
	} else if (CGRectContainsPoint(maxSlider.frame, [touch locationInView:self])) { //if touch is beginning on max slider
		trackingSlider = maxSlider;
		//NSLog(@"tracking max slider");
	} else if (CGRectContainsPoint(preferredSlider.frame, [touch locationInView:self])) { //if touch is beginning on preferred slider
		trackingSlider = preferredSlider;
		//NSLog(@"tracking preferred slider");
	}
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesMoved:touches withEvent:event];
	UITouch *touch = [touches anyObject];
	float deltaX = [touch locationInView:self].x - [touch previousLocationInView:self].x;
  float newX = MAX(0, MIN(trackingSlider.frame.origin.x+deltaX, self.frame.size.width-CONTROL_WIDTH));
  trackingSlider.frame = CGRectMake(newX, trackingSlider.frame.origin.y, CONTROL_WIDTH, CONTROL_HEIGHT);
	if (trackingSlider == minSlider) {
    preferredSlider.frame = CGRectMake(MAX(preferredSlider.frame.origin.x, trackingSlider.frame.origin.x), preferredSlider.frame.origin.y, CONTROL_WIDTH, CONTROL_HEIGHT);
		maxSlider.frame = CGRectMake(MAX(maxSlider.frame.origin.x, trackingSlider.frame.origin.x), maxSlider.frame.origin.y, CONTROL_WIDTH, CONTROL_HEIGHT);
	} else if (trackingSlider == maxSlider) {
		preferredSlider.frame = CGRectMake(MIN(preferredSlider.frame.origin.x, trackingSlider.frame.origin.x), preferredSlider.frame.origin.y, CONTROL_WIDTH, CONTROL_HEIGHT);
		minSlider.frame = CGRectMake(MIN(minSlider.frame.origin.x, trackingSlider.frame.origin.x), minSlider.frame.origin.y, CONTROL_WIDTH, CONTROL_HEIGHT);
	} else if (trackingSlider == preferredSlider) {
		maxSlider.frame = CGRectMake(MAX(maxSlider.frame.origin.x, trackingSlider.frame.origin.x), maxSlider.frame.origin.y, CONTROL_WIDTH, CONTROL_HEIGHT);
		minSlider.frame = CGRectMake(MIN(minSlider.frame.origin.x, trackingSlider.frame.origin.x), minSlider.frame.origin.y, CONTROL_WIDTH, CONTROL_HEIGHT);
	}	
	/*if (trackingSlider == minSlider) {
		float newX = MAX(0, MIN(minSlider.frame.origin.x+deltaX,
                            self.frame.size.width-CONTROL_WIDTH*2.0-minimumRangeLength*(self.frame.size.width-CONTROL_WIDTH*2.0)));
		minSlider.frame = CGRectMake(newX, minSlider.frame.origin.y, minSlider.frame.size.width, minSlider.frame.size.height);
    preferredSlider.frame = CGRectMake(MAX(preferredSlider.frame.origin.x,
                                           trackingSlider.frame.origin.x+CONTROL_WIDTH+minimumRangeLength*(self.frame.size.width-CONTROL_WIDTH*2.0)), 
                                       preferredSlider.frame.origin.y, CONTROL_WIDTH, CONTROL_HEIGHT);
		maxSlider.frame = CGRectMake(MAX(maxSlider.frame.origin.x,
                                     trackingSlider.frame.origin.x+CONTROL_WIDTH+minimumRangeLength*(self.frame.size.width-CONTROL_WIDTH*2.0)), 
                                 maxSlider.frame.origin.y, CONTROL_WIDTH, CONTROL_HEIGHT);
	} else if (trackingSlider == maxSlider) {
		float newX = MAX(CONTROL_WIDTH+minimumRangeLength*(self.frame.size.width-CONTROL_WIDTH*2.0),
                     MIN(maxSlider.frame.origin.x+deltaX, self.frame.size.width-CONTROL_WIDTH));
		maxSlider.frame = CGRectMake(newX, maxSlider.frame.origin.y, maxSlider.frame.size.width, maxSlider.frame.size.height);
		preferredSlider.frame = CGRectMake(MIN(preferredSlider.frame.origin.x,
                                     trackingSlider.frame.origin.x-CONTROL_WIDTH-minimumRangeLength*(self.frame.size.width-2.0*CONTROL_WIDTH)), 
                                 preferredSlider.frame.origin.y, CONTROL_WIDTH, CONTROL_HEIGHT);
		minSlider.frame = CGRectMake(MIN(minSlider.frame.origin.x,
                                     trackingSlider.frame.origin.x-CONTROL_WIDTH-minimumRangeLength*(self.frame.size.width-2.0*CONTROL_WIDTH)), 
                                 minSlider.frame.origin.y, CONTROL_WIDTH, CONTROL_HEIGHT);
	} else if (trackingSlider == preferredSlider) {
		float newX = MAX(CONTROL_WIDTH+minimumRangeLength*(self.frame.size.width-CONTROL_WIDTH*2.0),
                     MIN(preferredSlider.frame.origin.x+deltaX, self.frame.size.width-CONTROL_WIDTH*2.0-minimumRangeLength*(self.frame.size.width-CONTROL_WIDTH*2.0)));
		preferredSlider.frame = CGRectMake(newX, preferredSlider.frame.origin.y, preferredSlider.frame.size.width, preferredSlider.frame.size.height);
		maxSlider.frame = CGRectMake(MAX(maxSlider.frame.origin.x,
                                     trackingSlider.frame.origin.x+CONTROL_WIDTH+minimumRangeLength*(self.frame.size.width-CONTROL_WIDTH*2.0)), 
                                 maxSlider.frame.origin.y, CONTROL_WIDTH, CONTROL_HEIGHT);
		minSlider.frame = CGRectMake(MIN(minSlider.frame.origin.x,
                                     trackingSlider.frame.origin.x-CONTROL_WIDTH-minimumRangeLength*(self.frame.size.width-2.0*CONTROL_WIDTH)), 
                                 minSlider.frame.origin.y, CONTROL_WIDTH, CONTROL_HEIGHT);
	}*/
	[self calculateMinMax];
	[self updateTrackImageViews];
}

-(void)updateTrackImageViews {
	subRangeTrackImageView.frame = CGRectMake(CONTROL_WIDTH*0.5, 0,
                                            MAX(minSlider.frame.origin.x,subRangeTrackImageView.image.size.width),
                                            subRangeTrackImageView.frame.size.height);
	inRangeTrackImageView.frame = CGRectMake(minSlider.frame.origin.x+0.5*CONTROL_WIDTH, 0,
                                           maxSlider.frame.origin.x-minSlider.frame.origin.x,
                                           inRangeTrackImageView.frame.size.height);
	superRangeTrackImageView.frame = CGRectMake(maxSlider.frame.origin.x+0.5*CONTROL_WIDTH, 0,
                                              self.frame.size.width-maxSlider.frame.origin.x-CONTROL_WIDTH,
                                              superRangeTrackImageView.frame.size.height);
}

-(void)calculateMinMax {
	float newMax = MIN(1, maxSlider.frame.origin.x/(self.frame.size.width-CONTROL_WIDTH));
	float newMin = MAX(0, minSlider.frame.origin.x/(self.frame.size.width-CONTROL_WIDTH));
  float newPreferred = MIN(1, MAX(0, preferredSlider.frame.origin.x/(self.frame.size.width-CONTROL_WIDTH)));
	if (newMin != min || newMax != max || newPreferred != preferred) {
		min = newMin;
		max = newMax;
    preferred = newPreferred;
		[self sendActionsForControlEvents:UIControlEventValueChanged];   
	}
}

-(void)updateThumbViews {
  if (min == 0 && max == 0 && preferred > 0) {
    min = max = preferred;
  }
  //NSLog(@"maxSlider: %f, %f, %f, %f", maxSlider.frame.origin.x, maxSlider.frame.origin.y, maxSlider.frame.size.width, maxSlider.frame.size.height);
	maxSlider.frame = CGRectMake(max*self.frame.size.width, (SLIDER_HEIGHT-CONTROL_HEIGHT)/2.0, CONTROL_WIDTH, CONTROL_HEIGHT);
	//maxSlider.frame = CGRectMake(max*self.frame.size.width-2*CONTROL_WIDTH)+CONTROL_WIDTH, 
  //                             (SLIDER_HEIGHT-CONTROL_HEIGHT)/2.0, CONTROL_WIDTH, CONTROL_HEIGHT);
  //NSLog(@"maxSlider: %f, %f, %f, %f", maxSlider.frame.origin.x, maxSlider.frame.origin.y, maxSlider.frame.size.width, maxSlider.frame.size.height);
  //NSLog(@"preferredSlider: %f, %f, %f, %f", preferredSlider.frame.origin.x, preferredSlider.frame.origin.y, preferredSlider.frame.size.width, preferredSlider.frame.size.height);
	preferredSlider.frame = CGRectMake(MIN(preferred*self.frame.size.width, maxSlider.frame.origin.x), (SLIDER_HEIGHT-CONTROL_HEIGHT)/2.0, CONTROL_WIDTH, CONTROL_HEIGHT);
	//preferredSlider.frame = CGRectMake(MIN(preferred*(self.frame.size.width-2*CONTROL_WIDTH),
  //                                       maxSlider.frame.origin.x/*-CONTROL_WIDTH*/-(minimumRangeLength*(self.frame.size.width-CONTROL_WIDTH*2.0))), 
  //                                   (SLIDER_HEIGHT-CONTROL_HEIGHT)/2.0, CONTROL_WIDTH, CONTROL_HEIGHT);
  //NSLog(@"preferredSlider: %f, %f, %f, %f", preferredSlider.frame.origin.x, preferredSlider.frame.origin.y, preferredSlider.frame.size.width, preferredSlider.frame.size.height);  
  //NSLog(@"minSlider: %f, %f, %f, %f", minSlider.frame.origin.x, minSlider.frame.origin.y, minSlider.frame.size.width, minSlider.frame.size.height);
	minSlider.frame = CGRectMake(MIN(min*self.frame.size.width, preferredSlider.frame.origin.x), (SLIDER_HEIGHT-CONTROL_HEIGHT)/2.0, CONTROL_WIDTH, CONTROL_HEIGHT);
	//minSlider.frame = CGRectMake(MIN(min*(self.frame.size.width-2*CONTROL_WIDTH),
  //                                 preferredSlider.frame.origin.x/*-CONTROL_WIDTH*/-(minimumRangeLength*(self.frame.size.width-CONTROL_WIDTH*2.0))), 
  //                             (SLIDER_HEIGHT-CONTROL_HEIGHT)/2.0, CONTROL_WIDTH, CONTROL_HEIGHT);
  //NSLog(@"minSlider: %f, %f, %f, %f", minSlider.frame.origin.x, minSlider.frame.origin.y, minSlider.frame.size.width, minSlider.frame.size.height);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];
	trackingSlider = nil; //we are no longer tracking either slider
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

-(void)dealloc {
  [backgroundImageView release];
  [subRangeTrackImageView release];
  [inRangeTrackImageView release];
  [superRangeTrackImageView release];
  [minSlider release];
  [maxSlider release];
  [preferredSlider release];
  [titleLabel release];
  [fromLabel release];
  [preferredLabel release];
  [toLabel release];
  [super dealloc];
}

@end