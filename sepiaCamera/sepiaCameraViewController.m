//
//  sepiaCameraViewController.m
//  sepiaCamera
//
//  Created by 子民 駱 on 8/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "sepiaCameraViewController.h"

@implementation sepiaCameraViewController
@synthesize imageView;
@synthesize toolBar;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [self setToolBar:nil];
    [self setImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [toolBar release];
    [imageView release];
    [super dealloc];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    UIImagePickerControllerSourceType sourceType;
    switch (buttonIndex) {
        case 0:
            sourceType = UIImagePickerControllerSourceTypeCamera;
            break;
        case 1:
            sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
        case 2:
            sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            break;
        default:
            return;
    }
    
    if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
        return;
    }
    
    UIImagePickerController *picker = [[[UIImagePickerController alloc] init] autorelease];
    picker.sourceType = sourceType;
    picker.allowsEditing = YES;
    picker.delegate = self;
    
    [self presentModalViewController:picker animated:YES];
}

- (IBAction)selectImage:(id)sender {
    UIActionSheet* sheet = [[[UIActionSheet alloc] init] autorelease];
    sheet.delegate = self;
    
    [sheet addButtonWithTitle:@"Camera"];
    [sheet addButtonWithTitle:@"Photo albums"];
    [sheet addButtonWithTitle:@"Saved photos"];
    [sheet addButtonWithTitle:@"Cancel"];
    sheet.cancelButtonIndex = 3;
    [sheet showFromToolbar:self.toolBar];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *) error contextInfo:(void *)contextInfo {
    NSString *message;
    if (error) {
        message = @"ERROR!";
    } else {
        message = @"SUCCESS!";
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Save image" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
    [alert release];
}

- (IBAction)saveImage:(id)sender {
    UIImageWriteToSavedPhotosAlbum(self.imageView.image, 
                                   self, 
                                   @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

- (void)sepiaFilter {
    CGImageRef cgImage = self.imageView.image.CGImage;
    
    size_t width = CGImageGetWidth(cgImage);
    size_t height = CGImageGetHeight(cgImage);
    size_t bitsPerComponent = CGImageGetBitsPerComponent(cgImage);
    size_t bitsPerPixel = CGImageGetBitsPerPixel(cgImage);
    size_t bytesPerRow = CGImageGetBytesPerRow(cgImage);
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(cgImage);
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(cgImage);
    bool shouldInterpolate = CGImageGetShouldInterpolate(cgImage);
    CGColorRenderingIntent renderingIntent = CGImageGetRenderingIntent(cgImage);
    CGDataProviderRef dataProvider = CGImageGetDataProvider(cgImage);
    CFDataRef data = CGDataProviderCopyData(dataProvider);
    UInt8 *buf = (UInt8*)CFDataGetBytePtr(data);
    
    for (int j = 0; j < height; j++) {
        for (int i = 0; i < width; i++) {
            UInt8 *pixel = buf + j * bytesPerRow + i * 4;
            
            UInt8 r = *(pixel + 2);
            UInt8 g = *(pixel + 1);
            UInt8 b = *(pixel + 0);
            
            UInt8 y = (77 * r + 28 * g + 151 * b) / 256;
            
            int tmp;
            
            tmp = y + 30;
            if (tmp > 255) tmp = 255;
            r = tmp;
            
            g = y;
            
            tmp = y - 30;
            if (tmp < 0) tmp = 0;
            b = tmp;
            
            *(pixel + 2) = r;
            *(pixel + 1) = g;
            *(pixel + 0) = b;
        }
    }
    
    CFDataRef filterData = CFDataCreate(NULL, buf, CFDataGetLength(data));
    CGDataProviderRef filterDataProvider = CGDataProviderCreateWithCFData(filterData);
    CGImageRef filterCgImage = CGImageCreate(width, 
                                             height, 
                                             bitsPerComponent, 
                                             bitsPerPixel, 
                                             bytesPerRow, 
                                             colorSpace, 
                                             bitmapInfo, 
                                             filterDataProvider, 
                                             NULL, 
                                             shouldInterpolate,
                                             renderingIntent);
    self.imageView.image = [[[UIImage alloc] initWithCGImage:filterCgImage scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationUp] autorelease];
    
    CGImageRelease(filterCgImage);
    CFRelease(filterDataProvider);
    CFRelease(filterData);
    CFRelease(data);
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissModalViewControllerAnimated:YES];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    CGSize size = CGSizeMake(300, 300);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGRect rect;
    rect.origin = CGPointZero;
    rect.size = size;
    [image drawInRect:rect];
    
    self.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self sepiaFilter];
}

@end
