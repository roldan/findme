//
//  FMEventController.m
//  Find Me!
//
//  Created by Martin Goffan on 8/29/12.
//
//

#import "FMEventController.h"
#import "FMViewController.h"
#import "FMFriend.h"
#import "ASIHTTPRequest.h"
#import <AddressBook/AddressBook.h>

@interface FMEventController ()

@property (strong, nonatomic) NSMutableArray *selectedFriends;
@property (strong, nonatomic) NSMutableArray *attending;

@property (strong, nonatomic) FBProfilePictureView *fbView;

@property (strong, nonatomic) NSString *currentId;

@end

@implementation FMEventController
@synthesize myTableView = _myTableView;
@synthesize attending = _attending;
@synthesize currentId = _currentId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    self.currentId = [FMViewController selectedEventId];
    
    if (self.attending == nil) {
        self.attending = [[NSMutableArray alloc] init];
    }
    
    [[FBRequest requestForGraphPath:[NSString stringWithFormat:@"%@/attending",self.currentId]] startWithCompletionHandler:
     ^(FBRequestConnection *connection, NSDictionary<FBGraphObject> *result, NSError *error) {
         
//         NSLog(@"Data: %@",[result objectForKey:@"data"]);
         
         for (id i in [result objectForKey:@"data"]) {
             
             NSLog(@"%@",i);
             
             FMFriend *friend = [[FMFriend alloc] init];
             
             friend.fullName = [i objectForKey:@"name"];
             friend.id = [i objectForKey:@"id"];
             
             NSLog(@"%@",friend.description);
             
             [self.attending addObject:friend];
         }
         
         NSLog(@"%d",self.attending.count);
         
         [self.myTableView reloadData];
    }];
}

- (void)viewDidUnload
{
    [self setMyTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSLog(@"%d",[self.attending count]);
    
    self.title = [NSString stringWithFormat:@"%d people are Attending",[self.attending count]];
    
    return [self.attending count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.textLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        cell.textLabel.lineBreakMode = UILineBreakModeTailTruncation;
        cell.textLabel.clipsToBounds = YES;
        
//        CGRect rect = cell.textLabel.frame;
        cell.textLabel.frame = CGRectMake(100, 25, 200, 30);
        
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        cell.detailTextLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.4 green:0.6 blue:0.8 alpha:1];
        cell.detailTextLabel.lineBreakMode = UILineBreakModeTailTruncation;
        cell.detailTextLabel.clipsToBounds = YES;
    }
    
    FMFriend *event = [self.attending objectAtIndex:indexPath.row];
    
//    CGRect rect = cell.textLabel.frame;
    
    
    
    
    cell.textLabel.text = event.fullName;
    
    cell.textLabel.frame = CGRectMake( 100, 25, 200, 30);
    
    FBProfilePictureView *tempPictureView = [[FBProfilePictureView alloc] initWithProfileID:event.id pictureCropping:FBProfilePictureCroppingSquare];
    
    tempPictureView.frame = CGRectMake(0, 0, 80, 80);
    
    [cell addSubview:tempPictureView];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
    
//    [self gotoIndividualEvent];
    
    //    [self.navigationController pushViewController:target animated:YES];
}

@end
