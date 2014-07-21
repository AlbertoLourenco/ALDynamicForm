  ALDynamicForm - iOS
---------------

![ALDynamicForm v1.0](http://albertolourenco.com.br/github.png)

A powerful dynamic form for Objective-C (iOS).
With this lib you can create a dynamic custom forms. See the references:

Create something objects, add in array and generate your dynamic custom form.

- FormInput
- FormSwitch
- FormSlider
- FormCombobox
- FormTextArea
- FormSubmit

#Config the form:
    
    ----------------------------------------------------------------------------------------
    UIViewController.h
    ----------------------------------------------------------------------------------------
    
    @property(nonatomic, strong) ALDynamicForm* form;
    @property(nonatomic, assign) CGRect formFrame;

    ----------------------------------------------------------------------------------------
    UIViewController.m - viewDidLoad()
    ----------------------------------------------------------------------------------------
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doSomethignWhenFormSubmit:)
                                                 name:ALDynamicForm_NotificationSubmitForm
                                               object:nil];
    
    self.formFrame = CGRectMake(10, 30, [[UIScreen mainScreen] bounds].size.width - ALDynamicForm_ElementDefaultPadding,     [[UIScreen mainScreen] bounds].size.height - 40 /*status bar and label height*/);
    self.form = [[ALDynamicForm alloc] initWithFrame:self.formFrame andElements:[self createFormElements] onView:self.view];


#Creating elements:

    ----------------------------------------------------------------------------------------
    UIViewController.m - createFormElements()
    ----------------------------------------------------------------------------------------
    
    FormInput* element_01               = [[FormInput alloc] init];
    element_01.fieldName                = @"user_phone";
    element_01.maskFilter               = @"+## (##) #### - ####";
    element_01.placeholderText          = @"Phone number";
    element_01.placeholderColor         = [UIColor lightGrayColor];
    element_01.width                    = self.formFrame.size.width - ALDynamicForm_ElementDefaultPadding;
    element_01.height                   = 50.0f;
    element_01.padding                  = 20.0f;
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
    element_03.labelTextValue           = @"Relationship";
    element_03.labelTextColor           = [UIColor darkGrayColor];
    element_03.labelTextFont            = [UIFont fontWithName:@"Arial" size:14.0];
    element_03.backgroundImage          = [UIImage imageNamed:@"bg_combobox"];
    element_03.backgroundColor          = nil;
    element_03.options                  = @[@"Single", @"Married", @"Dirvorced", @"Widowed"];
    element_03.labelTextAlignment       = UIControlContentHorizontalAlignmentLeft;
    
    FormSubmit* element_04              = [[FormSubmit alloc] init];
    element_04.fieldName                = @"";
    element_04.width                    = self.formFrame.size.width - ALDynamicForm_ElementDefaultPadding;
    element_04.height                   = 50.0f;
    element_04.padding                  = 0;
    element_04.labelTextValue           = @"Send";
    element_04.labelTextColor           = [UIColor whiteColor];
    element_04.labelTextFont            = [UIFont fontWithName:@"Arial" size:18.0f];
    element_04.backgroundImage          = [UIImage imageNamed:@"bg_submit"];
    element_04.backgroundColor          = nil;
    element_04.labelTextAlignment       = UIControlContentHorizontalAlignmentCenter;
    
#Adding elements on array:

    ----------------------------------------------------------------------------------------
    UIViewController.m - createFormElements()
    ----------------------------------------------------------------------------------------
    
    NSMutableArray* formElements = [[NSMutableArray alloc] init];
    [formElements addObject:element_01];
    [formElements addObject:element_02];
    [formElements addObject:element_03];
    [formElements addObject:element_04];
    return formElements;
    
#Get form values
    
    ----------------------------------------------------------------------------------------
    UIViewController.m - doSomethignWhenFormSubmit()
    ----------------------------------------------------------------------------------------
    
    NSMutableDictionary* formValues = (NSMutableDictionary*)[notification object];
    
    [[[UIAlertView alloc] initWithTitle:@"Do all you want now! ;)"
                                message:[formValues description]
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];

See the object attributes on example project.

*   NOTE 01: create the FORM var on interface (YOUR_CLASS.h). If you don't create the app will crash when keyboard appears.
*   NOTE 02: add the NSNotificationCenter Observer to get the form values when submited
