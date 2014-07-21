//
//  ALDynamicForm.m
//  ALDynamicForm
//
//  Created by Alberto Lourenco on 7/20/14.
//  Copyright (c) 2014 Alberto Lourenço. All rights reserved.
//

#import "ALDynamicForm.h"

static NSMutableArray* elements;
static UIView* superView;
static CGRect formFrame;
static int elementTag = 1;
static float lastOriginY = 0.0f;
static float formRowHeight = 0.0f;
static float formScrolContentInsetHeight = 0.0f;
static float keyboardHeight = 0.0f;
static BOOL isTextView = NO;
static UITextView* activeTextView = nil;

//===================================================================================================
//  Form
//===================================================================================================

@interface ALDynamicForm (){
    __weak UITextField* activeInput;
    BOOL showingKeyboard;
}
@end

@implementation ALDynamicForm

//--------------------------------------------------------------------------------
//  Form Defaults
//--------------------------------------------------------------------------------

- (id)initWithFrame:(CGRect)frame andElements:(NSMutableArray*)elementsArray onView:(UIView*)view{
    
    formFrame = frame;
    
    superView = view;
    [superView addSubview:[self generateForm:elementsArray]];
    
    return [self init];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidBeginEditingNotification:)
                                                 name:UITextFieldTextDidBeginEditingNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    UITapGestureRecognizer* tapToHideKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.scroll addGestureRecognizer:tapToHideKeyboard];
    [self.view addGestureRecognizer:tapToHideKeyboard];
    [superView addGestureRecognizer:tapToHideKeyboard];
    
    [self.scroll.viewForBaselineLayout setBackgroundColor:nil];
    [self.view setBackgroundColor:nil];
}

- (void)removeFromSuperView{
    elements = nil;
    superView = nil;
    formFrame = CGRectZero;
    elementTag = 1;
    lastOriginY = 0.0f;
    formRowHeight = 0.0f;
    formScrolContentInsetHeight = 0.0f;
    keyboardHeight = 0.0f;
    isTextView = NO;
    activeTextView = nil;
}

- (UIView*)generateForm:(NSMutableArray*)elementsArray{
    
    elements = [[NSMutableArray alloc] init];
    elements = [elementsArray copy];
    
    self.scroll = [[UIScrollView alloc] init];
    
    [self.scroll setShowsVerticalScrollIndicator:ALDynamicForm_FormShowScrollVertical];
    [self.scroll setShowsHorizontalScrollIndicator:ALDynamicForm_FormShowScrollHorizontal];
    
    for (id element in elementsArray) {
        
        //---------------
        //  UITextField
        //---------------
        if ([element isKindOfClass:[FormInput class]]) {
            [self addInput:element toView:self.scroll];
        }
        
        //---------------
        //  UITextView
        //---------------
        if ([element isKindOfClass:[FormTextArea class]]) {
            [self addTextArea:element toView:self.scroll];
        }
        
        //---------------
        //  UISwitch
        //---------------
        if ([element isKindOfClass:[FormSwitch class]]) {
            [self addSwitch:element toView:self.scroll];
        }
        
        //---------------
        //  UISlider
        //---------------
        if ([element isKindOfClass:[FormSlider class]]) {
            [self addSlider:element toView:self.scroll];
        }
        
        //---------------
        //  Combobox
        //---------------
        if ([element isKindOfClass:[FormCombobox class]]) {
            [self addCombobox:element toView:self.scroll];
        }
        
        //---------------
        //  Submit
        //---------------
        if ([element isKindOfClass:[FormSubmit class]]) {
            [self addSubmit:element toView:self.scroll];
        }
        
        [self.scroll setContentSize:CGSizeMake(self.scroll.frame.size.width, lastOriginY + formRowHeight)];
    }
    
    [self.view setFrame:formFrame];
    [self.view addSubview:self.scroll];
    
    [self.scroll setFrame:[self.view bounds]];
    formScrolContentInsetHeight = self.scroll.contentSize.height;
    
    return self.view;
}

//--------------------------------------------------------------------------------
//  UITextField
//--------------------------------------------------------------------------------

- (void)addInput:(FormInput*)object toView:(UIScrollView*)scrollView{
    
    UIImageView* background = [[UIImageView alloc] initWithFrame:CGRectMake(0, lastOriginY + object.marginTop, object.width, object.height)];
    [background setImage:object.backgroundImage];
    [background setBackgroundColor:object.backgroundColor];
    [background setContentMode:UIViewContentModeScaleAspectFit];
    [background setUserInteractionEnabled:YES];
    
    float elementPositionX = (object.padding / 2 + (formFrame.size.width - object.width) / 2) - ALDynamicForm_ElementDefaultPadding / 2;
    
    if (!object.borderStyle && !object.backgroundImage && !object.backgroundColor) {
        object.borderStyle = UITextBorderStyleRoundedRect;
    }
    
    if (!object.placeholderText) {
        object.placeholderText = ALDynamicForm_ElementPlaceholderDefaultValue;
    }
    
    Input* element = [[Input alloc] init];
    [element setDelegate:self];
    [element setFrame:CGRectMake(elementPositionX, 0, object.width - object.padding, object.height)];
    [element setPlaceholder:object.placeholderText];
    [element setBorderStyle:object.borderStyle];
    [element setTag:elementTag];
    [element setTextColor:object.textColor];
    [element setFont:object.textFont];
    [element setMaskFilter:object.maskFilter];
    [element setInputType:object.inputType];
    
    if (object.inputType == InputType_Date) {
        [element setKeyboardType:UIKeyboardTypeNumberPad];
    }else{
        [element setKeyboardType:(UIKeyboardType)object.inputType];
    }
    
    if (object.placeholderColor) {
        if ([element respondsToSelector:@selector(setAttributedPlaceholder:)]) {
            element.attributedPlaceholder = [[NSAttributedString alloc] initWithString:object.placeholderText attributes:@{NSForegroundColorAttributeName: object.placeholderColor}];
        } else {
            NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        }
    }
    
    [background addSubview:element];
    [background sendSubviewToBack:element];
    
    lastOriginY += object.marginTop + object.height + object.marginBottom;
    formRowHeight = object.height;
    elementTag++;
    
    [scrollView addSubview:background];
}

//--------------------------------------------------------------------------------
//  UITextView
//--------------------------------------------------------------------------------

- (void)addTextArea:(FormTextArea*)object toView:(UIScrollView*)scrollView{
    
    UIImageView* background = [[UIImageView alloc] initWithFrame:CGRectMake(0, lastOriginY + object.marginTop, object.width, object.height)];
    [background setImage:object.backgroundImage];
    [background setBackgroundColor:object.backgroundColor];
    [background setContentMode:UIViewContentModeScaleAspectFit];
    [background setUserInteractionEnabled:YES];
    
    if (!object.placeholderText) {
        object.placeholderText = ALDynamicForm_ElementPlaceholderDefaultValue;
    }
    
    float elementPositionX = (object.padding / 2 + (formFrame.size.width - object.width) / 2);
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(elementPositionX + (ALDynamicForm_ElementDefaultTextViewPadding / 2),
                                                               ALDynamicForm_ElementDefaultTextViewPadding + 2.5f,
                                                               object.width - object.padding + ALDynamicForm_ElementDefaultTextViewPadding,
                                                               object.textFont.capHeight + 5)];
    [label setTextColor:object.placeholderColor];
    [label setText:object.placeholderText];
    [label setFont:object.textFont];
    [label setTag:elementTag];
    
    UITextView* element = [[UITextView alloc] init];
    [element setFrame:CGRectMake(elementPositionX,
                                 (ALDynamicForm_ElementDefaultTextViewPadding / 2),
                                 object.width - object.padding - ALDynamicForm_ElementDefaultTextViewPadding,
                                 object.height - ALDynamicForm_ElementDefaultTextViewPadding)];
    [element setDelegate:self];
    [element setTag:elementTag];
    [element setTextColor:object.textColor];
    [element setFont:object.textFont];
    
    [background addSubview:label];
    [background sendSubviewToBack:label];
    
    [background addSubview:element];
    [background sendSubviewToBack:element];
    
    lastOriginY += object.marginTop + object.height + object.marginBottom;
    formRowHeight = object.height;
    elementTag++;
    
    [scrollView addSubview:background];
}

//--------------------------------------------------------------------------------
//  UISwitch
//--------------------------------------------------------------------------------

- (void)addSwitch:(FormSwitch*)object toView:(UIScrollView*)scrollView{
    
    UIImageView* background = [[UIImageView alloc] initWithFrame:CGRectMake(0, lastOriginY + object.marginTop, object.width, object.height)];
    [background setImage:object.backgroundImage];
    [background setBackgroundColor:object.backgroundColor];
    [background setContentMode:UIViewContentModeScaleAspectFit];
    [background setUserInteractionEnabled:YES];
    
    float elementPositionX = (object.padding / 2 + (formFrame.size.width - object.width) / 2) - ALDynamicForm_ElementDefaultPadding / 2;
    float labelWidth = (((object.width - object.padding) - 10.f /* Space */) - 51.0f /* iOS 7 - UISwitch default width size */);
    
    if (!object.labelTextValue) {
        object.labelTextValue = @"Undefined";
        object.labelTextColor = [UIColor redColor];
    }
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(elementPositionX, 0, labelWidth, object.height)];
    [label setTextColor:object.labelTextColor];
    [label setText:object.labelTextValue];
    [label setFont:object.labelTextFont];
    [background addSubview:label];
    
    UISwitch* element = [[UISwitch alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label.frame) + 10.0f, 10, 0, 0)];
    [element setTag:elementTag];
    [background addSubview:element];
    
    lastOriginY += object.marginTop + object.height + object.marginBottom;
    formRowHeight = object.height;
    elementTag++;
    
    [scrollView addSubview:background];
}

//--------------------------------------------------------------------------------
//  UISlider
//--------------------------------------------------------------------------------

- (void)addSlider:(FormSlider*)object toView:(UIScrollView*)scrollView{
    
    UIImageView* background = [[UIImageView alloc] initWithFrame:CGRectMake(0, lastOriginY + object.marginTop, object.width, object.height)];
    [background setImage:object.backgroundImage];
    [background setBackgroundColor:object.backgroundColor];
    [background setContentMode:object.backgroundContentMode];
    [background setUserInteractionEnabled:YES];
    
    float elementPositionX = (object.padding / 2 + (formFrame.size.width - object.width) / 2) - ALDynamicForm_ElementDefaultPadding / 2;
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(elementPositionX, 0, object.width - object.padding, object.height/2)];
    [label setTextColor:object.labelTextColor];
    [label setText:[NSString stringWithFormat:@"%@: %i", object.labelTextValue, (int)object.minimumValue]];
    [label setFont:object.labelTextFont];
    [label setTag:elementTag];
    [background addSubview:label];
    
    if (!object.minimumValue) {
        object.minimumValue = 0;
    }
    
    if (!object.maximumValue) {
        object.maximumValue = 0;
    }
    
    Slider* element = [[Slider alloc] initWithFrame:CGRectMake(elementPositionX, CGRectGetMaxY(label.frame) + 8.0, object.width - object.padding, 10)];
    [element setMinimumValue:object.minimumValue];
    [element setMaximumValue:object.maximumValue];
    [element setContinuous:YES];
    [element setTarget];
    [element setTitle:object.labelTextValue];
    [element setLabelTag:elementTag];
    
    elementTag++;
    
    [element setTag:elementTag];
    [background addSubview:element];
    
    lastOriginY += object.marginTop + object.height + object.marginBottom;
    formRowHeight = object.height;
    elementTag++;
    
    [scrollView addSubview:background];
}

//--------------------------------------------------------------------------------
//  Combobox
//--------------------------------------------------------------------------------

- (void)addCombobox:(FormCombobox*)object toView:(UIScrollView*)scrollView{
    
    UIImageView* background = [[UIImageView alloc] initWithFrame:CGRectMake(0, lastOriginY + object.marginTop, object.width, object.height)];
    [background setImage:object.backgroundImage];
    [background setBackgroundColor:object.backgroundColor];
    [background setContentMode:UIViewContentModeScaleToFill];
    [background setUserInteractionEnabled:YES];
    
    float elementPositionX = (object.padding / 2 + (formFrame.size.width - object.width) / 2) - ALDynamicForm_ElementDefaultPadding / 2;
    
    Select* element = [Select buttonWithType:UIButtonTypeCustom];
    [element setFrame:CGRectMake(elementPositionX, 0, object.width - object.padding, object.height)];
    [element setTitle:object.labelTextValue forState:UIControlStateNormal];
    [element setTitleColor:object.labelTextColor forState:UIControlStateNormal];
    [element.titleLabel setFont:object.labelTextFont];
    [element setTag:elementTag];
    [element setContentHorizontalAlignment:object.labelTextAlignment];
    
    [element setOptionIDs:object.options];
    [element setOptions:object.options];
    
    [background addSubview:element];
    [background sendSubviewToBack:element];
    
    lastOriginY += object.marginTop + object.height + object.marginBottom;
    formRowHeight = object.height;
    elementTag++;
    
    [scrollView addSubview:background];
}

//--------------------------------------------------------------------------------
//  Submit
//--------------------------------------------------------------------------------

- (void)addSubmit:(FormSubmit*)object toView:(UIScrollView*)scrollView{
    
    float elementPositionX = (object.padding / 2 + (formFrame.size.width - object.width) / 2) - ALDynamicForm_ElementDefaultPadding / 2;
    
    UIButton* element = [UIButton buttonWithType:UIButtonTypeCustom];
    [element setFrame:CGRectMake(elementPositionX, lastOriginY + object.marginTop, object.width - object.padding, object.height)];
    [element.titleLabel setFont:object.labelTextFont];
    [element setTitle:object.labelTextValue forState:UIControlStateNormal];
    [element setTitleColor:object.labelTextColor forState:UIControlStateNormal];
    [element setBackgroundImage:object.backgroundImage forState:UIControlStateNormal];
    [element setBackgroundColor:object.backgroundColor];
    [element setContentHorizontalAlignment:object.labelTextAlignment];
    [element setTag:elementTag];
    
    [element addTarget:self action:@selector(getFormValues) forControlEvents:UIControlEventTouchUpInside];
    
    lastOriginY += object.marginTop + object.height + object.marginBottom;
    formRowHeight = object.height;
    elementTag++;
    
    [scrollView addSubview:element];
}

- (void)getFormValues{
    
    [self hideKeyboard];
    
    NSMutableDictionary* formValues = [[NSMutableDictionary alloc] init];
    
    int count = 0;
    for (UIView* sub in [self.scroll subviews]) {
        for (id subview in [sub subviews]) {
            
            //---------------
            //  UITextField
            //---------------
            if ([subview isKindOfClass:[Input class]]) {
                
                Input* element = (Input*)subview;
                FormInput* formInput = [elements objectAtIndex:count];
                
                if([formInput.fieldName length] == 0){
                    formInput.fieldName = [NSString stringWithFormat:@"field_%i", count];
                }
                
                if([element.text length] == 0){
                    element.text = @"";
                }
                
                [formValues setValue:element.text forKey:formInput.fieldName];
            }
            
            //---------------
            //  UITextView
            //---------------
            if ([subview isKindOfClass:[UITextView class]]) {
                
                UITextView* element = (UITextView*)subview;
                FormTextArea* formInput = [elements objectAtIndex:count];
                
                if([formInput.fieldName length] == 0){
                    formInput.fieldName = [NSString stringWithFormat:@"field_%i", count];
                }
                
                if([element.text length] == 0){
                    element.text = @"";
                }
                
                [formValues setValue:element.text forKey:formInput.fieldName];
            }
            
            //---------------
            //  UISwitch
            //---------------
            if ([subview isKindOfClass:[UISwitch class]]) {
                
                UISwitch* element = (UISwitch*)subview;
                FormSwitch* formInput = [elements objectAtIndex:count];
                
                if([formInput.fieldName length] == 0){
                    formInput.fieldName = [NSString stringWithFormat:@"field_%i", count];
                }
                
                NSString* value = @"false";
                if([element isOn]){
                    value = @"true";
                }
                
                [formValues setValue:value forKey:formInput.fieldName];
            }
            
            //---------------
            //  UISlider
            //---------------
            if ([subview isKindOfClass:[Slider class]]) {
                
                Slider* element = (Slider*)subview;
                FormSlider* formInput = [elements objectAtIndex:count];
                
                if([formInput.fieldName length] == 0){
                    formInput.fieldName = [NSString stringWithFormat:@"field_%i", count];
                }
                
                [formValues setValue:[NSString stringWithFormat:@"%i", (int)element.value] forKey:formInput.fieldName];
            }
            
            //---------------
            //  Combobox
            //---------------
            if ([subview isKindOfClass:[Select class]]) {
                
                Select* element = (Select*)subview;
                FormCombobox* formInput = [elements objectAtIndex:count];
                
                if([formInput.fieldName length] == 0){
                    formInput.fieldName = [NSString stringWithFormat:@"field_%i", count];
                }
                
                NSMutableDictionary* comboValues = [[NSMutableDictionary alloc] init];
                [comboValues setObject:[NSString stringWithFormat:@"%i", (int)[element selectedIndex]] forKey:@"index"];
                [comboValues setObject:[element selectedOption] forKey:@"value"];
                
                [formValues setValue:comboValues forKey:formInput.fieldName];
            }
            
        }
        count++;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ALDynamicForm_NotificationSubmitForm object:formValues];
}

//--------------------------------------------------------------------------------
//  Keyboard
//--------------------------------------------------------------------------------

- (void)hideKeyboard{
    for (UIView* sub in [self.scroll subviews]) {
        for (id subview in [sub subviews]) {
            if ([subview isKindOfClass:[Input class]] || [subview isKindOfClass:[UITextView class]]) {
                [subview resignFirstResponder];
            }
        }
    }
}

- (void)keyboardWillShow:(NSNotification*)notification{
    
    keyboardHeight = [[[notification userInfo] valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    showingKeyboard = YES;
    CGRect centeredRect = CGRectZero;
    
    if (isTextView == NO) {
        
        [UIView animateWithDuration:.25
                         animations:^{
                             self.scroll.contentSize = CGSizeMake(self.scroll.frame.size.width, formScrolContentInsetHeight + keyboardHeight);
                         }];
        
        centeredRect = CGRectMake(0,
                                  CGRectGetMaxX(activeInput.frame) + activeInput.frame.size.height,
                                  self.scroll.frame.size.width,
                                  self.scroll.frame.size.height);
    }else{
        
        [UIView animateWithDuration:.25
                         animations:^{
                             self.scroll.contentSize = CGSizeMake(self.scroll.frame.size.width, formScrolContentInsetHeight + keyboardHeight);
                         }];
        
        centeredRect = CGRectMake(0,
                                  CGRectGetMaxX(activeTextView.frame) + activeTextView.frame.size.height,
                                  self.scroll.frame.size.width,
                                  self.scroll.frame.size.height);
    }
    
    [self.scroll scrollRectToVisible:centeredRect animated:YES];
}

- (void)keyboardWillHide{
    
    [self hideKeyboard];
    
    isTextView = NO;
    showingKeyboard = NO;
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.scroll.contentSize = CGSizeMake(self.scroll.frame.size.width, formScrolContentInsetHeight);
                     }];
    
    CGRect centeredRect = CGRectMake(0,
                                     0,
                                     self.scroll.frame.size.width,
                                     self.scroll.frame.size.height);
    [self.scroll scrollRectToVisible:centeredRect animated:YES];
}

- (void)textFieldDidBeginEditingNotification:(NSNotification*)notification{
    Input* formInput = notification.object;
    if (formInput.superview == self.scroll) {
        activeInput = formInput;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    Input* input = (Input*)textField;
    
    if ([input.text length] > 0) {
        if (input.inputType == InputType_Date){
            
            NSString *dateFromTextfield = input.text;
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            
            BOOL flag = FALSE;
            for (NSString* srtDateFormat in ALDynamicForm_ElementInputTypeDateFormats) {
                
                [dateFormat setDateFormat:srtDateFormat];
                NSDate *date = [dateFormat dateFromString:dateFromTextfield];
                
                if (date != nil) {
                    flag = TRUE;
                    break;
                }
            }
            
            if (!flag) {
                [input setText:@""];
                
                if ([input.placeholder rangeOfString:ALDynamicForm_ElementInputTypeDateInvalid].location == NSNotFound) {
                    if ([input respondsToSelector:@selector(setAttributedPlaceholder:)]) {
                        input.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"*%@: %@", input.placeholder, ALDynamicForm_ElementInputTypeDateInvalid]
                                                                                      attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:255.0f/255.0f green:149.0f/255.0f blue:149.0f/255.0f alpha:1.0]}];
                    } else {
                        input.placeholder = [NSString stringWithFormat:@"*%@: %@", input.placeholder, ALDynamicForm_ElementInputTypeDateInvalid];
                    }
                }
            }
            
        }
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    UITextField* nextTextField;
    for (id subview in textField.superview.subviews) {
        if (((UIView*)subview).tag > textField.tag && [subview isKindOfClass:[UITextField class]]) {
            nextTextField = subview;
            break;
        }
    }
    
    if (nextTextField) {
        [nextTextField becomeFirstResponder];
        return NO;
    }
    else{
        [textField resignFirstResponder];
        return YES;
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    
    isTextView = YES;
    showingKeyboard = YES;
    
    activeTextView = textView;
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView{
    BOOL hidePlaceholder = NO;
    if ([textView.text length] > 0) {
        hidePlaceholder = YES;
    }
    
    for (UIView* sub in [self.scroll subviews]) {
        for (id subview in [sub subviews]) {
            if ([subview isKindOfClass:[UILabel class]] && [(UILabel*)subview tag] == textView.tag) {
                [subview setHidden:hidePlaceholder];
            }
        }
    }
}

//--------------------------------------------------------------------------------
//  Mask input text
//  http://stackoverflow.com/questions/7709450/uitextfield-format-in-xx-xx-xxx
//--------------------------------------------------------------------------------

NSMutableString *filteredPhoneStringFromStringWithFilter(NSString *string, NSString *filter){
    
    NSUInteger onOriginal = 0, onFilter = 0, onOutput = 0;
    char outputString[([filter length])];
    BOOL done = NO;
    
    while(onFilter < [filter length] && !done)
    {
        char filterChar = [filter characterAtIndex:onFilter];
        char originalChar = onOriginal >= string.length ? '\0' : [string characterAtIndex:onOriginal];
        switch (filterChar) {
            case '#':
                if(originalChar=='\0')
                {
                    // We have no more input numbers for the filter.  We're done.
                    done = YES;
                    break;
                }
                if(isdigit(originalChar))
                {
                    outputString[onOutput] = originalChar;
                    onOriginal++;
                    onFilter++;
                    onOutput++;
                }
                else
                {
                    onOriginal++;
                }
                break;
            default:
                // Any other character will automatically be inserted for the user as they type (spaces, - etc..) or deleted as they delete if there are more numbers to come.
                outputString[onOutput] = filterChar;
                onOutput++;
                onFilter++;
                if(originalChar == filterChar)
                    onOriginal++;
                break;
        }
    }
    outputString[onOutput] = '\0'; // Cap the output string
    return [NSMutableString stringWithUTF8String:outputString];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    Input* input = (Input*)textField;
    NSString *filter = input.maskFilter;
    
    if(!filter) return YES; // No filter provided, allow anything
    
    NSString *changedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if(range.length == 1 && // Only do for single deletes
       string.length < range.length &&
       [[textField.text substringWithRange:range] rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]].location == NSNotFound)
    {
        // Something was deleted.  Delete past the previous number
        NSInteger location = changedString.length-1;
        if(location > 0)
        {
            for(; location > 0; location--)
            {
                if(isdigit([changedString characterAtIndex:location]))
                {
                    break;
                }
            }
            changedString = [changedString substringToIndex:location];
        }
    }
    
    textField.text = filteredPhoneStringFromStringWithFilter(changedString, filter);
    
    return NO;
}

@end

//-------------------------------------------------------------------------------------------------
//  Input
//-------------------------------------------------------------------------------------------------

@implementation Input
@synthesize inputType, maskFilter;
@end

//-------------------------------------------------------------------------------------------------
//  Select
//-------------------------------------------------------------------------------------------------

@implementation Select

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex >= 0 && buttonIndex < actionSheet.numberOfButtons) {
        _selectedIndex = buttonIndex;
        [self setTitle:[NSString stringWithFormat:@"%@: %@", _title, [actionSheet buttonTitleAtIndex:buttonIndex]] forState:UIControlStateNormal];
    }
}

- (void)showOptions{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UIKeyboardWillHideNotification object:nil];
    
    [_actionSheet showInView:self.superview];
}

- (NSString*)selectedOption{
    return self.titleLabel.text;
}

- (NSString*)optionIDforSelectedItem{
    return [_optionIDs objectAtIndex:_selectedIndex];
}

- (void)setOptions:(NSArray*)options{
    
    _title = self.titleLabel.text;
    
    _options = options;
    _actionSheet = [[UIActionSheet alloc] initWithTitle:_title
                                               delegate:self
                                      cancelButtonTitle:nil
                                 destructiveButtonTitle:nil
                                      otherButtonTitles:nil];
    _actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    
    for (NSString* opt in options) {
        [_actionSheet addButtonWithTitle:opt];
    }
    
    [self addTarget:self action:@selector(showOptions) forControlEvents:UIControlEventTouchUpInside];
}

@end

//-------------------------------------------------------------------------------------------------
//  Slider
//-------------------------------------------------------------------------------------------------
@implementation Slider

- (void)sliderValue:(id)sender{
    _slider = (UISlider*)sender;
    
    for (id subview in [self.superview subviews]) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel* lbl = (UILabel*)subview;
            if (lbl.tag == _labelTag) {
                [lbl setText:[NSString stringWithFormat:@"%@: %i", _title, (int)_slider.value]];
            }
        }
    }
}

- (void)setTarget{
    [self addTarget:self action:@selector(sliderValue:) forControlEvents:UIControlEventValueChanged];
}

- (void)setLabelTag:(int)tag{
    _labelTag = tag;
}

- (void)setTitle:(NSString *)titleLabel{
    _title = titleLabel;
}

@end

//===================================================================================================
//  RowElement
//===================================================================================================

@implementation RowElement

@synthesize fieldName, height, width, padding, marginTop, marginBottom, backgroundImage, backgroundColor;

- (id)init{
    
    fieldName       = @"";
    height          = ALDynamicForm_ElementDefaultHeight;
    width           = ALDynamicForm_ElementDefaultWidth;
    padding         = ALDynamicForm_ElementDefaultPadding;
    marginTop       = ALDynamicForm_ElementDefaultMarginTop;
    marginBottom    = ALDynamicForm_ElementDefaultMarginBottom;
    backgroundImage = nil;
    backgroundColor = nil;
    
    return self;
}

@end

//===================================================================================================
//  FormInput
//===================================================================================================

@implementation FormInput
@synthesize textFont, textColor, placeholderText, placeholderColor, borderStyle, inputType, maskFilter;
@end

//===================================================================================================
//  FormTextArea
//===================================================================================================

@implementation FormTextArea
@synthesize textFont, textColor, placeholderText, placeholderColor;
@end

//===================================================================================================
//  FormSwitch
//===================================================================================================

@implementation FormSwitch
@synthesize labelTextValue, labelTextColor, labelTextFont;
@end

//===================================================================================================
//  FormSlider
//===================================================================================================

@implementation FormSlider
@synthesize minimumValue, maximumValue, labelTextValue, labelTextColor, labelTextFont;
@end

//===================================================================================================
//  FormCombobox
//===================================================================================================

@implementation FormCombobox
@synthesize labelTextValue, labelTextColor, labelTextFont, labelTextAlignment, options;
@end

//===================================================================================================
//  FormSubmit
//===================================================================================================

@implementation FormSubmit
@synthesize labelTextValue, labelTextAlignment, labelTextColor, labelTextFont;
@end


