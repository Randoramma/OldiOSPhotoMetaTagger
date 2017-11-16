//
//  CameraViewController.m
//  OldPhotoTagger
//
//  Created by Randy McLain on 11/15/17.
//  Copyright © 2017 Randy McLain. All rights reserved.
//

#import "CameraViewController.h"
#import "Macros.h"
#import "MetaImage.h"
#import "UTIHelper.h"
#import <Photos/Photos.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface CameraViewController ()
{
    UIImageView *imageView;
    UISwitch *editSwitch;
    UIPopoverPresentationController * popover;
}
@end

@implementation CameraViewController
{
//    UIImageView * imageView;
//    UISwitch * editSwitch;
//    UIPopoverPresentationController * popover;
}

- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    cameraUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeCamera];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    
    cameraUI.delegate = delegate;
    
   // [controller presentModalViewController: cameraUI animated: YES];
    [controller presentViewController:cameraUI animated:YES completion:nil];
    return YES;
}

- (IBAction) showCameraUI {
    [self startCameraControllerFromViewController: self
                                    usingDelegate: self];
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    
    [[picker parentViewController] dismissViewControllerAnimated:TRUE completion:nil];
}

- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    
    // Handle a still image capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToSave = editedImage;
        } else {
            imageToSave = originalImage;
        }
        
        MetaImage *mi = [MetaImage newImage:imageToSave];
        mi.exif[@"UserComment"] = @"This is a test comment";
        char makerNoteString[] = "{'Info': {'device_id': 'S0000001','local_accuracy': 1.0, 'target_accuracy': 1.0 ,'pitch': 4.714753506998264,'roll': -89.9984219326346,'rotation': -90,'destination_altitude': 33.37687902208307,'declination': 0}}";
        mi.exif[MAKERKEY] = [[NSString alloc] initWithCString:makerNoteString encoding:kCFStringEncodingUTF8];
        NSNumber * latitude = [NSNumber numberWithDouble:47.4354956457547];
        NSNumber * longitude = [NSNumber numberWithDouble:122.290824794171];
        NSNumber * altitude = [NSNumber numberWithDouble:100.0];
        NSNumber * imgDirection = [NSNumber numberWithDouble:333.0];
        NSNumber * destDistance = [NSNumber numberWithDouble:0.010];
        NSNumber * destLongitude = [NSNumber numberWithDouble:122.335800];
        NSNumber * destLatitude = [NSNumber numberWithDouble:47.605800];
        
        mi.gps[LATKEY] = latitude;
        mi.gps[LONGKEY] = longitude;
        mi.gps[ALTITUDEKEY] = altitude;
        mi.gps[DIRECTIONKEY] = imgDirection;
        mi.gps[DESTDISTANCEKEY] = destDistance;
        mi.gps[DESTLONGKEY] = destLongitude;
        mi.gps[DESTLATKEY] = destLatitude;
        
        mi.gps[LATREFKEY] = @"N";
        mi.gps[LONGREFKEY] = @"W";
        mi.gps[DESTLATREFKEY] = @"N";
        mi.gps[DESTLONGREFKEY] = @"W";
        mi.gps[DESTDISTANCEREFKEY] = @"K";
        mi.gps[GPSTIMEKEY] = @"12:30:19";
        mi.gps[GPSDATEKEY] = @"2017:11:16";
        
        NSLog(@"%@", mi.properties);
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *destPath = [documentsDirectory stringByAppendingPathComponent:@"temp.jpg"];
        NSURL * destURL = [NSURL URLWithString:destPath];
        
        [mi writeToPath:destPath];
        // Save the new image (original or edited) to the Camera Roll
        __weak __typeof__(self) weakSelf = self;
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:destURL];
        }   completionHandler:^(BOOL success, NSError *error) {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf dismissViewControllerAnimated:TRUE completion:nil];
                });
            }
        }];

    }
    
    // Handle a movie capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0)
        == kCFCompareEqualTo) {
        
        NSString *moviePath = [[info objectForKey:
                                UIImagePickerControllerMediaURL] path];
        
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath)) {
            UISaveVideoAtPathToSavedPhotosAlbum (
                                                 moviePath, nil, nil, nil);
        }
    }
    
    [[picker parentViewController] dismissViewControllerAnimated:TRUE completion:nil];
}

// Finished saving
- (void)image:(UIImage *)image didFinishSavingWithError: (NSError *)error contextInfo:(void *)contextInfo;
{
    // Handle the end of the image write process
    if (!error) {
        NSLog(@"Image written to photo album");
        [self dismissViewControllerAnimated:TRUE completion:nil];
    } else {
        NSLog(@"Error writing to photo album: %@", error.localizedFailureReason);
    }
}



- (void) snapImage
{
    if (popover) return;
    
    // Create and initialize the picker
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType =  UIImagePickerControllerSourceTypeCamera;
    picker.allowsEditing = editSwitch.isOn;
    picker.delegate = self;
    
    [self presentViewController:picker];
}

- (void) presentViewController:(UIViewController *)viewControllerToPresent
{
    if (IS_IPHONE)
    {
        [self presentViewController:viewControllerToPresent animated:YES completion:nil];
    }
    else
    {
//        popover = [[UIPopoverController alloc] initWithContentViewController:viewControllerToPresent];
//        popover.delegate = self;
//        [popover presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    
    PREPCONSTRAINTS(imageView);
    STRETCH_VIEW(self.view, imageView);
    
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera]) {
        self.navigationItem.rightBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemCamera, @selector(snapImage));
    }
    
    // Setup title view with Edits: ON/OFF
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 44.0f)];
    RESIZABLE(toolbar);
    self.navigationItem.titleView = toolbar;
    editSwitch = [[UISwitch alloc] init];
    toolbar.items = @[BARBUTTON(@"Edits", nil), CUSTOMBARBUTTON(editSwitch)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
