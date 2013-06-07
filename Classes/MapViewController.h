//
//  MapViewController.h
//  MapApp
//
//  Created by Mithin on 21/06/09.
//  Copyright 2009 Techtinium Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MyCLController.h"
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

@interface AddressAnnotation : NSObject<MKAnnotation, UITextFieldDelegate, UITextViewDelegate> {
	CLLocationCoordinate2D coordinate;
	int index;
	NSString *mTitle;
	NSString *mSubTitle;
    int emotionIndex;
    NSString *tweetId;
}
@property (nonatomic, assign) int index;
@property (nonatomic, assign) int emotionIndex;
@property (nonatomic, retain) NSString *tweetId;
@property (nonatomic, retain) NSString *mTitle;
@property (nonatomic, retain) NSString *mSubTitle;

-(id)initWithCoordinate:(CLLocationCoordinate2D) c: (NSString *)title: (NSString *)subTitle;
- (void)selectAnnotation:(AddressAnnotation*)annotation;

@end

@interface MapViewController : UIViewController<MKMapViewDelegate, UITextFieldDelegate, UITextViewDelegate, MyCLControllerDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate, UIWebViewDelegate> {
	IBOutlet UITextField *addressField;
	IBOutlet UIButton *goButton;
	IBOutlet MKMapView *mapView;
    IBOutlet UIView *emotionView;
    IBOutlet UIView *commentView;
    IBOutlet UIButton *instructionButton;
    IBOutlet UITextView *commentField;
    IBOutlet UIImageView *currentEmotionImage;
    IBOutlet UIButton *tweetButton;
    IBOutlet UIWebView *bannerWebView;
    IBOutlet UILabel *numberofCharacterLeft;
    
    IBOutlet UISlider *timeSlider;
	
	AddressAnnotation *addAnnotation;
    MyCLController *locationController;
    
    NSString * currentEmotion;
    NSString *note;
    
    CLLocation *currentLocation;
    MKCoordinateSpan currentSpan;
    NSMutableArray *mapAnnotations;
    
    NSMutableData *responseData;
    
    int instructionStep;
    int counterForQuery;
    
    UILabel *counterLabel;
}

@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, assign) MKCoordinateSpan currentSpan;
@property (nonatomic, retain) NSMutableArray *mapAnnotations;
@property (nonatomic, retain) NSString * currentEmotion;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSString *note;
@property (nonatomic, retain) IBOutlet UILabel *counterLabel;

- (IBAction) showAddress;
- (void)queryNewLocation:(CLLocationCoordinate2D)newLocation :(MKCoordinateSpan)newSpan;

-(CLLocationCoordinate2D) addressLocation;

- (void)locationUpdate:(CLLocation *)location; 
- (void)locationError:(NSError *)error;
- (IBAction)showCurrentLocation:(id)sender;
- (IBAction)showEmotionView:(id)sender;
- (IBAction)setEmotion:(id)sender;
- (NSString*)md5HexDigest:(NSString*)sourceString;
- (void)updateAnnotations:(NSMutableArray *)annotationDataArray;
- (IBAction)AddFaceData:(NSString *)tweetId;
- (IBAction)initialTwitter;
- (void)queryCurrentLocation;
- (IBAction)showInstruction:(id)sender;
- (IBAction)nextInstruction:(id)sender;

- (IBAction)closeCommentView:(id)sender;
-(NSString*) sha256:(NSString *)clear;
-(NSString*) tokenforlat:(double)lat lon:(double)lon type:(int)type;
@end
