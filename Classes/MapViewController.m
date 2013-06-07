//
//  MapViewController.m
//  MapApp
//
//  Created by Mithin on 21/06/09.
//  Copyright 2009 Techtinium Corporation. All rights reserved.
//

#import "MapViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "SBJSON.h"
#import "JSON.h"

@implementation AddressAnnotation

@synthesize coordinate, emotionIndex, index, tweetId;

@synthesize mTitle, mSubTitle;

- (NSString *)subtitle{
	return mSubTitle;
}
- (NSString *)title{
	return mTitle;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D) c: (NSString *)title: (NSString *)subTitle{
	coordinate=c;
    if ([title length] == 0) {
        title = @"";
    }
    if ([subTitle length] == 0) {
        subTitle = @"anonymous";
    }
    mTitle = [title copy];
    mSubTitle = [subTitle copy];
	NSLog(@"%f,%f",c.latitude,c.longitude);
	return self;
}

- (void)setMTitle:(NSString *)newMTitle{
    mTitle = [newMTitle copy];
}

- (void)setMSubTitle:(NSString *)newMSubTitle{
    mSubTitle = [newMSubTitle copy];
}

- (void)selectAnnotation:(AddressAnnotation*)annotation{
    //TO-DO query for tweet
    annotation.mTitle = @"Changed!";
    
}

- (void)selectAnnotation:(id <MKAnnotation>)annotation animated:(BOOL)animated{
    
}

@end



@implementation MapViewController

@synthesize currentLocation, currentSpan, mapAnnotations, currentEmotion, responseData, note, counterLabel;


#pragma mark - Map delegate
+ (CGFloat)annotationPadding;
{
    return 10.0f;
}
+ (CGFloat)calloutHeight;
{
    return 50.0f;
}


-(CLLocationCoordinate2D) addressLocation {
	NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps/geo?q=%@&output=csv", 
							[addressField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSError *error;
	NSString *locationString = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:&error];//stringWithContentsOfURL:[NSURL URLWithString:urlString]];
	NSArray *listItems = [locationString componentsSeparatedByString:@","];
	
	double latitude = 0.0;
	double longitude = 0.0;
	CLLocationCoordinate2D location;
	if([listItems count] >= 4 && [[listItems objectAtIndex:0] isEqualToString:@"200"]) {
		latitude = [[listItems objectAtIndex:2] doubleValue];
		longitude = [[listItems objectAtIndex:3] doubleValue];
        
        location.latitude = latitude;
        location.longitude = longitude;
        
        currentLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        [self queryCurrentLocation];
        return location;
	}
	else {
		//Show error
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Didn't find the place!" message:@"Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        location.latitude = mapView.region.center.latitude;
        location.longitude = mapView.region.center.longitude;
        return location;
	}
	
	
}

- (MKAnnotationView *) mapView:(MKMapView *)_mapView viewForAnnotation:(id <MKAnnotation>) annotation{
    
//	MKPinAnnotationView *annView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"currentloc"];
//	annView.pinColor = MKPinAnnotationColorRed;
//	annView.animatesDrop=TRUE;
//	annView.canShowCallout = YES;
//	annView.calloutOffset = CGPointMake(-5, 5);
//	return annView;
    
    NSString *thisEmotion = @"";
    //new style
    static NSString* SFAnnotationIdentifier = @"SFAnnotationIdentifier";
//    MKPinAnnotationView* pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:SFAnnotationIdentifier];
    
//    if (!pinView)
//    {
        
        MKAnnotationView *annotationView = [[[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                         reuseIdentifier:SFAnnotationIdentifier] autorelease];
        annotationView.canShowCallout = YES;
    
        AddressAnnotation *thisAnnotation = (AddressAnnotation *) annotation;
        [thisAnnotation retain];
        if ([thisAnnotation isKindOfClass:[AddressAnnotation class]]) {
            switch (thisAnnotation.emotionIndex) {
                case 0:
                    thisEmotion = @"happy";
                    break;
                case 1:
                    thisEmotion = @"sad";
                    break;
                case 2:
                    thisEmotion = @"sleeping";
                    break;
                case 3:
                    thisEmotion = @"dead";
                    break;    
                case 4:
                    thisEmotion = @"confused";
                    break;
                case 5:
                    thisEmotion = @"angry";
                    break;
    //            case 6:
    //                thisEmotion = @"heart";
    //                break;   
                default:
    //                thisEmotion = @"heart";
                    break;
            }
            
            UIImage *flagImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", thisEmotion]];
            
            CGRect resizeRect;
            
            resizeRect.size = CGSizeMake(26, 26);//flagImage.size;
            CGSize maxSize = CGRectInset(self.view.bounds,
                                         [MapViewController annotationPadding],
                                         [MapViewController annotationPadding]).size;
            maxSize.height -= self.navigationController.navigationBar.frame.size.height + [MapViewController calloutHeight];
            if (resizeRect.size.width > maxSize.width)
                resizeRect.size = CGSizeMake(maxSize.width, resizeRect.size.height / resizeRect.size.width * maxSize.width);
            if (resizeRect.size.height > maxSize.height)
                resizeRect.size = CGSizeMake(resizeRect.size.width / resizeRect.size.height * maxSize.height, maxSize.height);
            
            resizeRect.origin = (CGPoint){0.0f, 0.0f};
            UIGraphicsBeginImageContext(resizeRect.size);
            [flagImage drawInRect:resizeRect];
            UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            annotationView.image = resizedImage;
            annotationView.opaque = NO;
            annotationView.alpha = 0.8;
            
            UIImageView *sfIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png", thisEmotion]]];
            annotationView.leftCalloutAccessoryView = sfIconView;
            
            [sfIconView release];
            return annotationView;
        }
        else{
            return nil;
        }
//    }
//    else
//    {
//        pinView.annotation = annotation;
//        pinView.animatesDrop = YES;
//    }
//    return pinView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    //change the title after clicking
//    AddressAnnotation *thisAnnotation =(AddressAnnotation*) view.annotation;
//    NSString *tweetId = thisAnnotation.tweetId;
//    NSLog(@"%@", tweetId);
//    NSString *queryString= [NSString stringWithFormat: @"https://api.twitter.com/1/statuses/show.json?id=%@&include_entities=true", tweetId];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:queryString] cachePolicy:NSURLCacheStorageAllowed timeoutInterval: 40];
//    [[NSURLConnection alloc] initWithRequest:request delegate:self];
//    NSError *error;
//    NSHTTPURLResponse * response;
//    NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//    NSString *responseStringTweet = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] retain];
//    NSMutableDictionary *tweetArrays = [responseStringTweet JSONValue];
//    NSString *tweetText = [[NSString stringWithFormat:@"%@", [tweetArrays objectForKey:@"text"]] retain];
//    NSDictionary *userInfo = [tweetArrays objectForKey:@"user"];
//    NSString *userName = [[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"screen_name"]] retain];    
//    [thisAnnotation setMTitle:[NSString stringWithFormat:@"%@", tweetText]];
//    [thisAnnotation setMSubTitle:userName];
}

- (void)locationUpdate:(CLLocation *)location {
    currentLocation = location;
    [currentLocation retain];
    
}

- (void)locationError:(NSError *)error {
    
}


//- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views { 
//    MKAnnotationView *aV; 
//
//    for (aV in views) {
//        
//        CGRect endFrame = aV.frame;
//        
//        aV.frame = CGRectMake(aV.frame.origin.x, aV.frame.origin.y - 230.0, aV.frame.size.width, aV.frame.size.height);
//        
//        [UIView beginAnimations:nil context:NULL];
//        [UIView setAnimationDuration:0.45];
//        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//        [aV setFrame:endFrame];
//        [UIView commitAnimations];
//        
//    }
//}

- (void)mapView:(MKMapView *)_mapView regionDidChangeAnimated:(BOOL)animated{
    
    //remove old annotations
    int numberofAnnotatoins = [mapView.annotations count];
    if (numberofAnnotatoins > 1000) {
//        for (AddressAnnotation *annotation in mapView.annotations) {
//            NSLog(@"annotation %@", annotation);
//            if (![annotation isKindOfClass:[MKUserLocation class]]){
                [mapView removeAnnotations:mapView.annotations];
//            }
//        }
    }
    
    currentSpan = _mapView.region.span;
    
//    if (currentSpan.latitudeDelta > 1 || currentSpan.longitudeDelta > 1) {
//        currentSpan.latitudeDelta = 1;
//        currentSpan.longitudeDelta = 1;
//    }
  
    CLLocationCoordinate2D location;
    location.latitude = _mapView.region.center.latitude;
    location.longitude = _mapView.region.center.longitude;
    
    MKCoordinateRegion region;
	region.span=currentSpan;
    region.center=location;
    currentLocation = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
    if (commentView.hidden == YES) {
        [self queryNewLocation:location:currentSpan];
    }
    
}


- (void)mapViewDidFinishLoadingMap:(MKMapView *)_mapView{
//    [self queryCurrentLocation];
    
}

#pragma mark - update map methods


- (IBAction) showAddress {
	//Hide the keypad
	[addressField resignFirstResponder];
	MKCoordinateRegion region;
	MKCoordinateSpan span;
	span.latitudeDelta=0.1;
	span.longitudeDelta=0.1;
	
	CLLocationCoordinate2D location = [self addressLocation];
	region.span=span;
	region.center=location;
    
	[mapView setRegion:region animated:TRUE];
	[mapView regionThatFits:region];
	//[mapView selectAnnotation:mLodgeAnnotation animated:YES];
}

- (IBAction)showCurrentLocation:(id)sender{
    MKCoordinateRegion region;
	MKCoordinateSpan span;
    if (mapView.region.span.latitudeDelta < 0.001) {
        span = mapView.region.span;
    }
    else{
        span.latitudeDelta=0.001;
        span.longitudeDelta=0.001;
    }
	
	
	CLLocationCoordinate2D locationCoordinate = [currentLocation coordinate];
	region.span=span;
	region.center= locationCoordinate;
    
    
	[mapView setRegion:region animated:TRUE];
	[mapView regionThatFits:region];
    
    ///put/lat/{lat}/lon/{lon}/type/{type}/token/{token}
    //token = md5(floor($lat).floor($lon)."290815yhac")
//    NSString *latString = [NSString stringWithFormat:@"%f", abs(locationCoordinate.latitude)];
//    NSString *logString = [NSString stringWithFormat:@"%f", abs(locationCoordinate.longitude)];
    
//    NSString *tokenString = [NSString stringWithFormat:@"%d%d290815yhac", floor(abs(locationCoordinate.latitude)), floor(abs(locationCoordinate.longitude))];
    
    //TO-DO click on a annotation
    //https://api.twitter.com/1/statuses/show.json?id=193867539980361729&include_entities=true
}


- (IBAction)AddFaceData:(NSString *)tweetId{
    [commentField resignFirstResponder];
    
    CLLocationCoordinate2D locationCoordinate = [currentLocation coordinate];
    NSString *commentForThisFace = [[NSString stringWithString: commentField.text] retain];
    
	addAnnotation = [[AddressAnnotation alloc] initWithCoordinate:locationCoordinate: commentForThisFace: @"anonymous"];
    if ([currentEmotion isEqualToString:@"happy"]) {
        addAnnotation.emotionIndex = 0;
        
    }
    else if ([currentEmotion isEqualToString:@"sad"]) {
        addAnnotation.emotionIndex = 1;
    }
    else if ([currentEmotion isEqualToString:@"sleeping"]) {
        addAnnotation.emotionIndex = 2;
    }
    else if ([currentEmotion isEqualToString:@"dead"]) {
        addAnnotation.emotionIndex = 3;
    }
    else if ([currentEmotion isEqualToString:@"confused"]) {
        addAnnotation.emotionIndex = 4;
    }
    else if ([currentEmotion isEqualToString:@"angry"]) {
        addAnnotation.emotionIndex = 5;
    }
    
//	[mapView addAnnotation:addAnnotation]; 
    
//    NSString *tokenString = [NSString stringWithFormat:@"oaigshoaisg124ofha209fasfasafsfasq241242"];
    NSString *tokenString = [self tokenforlat:(double)locationCoordinate.latitude lon:(double)locationCoordinate.longitude type:(int)addAnnotation.emotionIndex];
    
    //[self md5HexDigest: tokenString];
//    if (tweetId == nil || [tweetId length] == 0) {
//        tweetId = @"-1";
//    }
    //TO-DO add comment and time stamp data
    NSString* myNote =
    [note stringByAddingPercentEscapesUsingEncoding:
     NSASCIIStringEncoding];
    
    NSString *queryString= [NSString stringWithFormat: @"http://facemehere.com/api/?method=put&lat=%f&lon=%f&type=%d&token=%@&tweetid=%@&note=%@", locationCoordinate.latitude, locationCoordinate.longitude, addAnnotation.emotionIndex, tokenString, tweetId, myNote];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:queryString] cachePolicy:NSURLCacheStorageAllowed timeoutInterval: 40];
    request.accessibilityHint = @"PutFace";
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    mapView.userInteractionEnabled = NO;
    
}

- (IBAction)setEmotion:(id)sender{
    UIButton *emotionButton = (UIButton*)sender;
    [emotionView setHidden:YES];
    currentEmotion = emotionButton.titleLabel.text;
    [currentEmotion retain];
    [currentEmotionImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",currentEmotion]]];
    
    [self showCurrentLocation:nil];
    if ([TWTweetComposeViewController canSendTweet]){
        //TO-DO set the button image to be tweet
        [tweetButton setImage:[UIImage imageNamed:@"tweet-btn.png"] forState:UIControlStateNormal];
    }
    else{
        //TO-DO set the button image to be face it
        [tweetButton setImage:[UIImage imageNamed:@"face-it-btn.png"] forState:UIControlStateNormal];
    }
    [commentView setHidden:NO];
    commentField.text = @"";
    [commentField becomeFirstResponder];
}

- (IBAction)removeInstruction:(id)sender{
    [instructionButton setHidden:YES];
    mapView.userInteractionEnabled = YES;
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HideInstruction"];
}
- (IBAction)showEmotionView:(id)sender{
    if (emotionView.hidden) {
        [emotionView setHidden:NO];
        
    }
    else{
        [emotionView setHidden:YES];
        
    }
}

- (IBAction)closeCommentView:(id)sender{
    [commentView setHidden:YES];
    [commentField resignFirstResponder];
//    [self AddFaceData:@""];
}

- (IBAction)showInstruction:(id)sender{
    if (instructionButton.hidden) {
        instructionStep = 2;
        [instructionButton setImage:[UIImage imageNamed:@"step1.png"] forState:UIControlStateNormal];
        [instructionButton setHidden:NO];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"hasShownInstruction"];
    }
    else{
        [instructionButton setHidden:YES];
    }
}


- (IBAction)nextInstruction:(id)sender{
    BOOL hasShownInstruction = [[NSUserDefaults standardUserDefaults] boolForKey:@"hasShownInstruction"];
    if (!hasShownInstruction) {
        
        switch (instructionStep) {
            case 1:
                [instructionButton setImage:[UIImage imageNamed:@"step1.png"] forState:UIControlStateNormal];
                instructionStep++;
                break;
            case 2:
                [instructionButton setImage:[UIImage imageNamed:@"step2.png"] forState:UIControlStateNormal];
                instructionStep++;
                break;
            case 3:
                [instructionButton setImage:[UIImage imageNamed:@"step3.png"] forState:UIControlStateNormal];
                instructionStep++;
                break;
            case 4:
                [instructionButton setImage:[UIImage imageNamed:@"step4.png"] forState:UIControlStateNormal];
                instructionStep++;
                break;
            case 5:
                [instructionButton setImage:[UIImage imageNamed:@"step5.png"] forState:UIControlStateNormal];
                instructionStep++;
                break;
            case 6:
                [instructionButton setImage:[UIImage imageNamed:@"step6.png"] forState:UIControlStateNormal];
                instructionStep++;
                break;
            case 7:
                [instructionButton setHidden:YES];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasShownInstruction"];
                break;
                
            default:
                break;
        }
    }
    else{
        [instructionButton setHidden:YES];
    }
}

- (void)updateAnnotations:(NSMutableArray *)annotationDataArray{
       
    double latitude;
    double longitude;
    int emotion;
    int index;
    NSString *tweetId;
    NSString *annotationNote;
    for (NSDictionary *oneAnnotationString in annotationDataArray) {
        index = [[oneAnnotationString objectForKey:@"id"] doubleValue];
        latitude = [[oneAnnotationString objectForKey:@"latitude"] doubleValue];
        longitude = [[oneAnnotationString objectForKey:@"longitude"] doubleValue];
        emotion = [[oneAnnotationString objectForKey:@"type"] intValue];
        tweetId = [oneAnnotationString objectForKey:@"tweetid"];
        annotationNote = [oneAnnotationString objectForKey:@"note"];
        
        NSString *comment = @"";
        if (![annotationNote isKindOfClass:[NSNull class]]) {
            comment = [NSString stringWithString:annotationNote];
        }
        else{
            if (emotion == 0) {
                comment = @"I am soooo happy!";
            }
            else if (emotion == 1) {
                comment = @"I am soooo sad!";
            }
            else if (emotion == 2) {
                comment = @"I am soooo sleepy!";
            }
            else if (emotion == 3) {
                comment = @"I am soooo dead!";
            }
            else if (emotion == 4) {
                comment = @"I am soooo confused!";
            }
            else if (emotion == 5) {
                comment = @"I am soooo angry!";
            }
        }
        
        
        CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
        NSString *tweetText = @"";
        NSString *userName = @"";
        
        if ((NSNull *)tweetId == [NSNull null]) {
            tweetText = comment;
            userName = @"anonymous";
        }
        else{            
            //test
            tweetText = comment;
            userName = @"anonymous";
        }
        
        AddressAnnotation *newAnnotation = [[AddressAnnotation alloc] initWithCoordinate:locationCoordinate: tweetText: userName];
        newAnnotation.emotionIndex = emotion;
        newAnnotation.index = index;
        newAnnotation.tweetId = tweetId;
        
//        [mapView addAnnotation:newAnnotation]

        BOOL hasbeenAdded = NO;
        
        for (AddressAnnotation *oneAnnotation in mapAnnotations) {
            if (oneAnnotation.index == newAnnotation.index) {
                hasbeenAdded = YES;
            }
        }
        
        if (!hasbeenAdded) {
            [mapAnnotations addObject:newAnnotation];
            [mapView addAnnotation:newAnnotation];
        }
    }
    
    

}

- (void)queryCurrentLocation{
    //http://192.168.1.77:58888/get/lat/55/lon/-125.15/deltalat/10/deltalon/10
    //http://192.168.1.77:58888/api/
    if (currentLocation) {
        MKCoordinateRegion region;
        MKCoordinateSpan span;
        span.latitudeDelta=0.2;
        span.longitudeDelta=0.2;
        int limit = 50;
        
        CLLocationCoordinate2D locationCoordinate = [currentLocation coordinate];
        region.span=span;
        region.center= locationCoordinate;
        
        [mapView setRegion:region animated:TRUE];
        //        [mapView regionThatFits:region];
        
        NSString *queryString= [NSString stringWithFormat: @"http://facemehere.com/api/?method=get&lat=%f&lon=%f&deltalat=%f&deltalon=%f&limit=%d", locationCoordinate.latitude, locationCoordinate.longitude, span.latitudeDelta, span.longitudeDelta, limit];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:queryString] cachePolicy:NSURLCacheStorageAllowed timeoutInterval: 40];
        request.accessibilityHint = @"GetFace";
        [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        
    }
    
    
}

- (void)queryNewLocation:(CLLocationCoordinate2D)newLocation :(MKCoordinateSpan)newSpan{
    
    MKCoordinateRegion region;
    int limit = 50;
    
    region.span= newSpan;
    region.center= newLocation;
    
    //    [mapView setRegion:region animated:TRUE];
    //        [mapView regionThatFits:region];
    //http://192.168.1.81:58888/api/?method=get&lat=49.15&lon=-122.15&deltalat=5&deltalon=5&limit=200
    //    NSString *queryString= [NSString stringWithFormat: @"http://facemehere.com/api/?method=get&lat=%f&lon=%f&deltalat=%f&deltalon=%f&limit=%d", newLocation.latitude, newLocation.longitude, newSpan.latitudeDelta, newSpan.longitudeDelta, limit];
    NSString *queryString= [NSString stringWithFormat: @"http://facemehere.com/api/?method=get&lat=%f&lon=%f&deltalat=%f&deltalon=%f&limit=%d", newLocation.latitude, newLocation.longitude, newSpan.latitudeDelta, newSpan.longitudeDelta, limit];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:queryString] cachePolicy:NSURLCacheStorageAllowed timeoutInterval: 40];
    request.accessibilityHint = @"GetFace";
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    counterForQuery++;
    counterLabel.text = [NSString stringWithFormat:@"%d", counterForQuery];
}



#pragma mark - connection

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[responseData appendData:data];
    [responseData retain];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	mapView.userInteractionEnabled = YES;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *responseStringAnnotation = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] retain];
    NSMutableArray *annotationArrays = [responseStringAnnotation JSONValue];// (NSMutableArray *)[responseStringAnnotation componentsSeparatedByString:@"],["];
    [annotationArrays retain];
    
    if ([responseStringAnnotation isEqualToString:@"ok."]) {

//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Faced it!" message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
//        [alertView show];
//        [alertView release];
//        
        mapView.userInteractionEnabled = YES;
        int limit = 50;
        
        CLLocationCoordinate2D locationCoordinate = [currentLocation coordinate];
        NSString *queryString= [NSString stringWithFormat: @"http://facemehere.com/api/?method=get&lat=%f&lon=%f&deltalat=%f&deltalon=%f&limit=%d", locationCoordinate.latitude, locationCoordinate.longitude, mapView.region.span.latitudeDelta, mapView.region.span.longitudeDelta, limit];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:queryString] cachePolicy:NSURLCacheStorageAllowed timeoutInterval: 40];
        request.accessibilityHint = @"GetFace";
        [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
//    else if ([responseStringAnnotation isEqualToString:@"no."]) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
//        [alertView show];
//        [alertView release];
//        
//    }
    else if([annotationArrays count] > 0 && [annotationArrays isKindOfClass:[NSArray class]]){
        [self updateAnnotations:annotationArrays];
    }
}

#pragma mark - twitter methods

- (IBAction)initialTwitter{
    TWRequest *request = [[TWRequest alloc] initWithURL:[NSURL URLWithString:
                                                         @"http://search.twitter.com/search.json?q=iOS%205&rpp=5&with_twitter_user_id=true&result_type=recent"] 
                                             parameters:nil requestMethod:TWRequestMethodGET];
    
    // Notice this is a block, it is the handler to process the response
    [request performRequestWithHandler:^(NSData *_responseData, NSHTTPURLResponse *urlResponse, NSError *error)
    {
        if ([urlResponse statusCode] == 200) 
        {
            // The response from Twitter is in JSON format
            // Move the response into a dictionary and print
            NSError *error;        
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:_responseData options:0 error:&error];
            NSLog(@"Twitter response: %@", dict);                           
        }
        else
            NSLog(@"Twitter error, HTTP response: %i", [urlResponse statusCode]);
    }];
    
    [commentView setHidden:YES];
    if ([TWTweetComposeViewController canSendTweet]) 
    {
        // Create account store, followed by a twitter account identifier
        // At this point, twitter is the only account type available
        ACAccountStore *account = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        // Request access from the user to access their Twitter account
        [account requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) 
         {
             // Did user allow us access?
             if (granted == YES)
             {
                 // Populate array with all available Twitter accounts
                 NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
                 
                 // Sanity check
                 if ([arrayOfAccounts count] > 0) 
                 {
                     // Keep it simple, use the first account available
                     ACAccount *acct = [arrayOfAccounts objectAtIndex:0];
                     NSString *stingToTwitt = commentField.text;
                     // Build a twitter request
                     TWRequest *postRequest = [[TWRequest alloc] initWithURL:
                                               [NSURL URLWithString:@"http://api.twitter.com/1/statuses/update.json"] 
                                                                  parameters:[NSDictionary dictionaryWithObject:stingToTwitt forKey:@"status"] requestMethod:TWRequestMethodPOST];
                     
                     // Post the request
                     [postRequest setAccount:acct];
                     // Block handler to manage the response
                     [postRequest performRequestWithHandler:^(NSData *_responseData, NSHTTPURLResponse *urlResponse, NSError *error) 
                      {
//                          NSLog(@"Twitter response, HTTP response: %@", urlResponse); //[urlResponse statusCode]);
//                          NSDictionary *responses = [urlResponse allHeaderFields];
//                          NSDictionary *results = [responses objectForKey:@"results"];
                          NSString *responseString = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
                          NSDictionary *results  = [responseString JSONValue];
                          
                          NSLog(@"fragment: %@", results);
                          if ([urlResponse statusCode] == 200) {
//                              NSString *responseString = [[[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding] retain];
                              [self performSelectorOnMainThread:@selector(AddFaceData:) withObject: [results objectForKey:@"id"] waitUntilDone:YES];
                          }
                      }];
                 }
             }
         }];
    }
    else{
        [self AddFaceData:@""];
    }

}

#pragma mark - webview delegate

//- (void)webViewDidFinishLoad:(UIWebView *)webView{
////    [bannerWebView setHidden:NO];
//    [bannerWebView setScalesPageToFit:YES];
//}
//
//- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
//    [bannerWebView setHidden:YES];
//}



#pragma mark - textfield and textview delegate
- (void)textViewDidChange:(UITextView *)textView{
    int characterleft = 100 - [textView.text length];
    

    if (characterleft >= 0) {
        numberofCharacterLeft.text = [NSString stringWithFormat:@"%d", characterleft];
        numberofCharacterLeft.textColor = [UIColor whiteColor];
        note = [NSString stringWithFormat:@"%@", textView.text];
        [note retain];
    }
    else{
        numberofCharacterLeft.textColor = [UIColor redColor];
        textView.text = [NSString stringWithFormat:@"%@", note];
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
//    [self showAddress];
    return YES;
    
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
    //    [self showAddress];
    return YES;
    
}

#pragma mark - Life Cycle
- (void)viewDidLoad{
    [super viewDidLoad];
    locationController = [[MyCLController alloc] init];
	locationController.delegate = self;
	[locationController.locationManager startUpdatingLocation];
    currentEmotion = @"";
    note = @"";
    [commentView setHidden:YES];
    instructionStep = 1;
    counterForQuery = 0;
    
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"hasShownInstruction"]) {
        [instructionButton setHidden:YES];
    }
    mapView.delegate = self;
    mapView.showsUserLocation = YES;
    addressField.delegate = self;
    addressField.returnKeyType = UIReturnKeyDone;
    
    responseData = [[NSMutableData alloc] init];
    mapAnnotations = [[NSMutableArray alloc] init];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HideInstruction"] == YES) {
        [instructionButton setHidden:YES];
    }
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://facemehere.com/bottomBanner.html"]];
    [bannerWebView setDelegate:self];
    [bannerWebView loadRequest:requestObj];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self performSelector:@selector(showCurrentLocation:) withObject:self afterDelay:1];    
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (NSString*)md5HexDigest:(NSString*)sourceString {
    const char* str = [sourceString UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}



-(NSString*) tokenforlat:(double)lat lon:(double)lon type:(int)type{
    NSString *unhashed = [NSString
                          stringWithFormat:@"oaigshoaisg124ofha209fasfasafsfasq241242%.6f%.6f%d",
                          lat, lon, type];
    return [self sha256:unhashed];
}

// slurped up from the internets
-(NSString*) sha256:(NSString *)clear{
    const char *s=[clear cStringUsingEncoding:NSASCIIStringEncoding];
    NSData *keyData=[NSData dataWithBytes:s length:strlen(s)];
    
    uint8_t digest[CC_SHA256_DIGEST_LENGTH]={0};
    CC_SHA256(keyData.bytes, keyData.length, digest);
    NSData *out=[NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    NSString *hash=[out description];
    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
    return hash;
}

- (void)dealloc {
    [super dealloc];
}





@end
