//
//  ViewController.m
//  GoogleLatLng
//
//  Created by Stronger Shen on 2014/5/27.
//  Copyright (c) 2014年 MobileIT. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "ViewController.h"
#import "ListsTableViewController.h"

#define isIOS7 [[[UIDevice currentDevice] systemVersion] floatValue]>=7.0
#define RegionMeter 250.0

@interface ViewController () <MKMapViewDelegate>
{
    NSDictionary *dictGoogleMap;
}
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *LatLng;

@end

@implementation ViewController

-(void)foundTap:(UITapGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:self.mapView];
    CLLocationCoordinate2D tapPoint = [self.mapView convertPoint:point toCoordinateFromView:self.view];
    
    MKPointAnnotation *point1 = [[MKPointAnnotation alloc] init];
    point1.coordinate = tapPoint;
    [self.mapView addAnnotation:point1];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (isIOS7 && (screenBounds.size.height==568)) {
        tapPoint.latitude -= 0.0003;    // For 4-inch, iOS 7.1
    } else if (isIOS7 && (screenBounds.size.height==480)) {
        tapPoint.latitude += 0.0001;    // For 3.5-inch, iOS 7.1
    }
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(tapPoint, RegionMeter, RegionMeter);
    [self.mapView setRegion:viewRegion animated:YES];

}


- (void)GetAddress {
    NSString *latlng = self.LatLng.text;
    NSString *urlString=[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%@&sensor=true", latlng];
    
    // Prepare NSURL
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:60.0];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ([data length]>0 && error==nil) {
                                   //確定資料完整接收完成，而且沒有錯誤
                                   
                                   dictGoogleMap = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                                   
                                   //如果要在 View 顯示，需要 dispatch 到主 queue
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       //                                       NSLog(@"%@", [NSString stringWithFormat:@"%@", dictGoogleMap]);
                                       //                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Download" message:@"OK to get Address" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                                       //                                       [alert show];
                                   });
                               } else if ([data length]==0 && error==nil) {
                                   //沒有接收到資料，連線也沒有錯誤
                                   
                                   NSLog(@"Nothing to download");
                               } else if (error != nil) {
                                   //有連線錯誤
                                   
                                   NSLog(@"Error: %@", error);
                               }
                           }];
}


#pragma mark - View

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    CLLocationCoordinate2D location;
    
    //中壢市火車站 24.953634, 121.225647
    location.latitude = 24.953634;
    location.longitude = 121.225647;
    
    //設定地圖可見範圍。以「中壢市火車站」為中心
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(location, RegionMeter, RegionMeter);
    [self.mapView setRegion:viewRegion];
    
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(foundTap:)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.numberOfTouchesRequired = 1;
    [self.mapView addGestureRecognizer:tapRecognizer];
    
//    [self mapView:self.mapView regionDidChangeAnimated:YES];
    [self GetAddress];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    //取得目前 MAP 的中心點座標並 show 在對應的 TextField 中
    double latitude  = self.mapView.centerCoordinate.latitude;
    double longitude = self.mapView.centerCoordinate.longitude;

    self.LatLng.text = [NSString stringWithFormat:@"%6f,%6f", latitude, longitude];
    
    [self GetAddress];
}

- (IBAction)GetAddressAction:(id)sender {
/*
    NSString *latlng = self.LatLng.text;
    NSString *urlString=[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%@&sensor=true", latlng];
    
    // Prepare NSURL
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:60.0];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ([data length]>0 && error==nil) {
                                   //確定資料完整接收完成，而且沒有錯誤
                                   
                                   dictGoogleMap = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                                   
                                   //如果要在 View 顯示，需要 dispatch 到主 queue
                                   dispatch_async(dispatch_get_main_queue(), ^{
//                                       NSLog(@"%@", [NSString stringWithFormat:@"%@", dictGoogleMap]);
//                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Download" message:@"OK to get Address" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//                                       [alert show];
                                   });
                               } else if ([data length]==0 && error==nil) {
                                   //沒有接收到資料，連線也沒有錯誤
                                   
                                   NSLog(@"Nothing to download");
                               } else if (error != nil) {
                                   //有連線錯誤
                                   
                                   NSLog(@"Error: %@", error);
                               }
                           }];

*/
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ListsTableViewController *lvc = segue.destinationViewController;
    lvc.dictResult = dictGoogleMap;
}


@end
