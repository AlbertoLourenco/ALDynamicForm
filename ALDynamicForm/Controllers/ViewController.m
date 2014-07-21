//
//  ViewController.m
//  ALDynamicForm
//
//  Created by Alberto Lourenco on 7/20/14.
//  Copyright (c) 2014 Alberto Lourenço. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@end

@implementation ViewController

//------------------------------------------------------------------------------------------------------
//  UIViewController
//------------------------------------------------------------------------------------------------------

- (void)viewDidLoad{
    [super viewDidLoad];
    
    //------------------------------------
    // Create and generate the FORM
    //------------------------------------
    
    /*
     *   NOTE 01: create the FORM var on interface. If you don't create the app will crash when keyboard appears.
     *   More details (See the explanation): http://stackoverflow.com/questions/4986587/uitextview-delegate-class-crashes-on-clicking-the-textview-whats-going-on
     *
     *   NOTE 02: add the NSNotificationCenter Observer to get the form values when submited
     */
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doSomethignWhenFormSubmit:)
                                                 name:ALDynamicForm_NotificationSubmitForm
                                               object:nil];
    
    self.formFrame = CGRectMake(10, 80, [[UIScreen mainScreen] bounds].size.width - ALDynamicForm_ElementDefaultPadding, [[UIScreen mainScreen] bounds].size.height - 40 /*status bar and label height*/);
    self.form = [[ALDynamicForm alloc] initWithFrame:self.formFrame andElements:[self createFormElements] onView:self.view];
}

- (void)viewWillDisappear:(BOOL)animated{
    [self.form removeFromSuperView];
}

//------------------------------------------------------------------------------------------------------
//  ALDynamicForm
//------------------------------------------------------------------------------------------------------

- (NSMutableArray*)createFormElements{
    
    //------------------------------------
    // Create elements of your form
    //------------------------------------
    
    FormInput* element                  = [[FormInput alloc] init];
    element.fieldName                   = @"user_name";
    element.maskFilter                  = nil;
    element.placeholderText             = @"Name";
    element.placeholderColor            = [UIColor lightGrayColor];
    element.width                       = self.formFrame.size.width - ALDynamicForm_ElementDefaultPadding;
    element.height                      = 50.0f;
    element.padding                     = 20.0f;
    element.marginTop                   = 1.0f;
    element.marginBottom                = 0.0f;
    element.textColor                   = [UIColor darkGrayColor];
    element.textFont                    = [UIFont fontWithName:@"Arial" size:14.0];
    element.borderStyle                 = UITextBorderStyleNone;
    element.inputType                   = InputType_KeyboardNormal;
    element.backgroundImage             = nil;
    element.backgroundColor             = [UIColor whiteColor];
    
    FormInput* element_00               = [[FormInput alloc] init];
    element_00.fieldName                = @"user_born_date";
    element_00.maskFilter               = @"##/##/####";
    element_00.placeholderText          = @"Born date";
    element_00.placeholderColor         = [UIColor lightGrayColor];
    element_00.width                    = self.formFrame.size.width - ALDynamicForm_ElementDefaultPadding;
    element_00.height                   = 50.0f;
    element_00.padding                  = 20.0f;
    element_00.marginTop                = 1.0f;
    element_00.marginBottom             = 0.0f;
    element_00.textColor                = [UIColor darkGrayColor];
    element_00.textFont                 = [UIFont fontWithName:@"Arial" size:14.0];
    element_00.borderStyle              = UITextBorderStyleNone;
    element_00.inputType                = InputType_Date;
    element_00.backgroundImage          = nil;
    element_00.backgroundColor          = [UIColor whiteColor];
    
    FormInput* element_01               = [[FormInput alloc] init];
    element_01.fieldName                = @"user_phone";
    element_01.maskFilter               = @"(##) #### - ####";
    element_01.placeholderText          = @"Phone number";
    element_01.placeholderColor         = [UIColor lightGrayColor];
    element_01.width                    = self.formFrame.size.width - ALDynamicForm_ElementDefaultPadding;
    element_01.height                   = 50.0f;
    element_01.padding                  = 20.0f;
    element_01.marginTop                = 1.0f;
    element_01.marginBottom             = 0.0f;
    element_01.textColor                = [UIColor darkGrayColor];
    element_01.textFont                 = [UIFont fontWithName:@"Arial" size:14.0];
    element_01.borderStyle              = UITextBorderStyleNone;
    element_01.inputType                = InputType_KeyboardNumbers;
    element_01.backgroundImage          = nil;
    element_01.backgroundColor          = [UIColor whiteColor];
    
    FormSwitch* element_02              = [[FormSwitch alloc] init];
    element_02.fieldName                = @"user_active";
    element_02.width                    = self.formFrame.size.width - ALDynamicForm_ElementDefaultPadding;
    element_02.height                   = element_01.height;
    element_02.padding                  = element_01.padding;
    element_02.marginTop                = 10.0f;
    element_02.marginBottom             = 0.0f;
    element_02.labelTextValue           = @"User active?";
    element_02.labelTextColor           = [UIColor darkGrayColor];
    element_02.labelTextFont            = [UIFont fontWithName:@"Arial" size:14.0];
    element_02.backgroundImage          = nil;
    element_02.backgroundColor          = [UIColor whiteColor];
    
    FormCombobox* element_03            = [[FormCombobox alloc] init];
    element_03.fieldName                = @"user_relationship_status";
    element_03.width                    = self.formFrame.size.width - ALDynamicForm_ElementDefaultPadding;
    element_03.height                   = element_01.height;
    element_03.padding                  = element_01.padding;
    element_03.marginTop                = 10.0f;
    element_03.marginBottom             = 0.0f;
    element_03.labelTextValue           = @"Relationship";
    element_03.labelTextColor           = [UIColor darkGrayColor];
    element_03.labelTextFont            = [UIFont fontWithName:@"Arial" size:14.0];
    element_03.backgroundImage          = [UIImage imageNamed:@"bg_combobox"];
    element_03.backgroundColor          = nil;
    element_03.options                  = @[@"Single", @"Married", @"Dirvorced", @"Widowed"];
    element_03.labelTextAlignment       = UIControlContentHorizontalAlignmentLeft;
    
    FormCombobox* element_04            = [[FormCombobox alloc] init];
    element_04.fieldName                = @"user_vehicle";
    element_04.width                    = self.formFrame.size.width - ALDynamicForm_ElementDefaultPadding;
    element_04.height                   = element_01.height;
    element_04.padding                  = element_01.padding;
    element_04.marginTop                = 1.0f;
    element_04.marginBottom             = 0.0f;
    element_04.labelTextValue           = @"Vehicle";
    element_04.labelTextColor           = [UIColor darkGrayColor];
    element_04.labelTextFont            = [UIFont fontWithName:@"Arial" size:14.0];
    element_04.backgroundImage          = [UIImage imageNamed:@"bg_combobox"];
    element_04.backgroundColor          = nil;
    element_04.options                  = @[@"Car", @"Motorcycle", @"Bus", @"Sandal"];
    element_04.labelTextAlignment       = UIControlContentHorizontalAlignmentLeft;
    
    FormCombobox* element_05            = [[FormCombobox alloc] init];
    element_05.fieldName                = @"user_blood_type";
    element_05.width                    = self.formFrame.size.width - ALDynamicForm_ElementDefaultPadding;
    element_05.height                   = element_01.height;
    element_05.padding                  = element_01.padding;
    element_05.marginTop                = 1.0f;
    element_05.marginBottom             = 0.0f;
    element_05.labelTextValue           = @"Blood type";
    element_05.labelTextColor           = [UIColor darkGrayColor];
    element_05.labelTextFont            = [UIFont fontWithName:@"Arial" size:14.0];
    element_05.backgroundImage          = [UIImage imageNamed:@"bg_combobox"];
    element_05.backgroundColor          = nil;
    element_05.options                  = @[@"A", @"B", @"O-", @"O+"];
    element_05.labelTextAlignment       = UIControlContentHorizontalAlignmentLeft;
    
    FormSlider* element_06              = [[FormSlider alloc] init];
    element_06.fieldName                = @"user_age";
    element_06.width                    = self.formFrame.size.width - ALDynamicForm_ElementDefaultPadding;
    element_06.height                   = 70.0f;
    element_06.padding                  = element_01.padding;
    element_06.marginTop                = 1.0f;
    element_06.marginBottom             = 0.0f;
    element_06.minimumValue             = 18;
    element_06.maximumValue             = 80;
    element_06.labelTextValue           = @"Age";
    element_06.labelTextColor           = [UIColor darkGrayColor];
    element_06.labelTextFont            = [UIFont fontWithName:@"Arial" size:14.0];
    element_06.backgroundImage          = nil;
    element_06.backgroundColor          = [UIColor whiteColor];
    element_06.backgroundContentMode    = UIViewContentModeScaleAspectFit;
    
    FormTextArea* element_07            = [[FormTextArea alloc] init];
    element_07.fieldName                = @"user_description";
    element_07.width                    = self.formFrame.size.width - ALDynamicForm_ElementDefaultPadding;
    element_07.height                   = 120.0f;
    element_07.padding                  = 0;
    element_07.marginTop                = 1.0f;
    element_07.marginBottom             = 1.0f;
    element_07.placeholderText          = @"Description";
    element_07.placeholderColor         = [UIColor lightGrayColor];
    element_07.textFont                 = [UIFont fontWithName:@"Arial" size:14.0];
    element_07.textColor                = [UIColor darkGrayColor];
    element_07.backgroundImage          = nil;
    element_07.backgroundColor          = [UIColor whiteColor];
    
    FormSubmit* element_08              = [[FormSubmit alloc] init];
    element_08.fieldName                = @"";
    element_08.width                    = self.formFrame.size.width - ALDynamicForm_ElementDefaultPadding;
    element_08.height                   = 50.0f;
    element_08.padding                  = 0;
    element_08.marginTop                = 10.0f;
    element_08.marginBottom             = 10.0f;
    element_08.labelTextValue           = @"Send";
    element_08.labelTextColor           = [UIColor whiteColor];
    element_08.labelTextFont            = [UIFont fontWithName:@"Arial" size:18.0f];
    element_08.backgroundImage          = [UIImage imageNamed:@"bg_submit"];
    element_08.backgroundColor          = nil;
    element_08.labelTextAlignment       = UIControlContentHorizontalAlignmentCenter;
    
    //------------------------------------
    // Put elements on array
    //------------------------------------
    
    NSMutableArray* formElements = [[NSMutableArray alloc] init];
    [formElements addObject:element];
    [formElements addObject:element_00];
    [formElements addObject:element_01];
    [formElements addObject:element_02];
    [formElements addObject:element_03];
    [formElements addObject:element_04];
    [formElements addObject:element_05];
    [formElements addObject:element_06];
    [formElements addObject:element_07];
    [formElements addObject:element_08];
    
    return formElements;
}

- (void)doSomethignWhenFormSubmit:(NSNotification*)notification{
    NSMutableDictionary* formValues = (NSMutableDictionary*)[notification object];
    
    [[[UIAlertView alloc] initWithTitle:@"Do all you want now! ;)"
                                message:[formValues description]
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}


@end
