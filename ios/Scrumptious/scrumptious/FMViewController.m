/*
 * Copyright 2012 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *    http://www.apache.org/licenses/LICENSE-2.0
 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "FMViewController.h"
#import "FMAppDelegate.h"
#import "FMLoginViewController.h"
#import "FMPhotoViewController.h"
#import "FMProtocols.h"
#import "FMEvent.h"
#import "FMEventController.h"
#import <AddressBook/AddressBook.h>
#import "TargetConditionals.h"

@interface FMViewController() < UITableViewDataSource,
                                UIImagePickerControllerDelegate,
                                FBFriendPickerDelegate,
                                UINavigationControllerDelegate,
                                FBPlacePickerDelegate,
                                CLLocationManagerDelegate,
                                UIActionSheetDelegate>

@property (strong, nonatomic) FBUserSettingsViewController *settingsViewController;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *userProfileImage;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UIButton *announceButton;
@property (strong, nonatomic) IBOutlet UITableView *menuTableView;
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) UIActionSheet *imagePickerActionSheet;
@property (strong, nonatomic) UIActionSheet *mealPickerActionSheet;
@property (retain, nonatomic) NSArray *mealTypes;

@property (strong, nonatomic) NSObject<FBGraphPlace> *selectedPlace;
@property (strong, nonatomic) NSString *selectedMeal;
@property (strong, nonatomic) NSArray *selectedFriends;
@property (strong, nonatomic) UIImage *selectedPhoto;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) FBCacheDescriptor *placeCacheDescriptor;
@property (strong, nonatomic) UIPopoverController *popover;
@property (strong, nonatomic) FMPhotoViewController *photoViewController;
@property (nonatomic) CGRect popoverFromRect;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

//########################################################################

#pragma mark -
#pragma mark My Properties

@property (strong, nonatomic) NSArray *allEvents;
@property (strong, nonatomic) FMEventController *eventController;


#pragma mark -

//########################################################################

- (IBAction)announce:(id)sender;
- (void)populateUserDetails;
- (void)updateSelections;
- (void)updateCellIndex:(int)index withSubtitle:(NSString *)subtitle;
- (id<FMOGMeal>)mealObjectForMeal:(NSString *)meal;
- (void)postPhotoThenOpenGraphAction;
- (void)postOpenGraphActionWithPhotoURL:(NSString *)photoID;
- (void)centerAndShowActivityIndicator;
- (void)setPlaceCacheDescriptorForCoordinates:(CLLocationCoordinate2D)coordinates;

@end

@implementation FMViewController
@synthesize userNameLabel = _userNameLabel;
@synthesize userProfileImage = _userProfileImage;
@synthesize selectedPlace = _selectedPlace;
@synthesize selectedMeal = _selectedMeal;
@synthesize selectedFriends = _selectedFriends;
@synthesize announceButton = _announceButton;
@synthesize selectedPhoto = _selectedPhoto;
@synthesize imagePicker = _imagePicker;
@synthesize photoViewController = _photoViewController;
@synthesize menuTableView = _menuTableView;
@synthesize locationManager = _locationManager;
@synthesize popover = _popover;
@synthesize imagePickerActionSheet = _imagePickerActionSheet;
@synthesize mealPickerActionSheet = _mealPickerActionSheet;
@synthesize popoverFromRect = _popoverFromRect;
@synthesize activityIndicator = _activityIndicator;
@synthesize settingsViewController = _settingsViewController;
@synthesize mealTypes = _mealTypes;
@synthesize placeCacheDescriptor = _placeCacheDescriptor;

//########################################################################

#pragma mark -
#pragma mark My Synthetize

@synthesize allEvents = _allEvents;
@synthesize eventController = _eventController;


#pragma mark -

const NSString *currentId = nil;

//########################################################################

+ (NSString *)selectedEventId
{
    return [currentId copy];
}


#pragma mark open graph


// FBSample logic
// This is a helper function that returns an FBGraphObject representing a meal
- (id<FMOGMeal>)mealObjectForMeal:(NSString *)meal {
    
    // We create an FBGraphObject object, but we can treat it as an SCOGMeal with typed
    // properties, etc. See <FacebookSDK/FBGraphObject.h> for more details.
    id<FMOGMeal> result = (id<FMOGMeal>)[FBGraphObject graphObject];
    
    // Give it a URL of sample data that contains the object's name, title, description, and body.
    // These OG object URLs were created using the edit open graph feature of the graph tool
    // at https://www.developers.facebook.com/apps/
    if ([meal isEqualToString:@"Cheeseburger"]) {
        result.url = @"http://samples.ogp.me/314483151980285";
    } else if ([meal isEqualToString:@"Pizza"]) {
        result.url = @"http://samples.ogp.me/314483221980278";
    } else if ([meal isEqualToString:@"Hotdog"]) {
        result.url = @"http://samples.ogp.me/314483265313607";
    } else if ([meal isEqualToString:@"Italian"]) {
        result.url = @"http://samples.ogp.me/314483348646932";
    } else if ([meal isEqualToString:@"French"]) {
        result.url = @"http://samples.ogp.me/314483375313596";
    } else if ([meal isEqualToString:@"Chinese"]) {
        result.url = @"http://samples.ogp.me/314483421980258";
    } else if ([meal isEqualToString:@"Thai"]) {
        result.url = @"http://samples.ogp.me/314483451980255";
    } else if ([meal isEqualToString:@"Indian"]) {
        result.url = @"http://samples.ogp.me/314483491980251";
    }
    return result;
}

// FBSample logic
// Creates the Open Graph Action with an optional photo URL.
- (void)postOpenGraphActionWithPhotoURL:(NSString *)photoURL {
    // First create the Open Graph meal object for the meal we ate.
    id<FMOGMeal> mealObject = [self mealObjectForMeal:self.selectedMeal];
    
    // Now create an Open Graph eat action with the meal, our location, and the people we were with.
    id<FMOGEatMealAction> action = (id<FMOGEatMealAction>)[FBGraphObject graphObject];
    action.meal = mealObject;
    if (self.selectedPlace) {
        // FBSample logic
        // We don't use the action.place syntax here because, unfortunately, setPlace:
        // and a few other selectors may be flagged as reserved selectors by Apple's App Store
        // validation tools. While this doesn't necessarily block App Store approval, it
        // could slow down the approval process. Falling back to the setObjec:forKey:
        // selector is a useful technique to avoid such naming conflicts.
        [action setObject:self.selectedPlace forKey:@"place"];
    }
    if (self.selectedFriends.count > 0) {
        [action setObject:self.selectedFriends forKey:@"tags"];
    }
    if (photoURL) {
        NSMutableDictionary *image = [[NSMutableDictionary alloc] init];
        [image setObject:photoURL forKey:@"url"];
        
        NSMutableArray *images = [[NSMutableArray alloc] init];
        [images addObject:image];
        
        action.image = images;
    }

    // Create the request and post the action to the "me/fb_sample_scrumps:eat" path.
    [FBRequestConnection startForPostWithGraphPath:@"me/fb_sample_scrumps:eat"
                                       graphObject:action
                                 completionHandler:^(FBRequestConnection *connection,
                                                     id result,
                                                     NSError *error) {
                                     [self.activityIndicator stopAnimating];
                                     [self.view setUserInteractionEnabled:YES];
                                     
                                     NSString *alertText;
                                     if (!error) {
                                         alertText = [NSString stringWithFormat:@"Posted Open Graph action, id: %@",
                                                      [result objectForKey:@"id"]];
                                         
                                         // start over
                                         self.selectedMeal = nil;
                                         self.selectedPlace = nil;
                                         self.selectedFriends = nil;
                                         self.selectedPhoto = nil;
                                         [self updateSelections];
                                     } else {
                                         alertText = [NSString stringWithFormat:@"error: domain = %@, code = %d",
                                                      error.domain, error.code];
                                     }
                                     [[[UIAlertView alloc] initWithTitle:@"Result" 
                                                                 message:alertText 
                                                                delegate:nil 
                                                       cancelButtonTitle:@"Thanks!" 
                                                       otherButtonTitles:nil] 
                                      show];
                                 }];
}

// FBSample logic
// Creates an Open Graph Action using the user-specified properties, optionally first
// uploading a photo to Facebook and attaching it to the action. 
- (void)postPhotoThenOpenGraphAction {
    FBRequestConnection *connection = [[FBRequestConnection alloc] init];

    // First request uploads the photo.
    FBRequest *request1 = [FBRequest requestForUploadPhoto:self.selectedPhoto];
    [connection addRequest:request1
        completionHandler:
        ^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
            }
        }
            batchEntryName:@"photopost"
    ];

    // Second request retrieves photo information for just-created photo so we can grab its source.
    FBRequest *request2 = [FBRequest requestForGraphPath:@"{result=photopost:$.id}"];
    [connection addRequest:request2
         completionHandler:
        ^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error &&
                result) {
                NSString *source = [result objectForKey:@"source"];
                [self postOpenGraphActionWithPhotoURL:source];
            }
        }
    ];

    [connection start];
}

// FBSample logic
// Handles the user clicking the Announce button, by either creating an Open Graph Action
// or first uploading a photo and then creating the action.
- (IBAction)announce:(id)sender {
    self.announceButton.enabled = false;
    [self centerAndShowActivityIndicator];
    [self.view setUserInteractionEnabled:NO];
    
    if (self.selectedPhoto) {
        self.selectedPhoto = [self normalizedImage:self.selectedPhoto];
        [self postPhotoThenOpenGraphAction];
    } else {
        [self postOpenGraphActionWithPhotoURL:nil];
    }
}

- (void)centerAndShowActivityIndicator {
    CGRect frame = self.view.frame;
    CGPoint center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
    self.activityIndicator.center = center;
    [self.activityIndicator startAnimating];
}
#pragma mark UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker 
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo {
    
    if (!self.photoViewController) {
        __block FMViewController *myself = self;
        self.photoViewController = [[FMPhotoViewController alloc]initWithNibName:@"FMPhotoViewController" bundle:nil image:image];
        self.photoViewController.confirmCallback = ^(id sender, bool confirm) {
            if(confirm) {
                myself.selectedPhoto = image;
            }
            [myself updateSelections];
        };
    }
    [self.navigationController pushViewController:self.photoViewController animated:true];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.popover dismissPopoverAnimated:YES];
    } else {
        [self dismissModalViewControllerAnimated:YES];
    }
    self.photoViewController = nil;
}

#pragma mark -

#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    // If user presses cancel, do nothing
    if (buttonIndex == actionSheet.cancelButtonIndex)
        return;
    
    // One method handles the delegate action for two action sheets
    if (actionSheet == self.mealPickerActionSheet) { 
        self.selectedMeal = [self.mealTypes objectAtIndex:buttonIndex];
        [self updateSelections];
        
    } else { // self.imagePickerActionSheet
        NSAssert(actionSheet == self.imagePickerActionSheet, @"Delegate method's else-case should be for image picker");
        
        if (!self.imagePicker) {
            self.imagePicker = [[UIImagePickerController alloc] init];
            self.imagePicker.delegate = self;
        }
        
        // Set the source type of the imagePicker to the users selection
        if (buttonIndex == 0) {
            // If its the simulator, camera is no good
            if(TARGET_IPHONE_SIMULATOR){
                [[[UIAlertView alloc] initWithTitle:@"Camera not supported in simulator." 
                                            message:@"(>'_')>" 
                                           delegate:nil 
                                  cancelButtonTitle:@"Ok" 
                                  otherButtonTitles:nil] show];
                return;
            }
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        } else if (buttonIndex == 1) {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            // Can't use presentModalViewController for image picker on iPad
            if (!self.popover) {
                self.popover = [[UIPopoverController alloc] initWithContentViewController:self.imagePicker];
            }
            [self.popover presentPopoverFromRect:self.popoverFromRect 
                                          inView:self.view 
                        permittedArrowDirections:UIPopoverArrowDirectionAny 
                                        animated:YES];
        } else {
            [self presentModalViewController:self.imagePicker animated:YES];
        } 
    }
}


#pragma mark -

#pragma mark Data fetch

- (void)updateCellIndex:(int)index withSubtitle:(NSString *)subtitle {
    UITableViewCell *cell = (UITableViewCell *)[self.menuTableView cellForRowAtIndexPath:
                                                [NSIndexPath indexPathForRow:index inSection:0]];
    cell.detailTextLabel.text = subtitle;
}

- (void)updateSelections {
    [self updateCellIndex:0 withSubtitle:(self.selectedMeal ?
                                          self.selectedMeal : 
                                          @"Select one")];
    [self updateCellIndex:1 withSubtitle:(self.selectedPlace ?
                                          self.selectedPlace.name :
                                          @"Select one")];
    
    NSString *friendsSubtitle = @"Select friends";
    int friendCount = self.selectedFriends.count;
    if (friendCount > 2) {
        // Just to mix things up, don't always show the first friend.
        id<FBGraphUser> randomFriend = [self.selectedFriends objectAtIndex:arc4random() % friendCount];
        friendsSubtitle = [NSString stringWithFormat:@"%@ and %d others", 
            randomFriend.name,
            friendCount - 1];
    } else if (friendCount == 2) {
        id<FBGraphUser> friend1 = [self.selectedFriends objectAtIndex:0];
        id<FBGraphUser> friend2 = [self.selectedFriends objectAtIndex:1];
        friendsSubtitle = [NSString stringWithFormat:@"%@ and %@",
            friend1.name,
            friend2.name];
    } else if (friendCount == 1) {
        id<FBGraphUser> friend = [self.selectedFriends objectAtIndex:0];
        friendsSubtitle = friend.name;
    }
    [self updateCellIndex:2 withSubtitle:friendsSubtitle];
    
    [self updateCellIndex:3 withSubtitle:(self.selectedPhoto ? @"Ready" : @"Take one")];
    
    self.announceButton.enabled = (self.selectedMeal != nil);
}

- (void)requestEventsImages {
    
    NSLog(@"request");
    
    for (FMEvent *event in self.allEvents) {
        
        NSLog(@"new");
        
        NSLog(@"%@",[NSString stringWithFormat:@"%@/picture",event.id]);
        
        [[FBRequest requestForGraphPath:[NSString stringWithFormat:@"%@/picture",event.id] ] startWithCompletionHandler:
         ^(FBRequestConnection *connection, NSDictionary<FBGraphObject> *result, NSError *error) {
             
             NSLog(@"Data pic %@",[result objectForKey:@"data"]);
             
             NSString *url = [[[result objectForKey:@"data"] objectForKey:@"url"] stringValue];
             
             event.image = [UIImage imageWithData:
                            [NSData dataWithContentsOfURL:
                             [NSURL URLWithString:url]]];
             
             NSLog(@"URL %@",url);
         }];
    }
    
    [self.menuTableView reloadData];
}

- (void) request:(HTTPRequest *)request receivedData:(NSData *)data {
    NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
}

- (void) request:(HTTPRequest *)request initialized:(NSURL *)url {
    NSLog(@"%@",[[NSString alloc] initWithData:[request getResponseData] encoding:NSUTF8StringEncoding]);
//    NSLog(@"%@",)
}

// FBSample logic
// Displays the user's name and profile picture so they are aware of the Facebook
// identity they are logged in as.
- (void)populateUserDetails {
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
             if (!error) {
                 self.userNameLabel.text = user.name;
                 self.userProfileImage.profileID = [user objectForKey:@"id"];
                 
                 HTTPRequest *request = [[HTTPRequest alloc] initWithURL:[NSURL URLWithString:@"http://findme.developmentserver.com.ar/users/create"] timeout:60.0 method:@"POST"];
                 [request setDelegate:self];
//                 [request setH]
                 NSString *body = [NSString stringWithFormat:@"fbId=%@",[user objectForKey:@"id" ]];
                 NSLog(@"%@",body);
                 [request setBodyContent:[body dataUsingEncoding:NSUTF8StringEncoding ]];
                 
                 [request start];
                 
//                 __unsafe_unretained ASIFormDataRequest *request= [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://172.16.1.216/findme/user/create"]];
//                 [request setRequestMethod:@"GET"];
//                 [request setPostValue:[user objectForKey:@"id"] forKey:@"id"];
//                 [request setCompletionBlock:^{
//                     NSLog(@"%@",[request responseString]);
//                 }];
//                 [request startAsynchronous];
             }
         }];
        [[FBRequest requestForGraphPath:@"me/events"] startWithCompletionHandler:
         ^(FBRequestConnection *connection, NSDictionary<FBGraphObject> *result, NSError *error) {
             if (!error) {
                 
                 NSLog(@"Data %@",[result objectForKey:@"data"]);
                 
                 NSMutableArray *tmp = [[NSMutableArray alloc] init];
                 
                 for (id i in [result objectForKey:@"data"]) {
                     
                     FMEvent *event = [[FMEvent alloc] init];
                     
                     event.name = [i objectForKey:@"name"];
                     event.startTime = [i objectForKey:@"startTime"];
                     event.endTime = [i objectForKey:@"endTime"];
                     event.location = [i objectForKey:@"location"];
                     event.id = [i objectForKey:@"id"];
                     
                     [tmp addObject:event];
                 }
                 
                 self.allEvents = [[NSArray alloc] initWithArray:tmp];
                 
                 [self.menuTableView reloadData];
                 
                 [self performSelectorInBackground:@selector(requestEventsImages) withObject:nil];
             }
         }];
    }
}

- (void)dealloc {
    _locationManager.delegate = nil;
    _imagePicker.delegate = nil;
    _imagePickerActionSheet.delegate = nil;
    _mealPickerActionSheet.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Find Me!";

    // Get the CLLocationManager going.
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    // We don't want to be notified of small changes in location, preferring to use our
    // last cached results, if any.
    self.locationManager.distanceFilter = 50;
    [self.locationManager startUpdatingLocation];
    
    // This avoids a gray background in the table view on iPad.
    if ([self.menuTableView respondsToSelector:@selector(backgroundView)]) {
        self.menuTableView.backgroundView = nil;
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"Settings" 
                                                style:UIBarButtonItemStyleBordered 
                                              target:self 
                                              action:@selector(settingsButtonWasPressed:)];

    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:self.activityIndicator];

    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(sessionStateChanged:) 
                                                 name:FMSessionStateChangedNotification
                                               object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (FBSession.activeSession.isOpen) {
        [self populateUserDetails];
    }
}

-(void)settingsButtonWasPressed:(id)sender {
    if (self.settingsViewController == nil) {
        self.settingsViewController = [[FBUserSettingsViewController alloc] init];
    }
    [self.navigationController pushViewController:self.settingsViewController animated:YES];
}

- (void)gotoIndividualEvent {
    if (self.eventController == nil) {
        self.eventController = [[FMEventController alloc] init];
    }
    [self.navigationController pushViewController:self.eventController animated:YES];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    // Release any retained subviews of the main view.
    self.photoViewController = nil;
    self.imagePicker = nil;
    self.popover = nil;
    self.imagePickerActionSheet = nil;
    self.mealPickerActionSheet = nil;
}

- (void)sessionStateChanged:(NSNotification*)notification {
    // A more complex app might check the state to see what the appropriate course of
    // action is, but our needs are simple, so just make sure our idea of the session is
    // up to date and repopulate the user's name and picture (which will fail if the session
    // has become invalid).
    [self populateUserDetails];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)setPlaceCacheDescriptorForCoordinates:(CLLocationCoordinate2D)coordinates {
    self.placeCacheDescriptor =
    [FBPlacePickerViewController cacheDescriptorWithLocationCoordinate:coordinates
                                                        radiusInMeters:1000
                                                            searchText:@"restaurant"
                                                          resultsLimit:50
                                                      fieldsForRequest:nil];
}

#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.allEvents count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.textLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        cell.textLabel.lineBreakMode = UILineBreakModeTailTruncation;
        cell.textLabel.clipsToBounds = YES;

        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        cell.detailTextLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.4 green:0.6 blue:0.8 alpha:1];
        cell.detailTextLabel.lineBreakMode = UILineBreakModeTailTruncation;
        cell.detailTextLabel.clipsToBounds = YES;
    }
    
    FMEvent *event = [self.allEvents objectAtIndex:indexPath.row];
    
    cell.textLabel.text = event.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@ - %@", event.location, event.startTime, event.endTime];
    cell.imageView.image = event.image;

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    currentId = [[self.allEvents objectAtIndex:indexPath.row] id];
    
//    UIViewController *target;
    
    /*
//    switch (indexPath.row) {
//        case 0: {
//            // if we don't yet have an array of meal types, create one now
//            if (!self.mealTypes) {
//                self.mealTypes = [NSArray arrayWithObjects:
//                                  @"Cheeseburger", 
//                                  @"Pizza",
//                                  @"Hotdog",
//                                  @"Italian",
//                                  @"French",
//                                  @"Chinese",
//                                  @"Thai",
//                                  @"Indian",
//                                  nil];
//            }
//            self.mealPickerActionSheet = [[UIActionSheet alloc] initWithTitle:@"Select a meal"
//                                                                     delegate:self
//                                                            cancelButtonTitle:nil
//                                                       destructiveButtonTitle:nil
//                                                            otherButtonTitles:nil];
//                                          
//            for( NSString *meal in self.mealTypes) {
//                [self.mealPickerActionSheet addButtonWithTitle:meal]; 
//            }
//            
//            self.mealPickerActionSheet.cancelButtonIndex = [self.mealPickerActionSheet addButtonWithTitle:@"Cancel"];
//            
//            [self.mealPickerActionSheet showInView:self.view];
//            return;
//        }
//        
//        case 1: {
//            FBPlacePickerViewController *placePicker = [[FBPlacePickerViewController alloc] init];
//            
//            placePicker.title = @"Select a restaurant";
//
//            // SIMULATOR BUG:
//            // See http://stackoverflow.com/questions/7003155/error-server-did-not-accept-client-registration-68
//            // at times the simulator fails to fetch a location; when that happens rather than fetch a
//            // a meal near 0,0 -- let's see if we can find something good in Paris
//            if (self.placeCacheDescriptor == nil) {
//                [self setPlaceCacheDescriptorForCoordinates:CLLocationCoordinate2DMake(48.857875, 2.294635)];
//            }
//            
//            [placePicker configureUsingCachedDescriptor:self.placeCacheDescriptor];
//            [placePicker loadData];
//            [placePicker presentModallyFromViewController:self
//                                                 animated:YES
//                                                  handler:^(FBViewController *sender, BOOL donePressed) {
//                                                      if (donePressed) {
//                                                          self.selectedPlace = placePicker.selection;
//                                                          [self updateSelections];
//                                                      }
//                                                  }];
//            return;
//        }
//            
//        case 2: {
//            FBFriendPickerViewController *friendPicker = [[FBFriendPickerViewController alloc] init];
//            
//            // Set up the friend picker to sort and display names the same way as the
//            // iOS Address Book does.
//            
//            // Need to call ABAddressBookCreate in order for the next two calls to do anything.
//            ABAddressBookCreate();
//            ABPersonSortOrdering sortOrdering = ABPersonGetSortOrdering();
//            ABPersonCompositeNameFormat nameFormat = ABPersonGetCompositeNameFormat();
//            
//            friendPicker.sortOrdering = (sortOrdering == kABPersonSortByFirstName) ? FBFriendSortByFirstName : FBFriendSortByLastName;
//            friendPicker.displayOrdering = (nameFormat == kABPersonCompositeNameFormatFirstNameFirst) ? FBFriendDisplayByFirstName : FBFriendDisplayByLastName;
//            
//            [friendPicker loadData];
//            [friendPicker presentModallyFromViewController:self
//                                                  animated:YES
//                                                   handler:^(FBViewController *sender, BOOL donePressed) {
//                                                       if (donePressed) {
//                                                           self.selectedFriends = friendPicker.selection;
//                                                           [self updateSelections];
//                                                       }
//                                                   }];
//            return;
//        }
//            
//        case 3:            
//            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//                self.popoverFromRect = [tableView rectForRowAtIndexPath:indexPath];
//            }
//            if(!self.imagePickerActionSheet) {
//                self.imagePickerActionSheet = [[UIActionSheet alloc] initWithTitle:@""
//                                                                          delegate:self
//                                                                 cancelButtonTitle:@"Cancel"
//                                                            destructiveButtonTitle:nil
//                                                                 otherButtonTitles:@"Take Photo", @"Choose Existing", nil];
//            }
//            
//            [self.imagePickerActionSheet showInView:self.view];
//            // Return rather than execute below code
//            return;
//    }*/
    
    [self gotoIndividualEvent];
    
//    [self.navigationController pushViewController:target animated:YES];
}

#pragma mark -
#pragma mark CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager 
    didUpdateToLocation:(CLLocation *)newLocation 
           fromLocation:(CLLocation *)oldLocation {
    if (!oldLocation ||
        (oldLocation.coordinate.latitude != newLocation.coordinate.latitude && 
         oldLocation.coordinate.longitude != newLocation.coordinate.longitude &&
         newLocation.horizontalAccuracy <= 100.0)) {
            // Fetch data at this new location, and remember the cache descriptor.
            [self setPlaceCacheDescriptorForCoordinates:newLocation.coordinate];
            [self.placeCacheDescriptor prefetchAndCacheForSession:FBSession.activeSession];
    }
}

- (void)locationManager:(CLLocationManager *)manager 
       didFailWithError:(NSError *)error {
	NSLog(@"%@", error);
}

#pragma mark -

- (UIImage*) normalizedImage:(UIImage*)image {
	CGImageRef          imgRef = image.CGImage;
	CGFloat             width = CGImageGetWidth(imgRef);
	CGFloat             height = CGImageGetHeight(imgRef);
	CGAffineTransform   transform = CGAffineTransformIdentity;
	CGRect              bounds = CGRectMake(0, 0, width, height);
    CGSize              imageSize = bounds.size;
	CGFloat             boundHeight;
    UIImageOrientation  orient = image.imageOrientation;
    
	switch (orient) { 
		case UIImageOrientationUp: //EXIF = 1
			transform = CGAffineTransformIdentity;
			break;
            
		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
            
		case UIImageOrientationLeft: //EXIF = 6
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
            
		case UIImageOrientationRight: //EXIF = 8
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
            
		default:
            // image is not auto-rotated by the photo picker, so whatever the user
            // sees is what they expect to get. No modification necessary
            transform = CGAffineTransformIdentity;
            break;
	}
    
	UIGraphicsBeginImageContext(bounds.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
    
    if ((image.imageOrientation == UIImageOrientationDown) || 
        (image.imageOrientation == UIImageOrientationRight) || 
        (image.imageOrientation == UIImageOrientationUp)) {
        // flip the coordinate space upside down
        CGContextScaleCTM(context, 1, -1);
        CGContextTranslateCTM(context, 0, -height);
    }
    
	CGContextConcatCTM(context, transform);
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
	return imageCopy;
}

@end
