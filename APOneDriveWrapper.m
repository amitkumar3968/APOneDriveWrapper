//  Created by Alexey Potapov on 3/13/14.
//
#import "GRoneDriveWrapper.h"

@interface GRoneDriveWrapper()
    @property (nonatomic, strong) UIViewController *activeViewController;
    @property (nonatomic, strong) NSString *clientID = @"YOUR_CLIENTID";
@end

@implementation GRoneDriveWrapper 

- (void) prepareOneDrive:(UIViewController *) vc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makeGetOperationWithQueue:) name:@"MSOneDriveOpenFolderForPath" object:nil];
    self.activeViewController = vc;
    self.liveClient = [[LiveConnectClient alloc] initWithClientId:clientID
                                                         delegate:self
                                                        userState:@"initialize"];
}

//Code mostly copied from original Live-sdk example
- (void)authCompleted:(LiveConnectSessionStatus) status
              session:(LiveConnectSession *) session
            userState:(id) userState
{
    if ([userState isEqual:@"initialize"])
    {
    //more about scopes read here http://msdn.microsoft.com/en-us/library/live/hh243646.aspx
        [self.liveClient login:self.activeViewController
                        scopes:[NSArray arrayWithObjects:@"wl.basic", @"wl.contacts_skydrive", @"wl.offline_access", nil]
                      delegate:self
                     userState:@"signin"];
    }
    if ([userState isEqual:@"signin"])
    {
        if (session != nil)
        {
            [self.liveClient getWithPath:@"me"
                                delegate:self
                               userState:@"getMe"];
        }
    }
}

- (void)authFailed:(NSError *) error  userState:(id)userState
{
    [[[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Error: %@", [error localizedDescription]] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

- (void) liveOperationSucceeded:(LiveOperation *)operation
{
    if ([operation.userState isEqual:@"getMe"])
    {
        UserAccount *user = [UserAccount MR_createEntity];
        user.cloudName = @"MSOneDrive";
        user.userId = [operation.result objectForKey:@"id"];
        user.userName = [operation.result objectForKey:@"name"];
        
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }
    else if ([operation.userState isEqual:@"getFiles"])
    {
        self.arrayWithfiles = [operation.result objectForKey:@"data"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MSOneDriveOpenRoot" object:self.arrayWithfiles];
    }
}

- (void) revokeAccess
{
    if (!self.liveClient)
    {
        self.liveClient = [[LiveConnectClient alloc] initWithClientId:clientID
                                                             delegate:self];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makeGetOperationWithQueue:) name:@"MSOneDriveOpenFolderForPath" object:nil];
    }
}

- (void) deleteOneDriveUser
{    
    [self.liveClient logoutWithDelegate:self userState:@"signout"];
    self.liveClient = nil;
}

- (void) makeGetOperationWithQueue:(NSNotification *) notif
{
    [self.liveClient getWithPath:notif.object delegate:self userState:@"getFiles"];
}

@end
