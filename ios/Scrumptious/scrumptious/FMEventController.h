//
//  FMEventController.h
//  Find Me!
//
//  Created by Martin Goffan on 8/29/12.
//
//

#import <UIKit/UIKit.h>

@interface FMEventController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end
