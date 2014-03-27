//  Created by Alexey Potapov on 3/13/14.
//

#import "ExampleFilesViewController.h"

@implementation ExampleFilesViewController

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deeperOneDriveWithNotification:) name:@"MSOneDriveOpenRoot" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) clickOnElementAtIndex:(NSNumber *) index
    NSDictionary *file = [self.arrayWithFiles objectAtIndex:index];
    if ([[file objectForKey:@"type"] isEqualToString:@"file"])
    {
        //get our file
        NSError *error;
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[file objectForKey:@"source"]]options:NSDataReadingUncached error:&error];
        if (error)
        {
             NSLog(@"%@", [error localizedDescription]);
        }
        else
        {
            //save it maybe?
        }
    }
    else
    {
        //or go deeper
        [[NSNotificationCenter defaultCenter] postNotificationName:kOneDriveDeeper object:[NSString stringWithFormat:@"%@/files",[file objectForKey:@"id"]]];
    }
}

#pragma mark - helpers
- (void) deeperOneDriveWithNotification:(NSNotification *) notif
{
    if (notif.object)
    {
        [self navigateToStorageWithDataArray:notif.object];
    }
}

- (void) navigateToStorageWithDataArray:(NSArray *) files
{
    ExampleFilesViewController *filesVC = [[ExampleFilesViewController alloc] init];
    
    filesVC.arrayWithFiles = files;
    
    [self.navigationController pushViewController:filesVC animated:YES];
}


@end
