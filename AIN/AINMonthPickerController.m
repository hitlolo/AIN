//
//  AINMonthPickerController.m
//  AIN
//
//  Created by Lolo on 16/6/15.
//  Copyright © 2016年 Lolo. All rights reserved.
//

#import "AINMonthPickerController.h"


#define YearComponent 0
#define MonthComponent 1


@interface AINMonthPickerController ()
<UIPickerViewDelegate,UIPickerViewDataSource>
@property (strong, nonatomic) IBOutlet UIPickerView *datePicker;
@property (strong, nonatomic) IBOutlet UIButton *confirmButton;


@property (assign, nonatomic) NSInteger year;
@property (assign, nonatomic) NSInteger month;

@property (assign, nonatomic) NSInteger monthCountForCurrentYear;
@property (assign, nonatomic) NSInteger monthCountFor2012;
@property (assign, nonatomic) NSInteger monthCountForDefault;


@property(nonatomic, copy,readwrite)NSString* selectedDate;
@end

@implementation AINMonthPickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self prepare];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.popoverPresentationController.passthroughViews = nil;
}

- (void)prepare{
    
    self.confirmButton.layer.borderWidth = 1.0f;
    self.confirmButton.layer.borderColor = self.confirmButton.tintColor.CGColor;
    self.confirmButton.layer.cornerRadius = 3.0f;
    self.confirmButton.layer.masksToBounds = YES;
    
    self.datePicker.dataSource = self;
    self.datePicker.delegate = self;
    self.selectedDate = nil;
    [self prepareData];
    
}

- (void)prepareData{
    
    //first serial is 2012-10
    NSString* yearInString = [HITDateHelper getCurrentYear];
    NSInteger yearInInteger = [yearInString integerValue];
    self.year = yearInInteger;
    
     //2012-10
    NSString* monthCount = [HITDateHelper getCurrentMonth];
    self.monthCountForCurrentYear = [monthCount integerValue];
    self.monthCountFor2012 = 10;
    self.monthCountForDefault = 12;
    
    self.month = self.monthCountForCurrentYear;
}

- (NSInteger)yearCount{
    return self.year - [self columnStartYear] + 1;
}

-(NSInteger)columnStartYear{
    return [self.datasource columnFirstYear];
}

#pragma mark - PickerView datasource & delegate


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (component == YearComponent) {
        return [self yearCount];
    }
    else{
        return self.month;
    }
};



- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 30.0f;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    if (component == YearComponent) {
        return 120;
    }
    else
        return 60;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (component == YearComponent) {
        return [NSString stringWithFormat:@"%d年",self.year - row ];
    }
    else{
        return [NSString stringWithFormat:@"%d月",row + 1];
    }
}

- (UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    UILabel* labelView = nil;
    if (view != nil) {
        labelView = (UILabel*)view;
    }
    else{
        labelView = [UILabel new];
        labelView.textAlignment = NSTextAlignmentCenter;
        labelView.font = DefaultSystemFont(20);
    }
    
    if (component == YearComponent) {
        labelView.text = [NSString stringWithFormat:@"%d年",self.year - row ];
    }
    else{
        labelView.text = [NSString stringWithFormat:@"%d月",self.month - row];
    }
    return labelView;
    
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    if (component == YearComponent) {
        //current
        if (row == 0) {
            self.month = self.monthCountForCurrentYear;
            [pickerView reloadComponent:MonthComponent];
            [pickerView selectRow:0 inComponent:MonthComponent animated:YES];
        }
        //2012
        else if (row == [self yearCount] -1){
            self.month = self.monthCountFor2012;
            [pickerView reloadComponent:MonthComponent];
            [pickerView selectRow:0 inComponent:MonthComponent animated:YES];
        }
        //other years excpet current and 2012
        else{
            self.month = self.monthCountForDefault;
            [pickerView reloadComponent:MonthComponent];
            [pickerView selectRow:0 inComponent:MonthComponent animated:YES];
        }
    }
}

- (IBAction)confirmButtonClicked:(id)sender {
    
    NSInteger yearRow = [self.datePicker selectedRowInComponent:YearComponent];
    NSInteger monthRow = [self.datePicker selectedRowInComponent:MonthComponent];
    NSInteger selectedYear = self.year - yearRow;
    NSInteger selectedMonth = self.month - monthRow;
    NSString* dateString = [NSString stringWithFormat:@"%d-%d",selectedYear,selectedMonth];
    
    self.selectedDate = dateString;
    
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        [self.delegate monthPickerController:self didSelectedDate:self.selectedDate];

    }];
    
    
}


- (CGSize)preferredContentSize{
    CGSize size  = CGSizeZero;
    size.width = self.screenSize.width;
    size.height = 200;
    return size;
}

@end
