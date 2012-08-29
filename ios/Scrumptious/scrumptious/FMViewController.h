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

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <FacebookSDK/FacebookSDK.h>
#import "HTTPRequest.h"

typedef void(^SelectItemCallback)(id sender, id selectedItem);

// FBSample logic
// The main UI for the application, which lets the user select a type of food, tag who they
// are with and where they are, and choose a photo for attaching to an Open Graph Action.
@interface FMViewController : UIViewController <FBUserSettingsDelegate, HTTPRequestDelegate>

+ (NSString *)selectedEventId;

@end
