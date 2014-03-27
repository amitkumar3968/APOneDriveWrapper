//  Created by Alexey Potapov on 3/13/14.
//

#pragma message @"some standard methods are omitted"
#pragma message @"I assume that you are using MagicalRecord (Core Data wrapper) to store your accounts"
//Magical record you can find here
//Exmaple its usage is here: http://yannickloriot.com/2012/03/magicalrecord-how-to-make-programming-with-core-data-pleasant

#import "ExampleMainViewController.h"
#import "UserAccount.h"
#import "ExampleFilesViewController.h"
#import "APOneDriveWrapper.h"

@interface GRMainViewController ()
    @property (nonatomic, strong) APOneDriveWrapper *oneDriveWrapper;
@end

@implementation ExampleMainViewController


- (void) viewDidLoad
{
    [super viewDidLoad];    

    //This notification is to get file data from APOneDriveWrapper
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openOneDriveWithNotification:) name:@"MSOneDriveOpenRoot" object:nil];
}

//OneDrive login
- (void) showOneDriveLoginView
{
    UserAccount *user = [UserAccount MR_findFirstByAttribute:@"cloudName" withValue:@"MSOneDrive"];
    if (!user)
    {
        if (!self.oneDriveWrapper)
        {
            self.oneDriveWrapper = nil;
            self.oneDriveWrapper = [GRoneDriveWrapper new];
        }
        
        [self.oneDriveWrapper prepareOneDrive:self];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Only one OneDrive account is available" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

//Open the folder
- (void) openFileSystemForUser:(UserAccount *)userAccount
{
    if ([userAccount.cloudName isEqualToString:@"MSOneDrive"])
    {
        //check if we need to revoke the manager (for case, when we turn off the application)
        if (!self.oneDriveWrapper)
        {
            self.oneDriveWrapper = [GRoneDriveWrapper new];
            [self.oneDriveWrapper revokeAccess];
        }
        //
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MSOneDriveOpenFolderForPath" object:@"/me/skydrive/files"];
    }
}

- (void) openOneDriveWithNotification:(NSNotification *) notif
{
    if (notif.object)
    {
        [self navigateToStorageWithDataArray:notif.object];
    }
}

- (void) navigateToStorageWithDataArray:(NSArray *) files
{
    //initialize our ExampleFilesViewController
    ExampleFilesViewController *exampleFilesVC = [[ExampleFilesViewController alloc] init];
    
    exampleFilesVC.arrayWithFiles = files;
    
    [self.navigationController pushViewController:exampleFilesVC animated:YES];
}

#pragma mark - Remove account
- (void) deleteAccount:(NSString *) userId
{
    [self.oneDriveWrapper deleteOneDriveUser];
    
    //the Core Data delete process
    UserAccount *user = [UserAccount MR_findFirstByAttribute:@"userId" withValue:userId];
    [user MR_deleteEntity];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];

}

@end
