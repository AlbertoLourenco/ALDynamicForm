//
//  ALDynamicForm.h
//  ALDynamicForm
//
//  Created by Alberto Lourenco on 7/20/14.
//  Copyright (c) 2014 Alberto Lourenço. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define ALDynamicForm_ElementDefaultMarginTop 1.0f
#define ALDynamicForm_ElementDefaultWidth 300.0f
#define ALDynamicForm_ElementDefaultHeight 50.0f
#define ALDynamicForm_ElementDefaultPadding 10.0f
#define ALDynamicForm_ElementDefaultTextViewPadding 10.0f
#define ALDynamicForm_ElementInputTypeDateFormats @[@"MM/dd/yyyy", @"dd/MM/yyyy", @"yyyy-MM-dd"]

#define ALDynamicForm_ElementInputTypeDateInvalid @"Invalid date"
#define ALDynamicForm_ElementPlaceholderDefaultValue @"Put some text here..."

#define ALDynamicForm_FormShowScrollVertical NO
#define ALDynamicForm_FormShowScrollHorizontal NO

#define ALDynamicForm_NotificationSubmitForm @"ALDynamicFormNotificationSubmitForm"

@interface RowElement : NSObject

@property (nonatomic, strong) NSString* fieldName;

@property (nonatomic, assign) float width;
@property (nonatomic, assign) float height;
@property (nonatomic, assign) float padding;

@property (nonatomic, strong) UIImage* backgroundImage;
@property (nonatomic, strong) UIColor* backgroundColor;

@end

//============================================================================================================
//  Form
//============================================================================================================

@interface ALDynamicForm : UIViewController <UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong) UIScrollView* scroll;

- (UIView*)generateForm:(NSMutableArray*)elements;
- (id)initWithFrame:(CGRect)frame andElements:(NSMutableArray*)elementsArray onView:(UIView*)view;

@end

//============================================================================================================
//  FormInput
//============================================================================================================

typedef enum {
    InputType_KeyboardNormal    = UIKeyboardTypeDefault,
    InputType_KeyboardNumbers   = UIKeyboardTypeNumberPad,
    InputType_KeyboardEmail     = UIKeyboardTypeEmailAddress,
    InputType_Date              = 80
}InputType;

@interface FormInput : RowElement

@property (nonatomic, strong) UIFont* textFont;
@property (nonatomic, strong) UIColor* textColor;
@property (nonatomic, strong) NSString* placeholderText;
@property (nonatomic, strong) UIColor* placeholderColor;
@property (nonatomic, strong) NSString* maskFilter;
@property (nonatomic, assign) UITextBorderStyle borderStyle;

@property (nonatomic, assign) InputType inputType;

@end

//-------------------------------------------------------
//  Input
//-------------------------------------------------------

@interface Input : UITextField

@property (nonatomic, assign) InputType inputType;
@property (nonatomic, strong) NSString* maskFilter;

@end

//============================================================================================================
//  FormTextArea
//============================================================================================================

@interface FormTextArea : RowElement

@property (nonatomic, strong) UIFont* textFont;
@property (nonatomic, strong) UIColor* textColor;
@property (nonatomic, strong) NSString* placeholderText;
@property (nonatomic, strong) UIColor* placeholderColor;

@end

//============================================================================================================
//  FormSwitch
//============================================================================================================

@interface FormSwitch : RowElement

@property (nonatomic, strong) NSString* labelTextValue;
@property (nonatomic, strong) UIColor* labelTextColor;
@property (nonatomic, strong) UIFont* labelTextFont;

@end

//============================================================================================================
//  FormSlider
//============================================================================================================

@interface FormSlider : RowElement

@property (nonatomic, assign) float minimumValue;
@property (nonatomic, assign) float maximumValue;

@property (nonatomic, strong) NSString* labelTextValue;
@property (nonatomic, strong) UIColor* labelTextColor;
@property (nonatomic, strong) UIFont* labelTextFont;

@property (nonatomic, assign) UIViewContentMode backgroundContentMode;

@end

//-------------------------------------------------------
//  Slider
//-------------------------------------------------------

@interface Slider : UISlider

- (void)sliderValue:(id)sender;
- (void)setTarget;
- (void)setLabelTag:(int)tag;
- (void)setTitle:(NSString*)titleLabel;

@end

@interface Slider (){
    float _value;
}

@property (nonatomic, assign) NSString* title;
@property (nonatomic, assign) float value;
@property (nonatomic, assign) int labelTag;
@property (nonatomic, readonly) UISlider* slider;

@end

//============================================================================================================
//  FormCombobox
//============================================================================================================

@interface FormCombobox : RowElement

@property (nonatomic, strong) NSArray* options;
@property (nonatomic, strong) NSString* labelTextValue;
@property (nonatomic, strong) UIColor* labelTextColor;
@property (nonatomic, strong) UIFont* labelTextFont;
@property (nonatomic, assign) UIControlContentHorizontalAlignment labelTextAlignment;

@end

//-------------------------------------------------------
//  FormSelect
//-------------------------------------------------------

@interface Select : UIButton

- (NSString*)selectedOption;
- (NSString*)optionIDforSelectedItem;
- (void)setOptions:(NSArray*)options;

@end

@interface Select ()<UIActionSheetDelegate>{
    NSInteger _selectedIndex;
}

@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSArray* options;
@property (nonatomic, strong) NSArray* optionIDs;
@property (nonatomic, readwrite) NSInteger selectedIndex;
@property (nonatomic, readonly) UIActionSheet* actionSheet;

@end

//============================================================================================================
//  FormSubmit
//============================================================================================================

@interface FormSubmit : RowElement

@property (nonatomic, strong) NSString* labelTextValue;
@property (nonatomic, strong) UIColor* labelTextColor;
@property (nonatomic, strong) UIFont* labelTextFont;
@property (nonatomic, assign) UIControlContentHorizontalAlignment labelTextAlignment;

@end















