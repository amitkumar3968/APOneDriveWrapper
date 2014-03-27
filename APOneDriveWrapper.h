//  Created by Alexey Potapov on 3/13/14.
//
#import "UserAccount.h"
#import "LiveSDK/LiveConnectClient.h"

@interface GRoneDriveWrapper : NSObject  <LiveAuthDelegate, LiveOperationDelegate, LiveDownloadOperationDelegate, LiveUploadOperationDelegate>

@property (nonatomic, strong) LiveConnectClient *liveClient;
@property (nonatomic, strong) NSArray *arrayWithfiles;

- (void) prepareOneDrive:(UIViewController *) vc;
- (void) deleteOneDriveUser;
- (void) revokeAccess;

@end
