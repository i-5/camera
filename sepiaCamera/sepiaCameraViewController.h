//
//  sepiaCameraViewController.h
//  sepiaCamera
//
//  Created by 子民 駱 on 8/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface sepiaCameraViewController : UIViewController 
<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    
    UIToolbar *toolBar;
    UIImageView *imageView;
}

@property (nonatomic, retain) IBOutlet UIToolbar *toolBar;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
- (IBAction)selectImage:(id)sender;
- (IBAction)saveImage:(id)sender;
@end
