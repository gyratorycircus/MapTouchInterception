//
//  ViewController.m
//  MapTouchInterception
//

#import "ViewController.h"

@interface Annotation : NSObject <MKAnnotation>
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@end

@implementation Annotation
@end


@interface ViewController ()

@property (nonatomic, strong) MKPolyline *polyline;
@property (nonatomic, strong) id<MKAnnotation> selectedAnnotation;


@property (nonatomic, strong) CLLocation *lax;
@property (nonatomic, strong) CLLocation *jfk;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(handleTap:)];
    [self.mapView addGestureRecognizer:tap];
    [self.mapView addOverlay:self.polyline];
}

- (void)handleTap:(UIGestureRecognizer *)recognizer
{
    NSLog(@"%@", [[self.mapView.subviews.firstObject gestureRecognizers] firstObject]);
    
    // Get the point tapped in the map view from the gesture recognizer.
    CGPoint point = [recognizer locationOfTouch:0 inView:self.mapView];
    
    // Convert the point to a coordinate.
    CLLocationCoordinate2D coord = [self.mapView convertPoint:point
                                         toCoordinateFromView:self.mapView];
    MKMapPoint mapPoint = MKMapPointForCoordinate(coord);
    
    // Use the renderer to determine if the touch was on the polyline.
    MKPolylineRenderer *renderer = (MKPolylineRenderer *)[self.mapView rendererForOverlay:self.polyline];

    // NOTE: The renderer takes the map scale into account and adjusts its drawing accordingly. We need to do the same because our lineWidth is set in single or double-digits to match points against the on-screen map size, but the map itself is measured in millions (i.e. LAX-JFK is 35.4 million MK units). To scale accordingly, take the visible map width and divide it by the map view point width.
    double mapWidth = self.mapView.visibleMapRect.size.width;
    double pointWidth = self.mapView.frame.size.width;
    double scaleFactor = mapWidth / pointWidth;
    CGPathRef stroked = CGPathCreateCopyByStrokingPath(renderer.path, NULL,
                                                       renderer.lineWidth * scaleFactor,
                                                       renderer.lineCap,
                                                       renderer.lineJoin,
                                                       renderer.miterLimit * scaleFactor);
    CGPoint polyPoint = [renderer pointForMapPoint:mapPoint];
    BOOL hitPath = CGPathContainsPoint(stroked, NULL, polyPoint, NO);
    CGPathRelease(stroked);
    
    if (hitPath) {
        // If the touch was on a polyline, add an annotation at the touch location,
        // and also select it to display the callout immediately.
        NSLog(@"Touched Polyline");
        Annotation *annotation = [[Annotation alloc] init];
        annotation.title = @"Title";
        annotation.subtitle = @"Subtitle";
        annotation.coordinate = coord;
        
        // To avoid having the mapView automatically deselect the annotation, we can delay the selection by 0.4 seconds via a dispatch_after, but that is a bit ridiculous, and UX suffers.
        [self.mapView addAnnotation:annotation];
        [self.mapView selectAnnotation:annotation animated:YES];
    }
    else {
        NSLog(@"Missed Polyline");
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    [mapView removeAnnotation:view.annotation];
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (MKPolyline *)polyline
{
    if (!_polyline) {
        // http://nshipster.com/mkgeodesicpolyline/
        self.lax = [[CLLocation alloc] initWithLatitude:33.9424955
                                              longitude:-118.4080684];
        self.jfk = [[CLLocation alloc] initWithLatitude:40.6397511
                                              longitude:-73.7789256];
        
        CLLocationCoordinate2D coordinates[2] = {self.lax.coordinate, self.jfk.coordinate};
        
        _polyline = [MKGeodesicPolyline polylineWithCoordinates:coordinates
                                                  count:2];
    }
    return _polyline;
}


- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.lineCap = kCGLineCapRound;
    renderer.lineWidth = 20.0f;
    renderer.strokeColor = UIColor.redColor;
    renderer.fillColor = UIColor.blueColor;
    return renderer;
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *av = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:NSStringFromClass(MKPinAnnotationView.class)];
    av.canShowCallout = YES;
    return av;
}

@end
