#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#include <fivemac.h>
#include <hbapi.h>
#include <hbapiitm.h>
#include <hbvm.h>
#import <objc/runtime.h>

static PHB_SYMB symFMH = NULL;

@interface MKMapView (FiveMac)
@end

@implementation MKMapView (FiveMac)
@end

@interface MapDelegate : NSObject <MKMapViewDelegate>
@end

@implementation MapDelegate
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView
            rendererForOverlay:(id<MKOverlay>)overlay {
  if ([overlay isKindOfClass:[MKPolyline class]]) {
    MKPolylineRenderer *renderer =
        [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    [renderer setStrokeColor:[NSColor systemBlueColor]];
    [renderer setLineWidth:5.0];
    return [renderer autorelease];
  }
  return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id<MKAnnotation>)annotation {
  if ([annotation isKindOfClass:[MKUserLocation class]]) {
    return nil;
  }

  static NSString *identifier = @"CustomAnnotation";

  // Check for custom icon or color
  NSString *iconName = objc_getAssociatedObject(annotation, "fb_icon");
  NSColor *color = objc_getAssociatedObject(annotation, "fb_color");

  if (iconName) {
    MKAnnotationView *annotationView =
        [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (!annotationView) {
      annotationView = [[[MKAnnotationView alloc] initWithAnnotation:annotation
                                                     reuseIdentifier:identifier]
          autorelease];
      annotationView.canShowCallout = YES;
    } else {
      annotationView.annotation = annotation;
    }
    annotationView.image = [NSImage imageNamed:iconName];
    return annotationView;
  } else {
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView
        dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
    if (!pinView) {
      pinView =
          [[[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                           reuseIdentifier:@"Pin"] autorelease];
      pinView.canShowCallout = YES;
    } else {
      pinView.annotation = annotation;
    }
    if (color) {
      if (@available(macOS 10.11, *)) {
        pinView.pinTintColor = color;
      }
    }
    return pinView;
  }
}
@end

//----------------------------------------------------------------------------//

HB_FUNC(MKMAPSETANNOTATIONICON) // ( hAnnotation, cImageName )
{
  id<MKAnnotation> annotation = (id<MKAnnotation>)hb_parnll(1);
  NSString *iconName = hb_NSSTRING_par(2);
  objc_setAssociatedObject(annotation, "fb_icon", iconName,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

HB_FUNC(MKMAPSETANNOTATIONCOLOR) // ( hAnnotation, nColor )
{
  id<MKAnnotation> annotation = (id<MKAnnotation>)hb_parnll(1);
  NSColor *color =
      [NSColor colorWithCalibratedRed:((hb_parnl(2) & 0xFF) / 255.0)
                                green:(((hb_parnl(2) >> 8) & 0xFF) / 255.0)
                                 blue:(((hb_parnl(2) >> 16) & 0xFF) / 255.0)
                                alpha:1.0];
  objc_setAssociatedObject(annotation, "fb_color", color,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//----------------------------------------------------------------------------//

HB_FUNC(MKMAPGOTOLOCATION) // ( hMap, cAddress )
{
  MKMapView *map = (MKMapView *)hb_parnll(1);
  NSString *address = hb_NSSTRING_par(2);

  CLGeocoder *geocoder = [[CLGeocoder alloc] init];

  [geocoder geocodeAddressString:address
               completionHandler:^(NSArray *placemarks, NSError *error) {
                 if (error) {
                   NSLog(@"Geocode failed with error: %@", error);
                   return;
                 }

                 if (placemarks && placemarks.count > 0) {
                   CLPlacemark *topResult = [placemarks objectAtIndex:0];
                   MKPlacemark *placemark =
                       [[MKPlacemark alloc] initWithPlacemark:topResult];

                   MKCoordinateRegion region = map.region;
                   region.center = placemark.coordinate;
                   region.span.longitudeDelta /= 8.0;
                   region.span.latitudeDelta /= 8.0;

                   [map setRegion:region animated:YES];
                   [map addAnnotation:placemark];
                 }
               }];
}

//----------------------------------------------------------------------------//

HB_FUNC(MKMAPSHOWROUTE) // ( hMap, cFrom, cTo, bInstructions )
{
  MKMapView *map = (MKMapView *)hb_parnll(1);
  NSString *cFrom = hb_NSSTRING_par(2);
  NSString *cTo = hb_NSSTRING_par(3);
  PHB_ITEM pCodeBlock =
      hb_param(4, HB_IT_BLOCK) ? hb_itemNew(hb_param(4, HB_IT_BLOCK)) : NULL;

  CLGeocoder *geocoder = [[CLGeocoder alloc] init];

  [geocoder
      geocodeAddressString:cFrom
         completionHandler:^(NSArray *placemarks, NSError *error) {
           if (error || placemarks.count == 0) {
             if (pCodeBlock)
               hb_itemRelease(pCodeBlock);
             return;
           }

           CLPlacemark *fromPlacemark = [placemarks objectAtIndex:0];
           MKPlacemark *fromMKPlacemark =
               [[MKPlacemark alloc] initWithPlacemark:fromPlacemark];
           MKMapItem *fromItem =
               [[MKMapItem alloc] initWithPlacemark:fromMKPlacemark];

           [geocoder
               geocodeAddressString:cTo
                  completionHandler:^(NSArray *placemarks2, NSError *error2) {
                    if (error2 || placemarks2.count == 0) {
                      if (pCodeBlock)
                        hb_itemRelease(pCodeBlock);
                      return;
                    }

                    CLPlacemark *toPlacemark = [placemarks2 objectAtIndex:0];
                    MKPlacemark *toMKPlacemark =
                        [[MKPlacemark alloc] initWithPlacemark:toPlacemark];
                    MKMapItem *toItem =
                        [[MKMapItem alloc] initWithPlacemark:toMKPlacemark];

                    MKDirectionsRequest *request =
                        [[MKDirectionsRequest alloc] init];
                    request.source = fromItem;
                    request.destination = toItem;
                    request.transportType = MKDirectionsTransportTypeAutomobile;

                    MKDirections *directions =
                        [[MKDirections alloc] initWithRequest:request];

                    [directions calculateDirectionsWithCompletionHandler:^(
                                    MKDirectionsResponse *response,
                                    NSError *error3) {
                      if (error3 || response.routes.count == 0) {
                        if (pCodeBlock)
                          hb_itemRelease(pCodeBlock);
                        return;
                      }

                      MKRoute *route = [response.routes objectAtIndex:0];
                      [map addOverlay:route.polyline
                                level:MKOverlayLevelAboveRoads];

                      [map addAnnotation:fromMKPlacemark];
                      [map addAnnotation:toMKPlacemark];

                      [map setVisibleMapRect:route.polyline.boundingMapRect
                                 edgePadding:NSEdgeInsetsMake(50, 50, 50, 50)
                                    animated:YES];

                      if (pCodeBlock) {
                        PHB_ITEM pSteps = hb_itemArrayNew(0);

                        for (MKRouteStep *step in route.steps) {
                          if (step.instructions.length > 0) {
                            PHB_ITEM pString = hb_itemPutC(
                                NULL, [step.instructions UTF8String]);
                            hb_arrayAdd(pSteps, pString);
                            hb_itemRelease(pString);
                          }
                        }

                        PHB_ITEM pArray = hb_itemArrayNew(3);
                        hb_arraySet(pArray, 1, pSteps);
                        hb_itemRelease(pSteps);

                        hb_arraySetForward(pArray, 2,
                                           hb_itemPutND(NULL, route.distance));
                        hb_arraySetForward(
                            pArray, 3,
                            hb_itemPutND(NULL, route.expectedTravelTime));

                        hb_vmEvalBlockV(pCodeBlock, 1, pArray);
                        hb_itemRelease(pArray);
                        hb_itemRelease(pCodeBlock);
                      }
                    }];
                  }];
         }];
}

//----------------------------------------------------------------------------//

HB_FUNC(MKMAPSHOWTRAFFIC) // ( hMap, lShow )
{
  MKMapView *map = (MKMapView *)hb_parnll(1);
  [map setShowsTraffic:hb_parl(2)];
}

//----------------------------------------------------------------------------//

HB_FUNC(MKMAPCREATE) // ( nTop, nLeft, nWidth, nHeight, oWnd )
{
  MKMapView *map =
      [[MKMapView alloc] initWithFrame:NSMakeRect(hb_parnl(2), hb_parnl(1),
                                                  hb_parnl(3), hb_parnl(4))];
  NSWindow *window = (NSWindow *)hb_parnll(5);

  [GetView(window) addSubview:map];

  MapDelegate *delegate = [[MapDelegate alloc] init];
  map.delegate = delegate;
  objc_setAssociatedObject(map, "fb_delegate", delegate,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  hb_retnll((HB_LONGLONG)map);
}

//----------------------------------------------------------------------------//

HB_FUNC(MKMAPSETTYPE) // ( hMap, nType )
{
  MKMapView *map = (MKMapView *)hb_parnll(1);

  switch (hb_parni(2)) {
  case 0:
    [map setMapType:MKMapTypeStandard];
    break;
  case 1:
    [map setMapType:MKMapTypeSatellite];
    break;
  case 2:
    [map setMapType:MKMapTypeHybrid];
    break;
  case 3:
    if (@available(macOS 10.11, *)) {
      [map setMapType:MKMapTypeSatelliteFlyover];
    }
    break;
  case 4:
    if (@available(macOS 10.11, *)) {
      [map setMapType:MKMapTypeHybridFlyover];
    }
    break;
  }
}

//----------------------------------------------------------------------------//

HB_FUNC(MKMAPSETCENTER) // ( hMap, nLat, nLon, nZoom )
{
  MKMapView *map = (MKMapView *)hb_parnll(1);
  CLLocationCoordinate2D location;
  MKCoordinateRegion region;
  MKCoordinateSpan span;

  location.latitude = hb_parnd(2);
  location.longitude = hb_parnd(3);

  span.latitudeDelta = hb_parnd(4);
  span.longitudeDelta = hb_parnd(4);

  region.center = location;
  region.span = span;

  [map setRegion:region animated:YES];
}

//----------------------------------------------------------------------------//

HB_FUNC(MKMAPADDANNOTATION) // ( hMap, nLat, nLon, cTitle, cSubTitle )
{
  MKMapView *map = (MKMapView *)hb_parnll(1);
  MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
  CLLocationCoordinate2D location;

  location.latitude = hb_parnd(2);
  location.longitude = hb_parnd(3);

  [annotation setCoordinate:location];
  [annotation setTitle:hb_NSSTRING_par(4)];
  [annotation setSubtitle:hb_NSSTRING_par(5)];

  [map addAnnotation:annotation];

  hb_retnll((HB_LONGLONG)annotation);
}

//----------------------------------------------------------------------------//

HB_FUNC(MKMAPSELECTANNOTATION) // ( hMap, hAnnotation )
{
  MKMapView *map = (MKMapView *)hb_parnll(1);
  id<MKAnnotation> annotation = (id<MKAnnotation>)hb_parnll(2);

  [map selectAnnotation:annotation animated:YES];
}

//----------------------------------------------------------------------------//

HB_FUNC(MKMAPREMOVEANNOTATIONS) // ( hMap )
{
  MKMapView *map = (MKMapView *)hb_parnll(1);

  [map removeAnnotations:map.annotations];
}

//----------------------------------------------------------------------------//

HB_FUNC(MKMAPREMOVEOVERLAYS) // ( hMap )
{
  MKMapView *map = (MKMapView *)hb_parnll(1);

  [map removeOverlays:map.overlays];
}

//----------------------------------------------------------------------------//

HB_FUNC(MKMAPSETRESIZING) // ( hMap, nResizing )
{
  MKMapView *map = (MKMapView *)hb_parnll(1);

  [map setAutoresizingMask:hb_parni(2)];
}

//----------------------------------------------------------------------------//

HB_FUNC(MKMAPZOOM) // ( hMap, nLevel )
{
  MKMapView *map = (MKMapView *)hb_parnll(1);
  double dLevel = hb_parnd(2);
  MKCoordinateRegion region = map.region;

  region.span.latitudeDelta *= dLevel;
  region.span.longitudeDelta *= dLevel;

  [map setRegion:region animated:YES];
}

//----------------------------------------------------------------------------//

HB_FUNC(MKMAPSETCAMERA) // ( hMap, nPitch, nHeading, nAltitude, lAnimated )
{
  MKMapView *map = (MKMapView *)hb_parnll(1);
  MKMapCamera *camera = [[map camera] copy];

  if (hb_param(2, HB_IT_NUMERIC))
    [camera setPitch:hb_parnd(2)];

  if (hb_param(3, HB_IT_NUMERIC))
    [camera setHeading:hb_parnd(3)];

  if (hb_param(4, HB_IT_NUMERIC))
    [camera setAltitude:hb_parnd(4)];

  [map setCamera:camera animated:hb_parl(5)];
  [camera release];
}

HB_FUNC(MKMAPGETPITCH) { hb_retnd([(MKMapView *)hb_parnll(1) camera].pitch); }

HB_FUNC(MKMAPGETHEADING) {
  hb_retnd([(MKMapView *)hb_parnll(1) camera].heading);
}

HB_FUNC(MKMAPGETALTITUDE) {
  hb_retnd([(MKMapView *)hb_parnll(1) camera].altitude);
}

//----------------------------------------------------------------------------//

HB_FUNC(MKMAPSEARCHPOI) // ( hMap, cSearch, bCallback )
{
  MKMapView *map = (MKMapView *)hb_parnll(1);
  NSString *cSearch = hb_NSSTRING_par(2);
  PHB_ITEM pCodeBlock =
      hb_param(3, HB_IT_BLOCK) ? hb_itemNew(hb_param(3, HB_IT_BLOCK)) : NULL;

  MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
  request.naturalLanguageQuery = cSearch;
  request.region = map.region;

  MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
  [search startWithCompletionHandler:^(MKLocalSearchResponse *response,
                                       NSError *error) {
    if (pCodeBlock) {
      PHB_ITEM pArray = hb_itemArrayNew(0);
      if (!error && response.mapItems.count > 0) {
        for (MKMapItem *item in response.mapItems) {
          PHB_ITEM pSub = hb_itemArrayNew(3);
          hb_arraySetForward(pSub, 1,
                             hb_itemPutC(NULL, [item.name UTF8String]));
          hb_arraySetForward(
              pSub, 2, hb_itemPutND(NULL, item.placemark.coordinate.latitude));
          hb_arraySetForward(
              pSub, 3, hb_itemPutND(NULL, item.placemark.coordinate.longitude));
          hb_arrayAdd(pArray, pSub);
          hb_itemRelease(pSub);
        }
      }
      hb_vmEvalBlockV(pCodeBlock, 1, pArray);
      hb_itemRelease(pCodeBlock);
      hb_itemRelease(pArray);
    }
  }];
  [request release];
}

//----------------------------------------------------------------------------//
