#import "GAPlugin.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "AppDelegate.h"

static NSString *trackerName = @"tracker";

@implementation GAPlugin
- (void) initGA:(CDVInvokedUrlCommand*)command
{
    NSString    *callbackId = command.callbackId;
    NSString    *accountID = [command.arguments objectAtIndex:0];
    NSInteger   dispatchPeriod = [[command.arguments objectAtIndex:1] intValue];

    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = dispatchPeriod;
    // Optional: set debug to YES for extra debugging information.
    //[GAI sharedInstance].debug = YES;
    // Create tracker instance.
    [[GAI sharedInstance] trackerWithName:trackerName trackingId:accountID];
    // Set the appVersion equal to the CFBundleVersion
    //[GAI sharedInstance].defaultTracker = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    [[[GAI sharedInstance] defaultTracker] send:@{
        kGAIAppVersion: [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]
    }];
    inited = YES;

    [self successWithMessage:[NSString stringWithFormat:@"initGA: accountID = %@; Interval = %li seconds",accountID, dispatchPeriod] toID:callbackId];
}

-(void) exitGA:(CDVInvokedUrlCommand*)command
{
    NSString *callbackId = command.callbackId;

    if (inited)
        [[GAI sharedInstance] removeTrackerByName:trackerName];

    [self successWithMessage:@"exitGA" toID:callbackId];
}

- (void) trackEvent:(CDVInvokedUrlCommand*)command
{
    NSString        *callbackId = command.callbackId;
    NSString        *category = [command.arguments objectAtIndex:0];
    NSString        *eventAction = [command.arguments objectAtIndex:1];
    NSString        *eventLabel = [command.arguments objectAtIndex:2];
    NSInteger       eventValue = [[command.arguments objectAtIndex:3] intValue];

    if (inited)
    {
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category action:eventAction label:eventLabel value:@(eventValue)] build]];
        [self successWithMessage:[NSString stringWithFormat:@"trackEvent: category = %@; action = %@; label = %@; value = %li", category, eventAction, eventLabel, eventValue] toID:callbackId];
    }
    else
        [self failWithMessage:@"trackEvent failed - not initialized" toID:callbackId withError:nil];
}

- (void) trackPage:(CDVInvokedUrlCommand*)command
{
    NSString            *callbackId = command.callbackId;
    NSString            *pageURL = [command.arguments objectAtIndex:0];

    if (inited)
    {
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:kGAIScreenName value:pageURL];
        [tracker send:[[GAIDictionaryBuilder createAppView]  build]];

        [self successWithMessage:[NSString stringWithFormat:@"trackPage: url = %@", pageURL] toID:callbackId];
    }
    else
        [self failWithMessage:@"trackPage failed - not initialized" toID:callbackId withError:nil];
}

-(void)successWithMessage:(NSString *)message toID:(NSString *)callbackID
{
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];

    [self.commandDelegate sendPluginResult:commandResult callbackId:callbackID];
}

-(void)failWithMessage:(NSString *)message toID:(NSString *)callbackID withError:(NSError *)error
{
    NSString        *errorMessage = (error) ? [NSString stringWithFormat:@"%@ - %@", message, [error localizedDescription]] : message;
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorMessage];

    [self.commandDelegate sendPluginResult:commandResult callbackId:callbackID];
}

-(void)dealloc
{
    [[GAI sharedInstance] removeTrackerByName:trackerName];
   // [super dealloc];
}

@end
