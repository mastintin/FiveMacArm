#import <UserNotifications/UserNotifications.h>
#include <fivemac.h>

static PHB_SYMB symFMH = NULL;

@interface NotiDelegate : NSObject <UNUserNotificationCenterDelegate>
@end

@implementation NotiDelegate

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:
             (void (^)(UNNotificationPresentationOptions options))
                 completionHandler {
  completionHandler(UNNotificationPresentationOptionList |
                    UNNotificationPresentationOptionBanner |
                    UNNotificationPresentationOptionSound);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
    didReceiveNotificationResponse:(UNNotificationResponse *)response
             withCompletionHandler:(void (^)(void))completionHandler {

  UNNotification *notification = response.notification;

  if (symFMH == NULL)
    symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMN"));

  hb_vmPushSymbol(symFMH);
  hb_vmPushNil();
  hb_vmPushLong((HB_LONG)notification); // Passing notification object
  hb_vmPushLong(WM_NOTICLICK);
  hb_vmPushLong((HB_LONG)notification);
  hb_vmDo(3);

  completionHandler();
}

@end

static NotiDelegate *sharedNotiDelegate = nil;

HB_FUNC(NOTIFICREATE) {
  UNMutableNotificationContent *content =
      [[UNMutableNotificationContent alloc] init];

  content.title = hb_NSSTRING_par(1);
  content.body = hb_NSSTRING_par(2);
  content.subtitle = hb_NSSTRING_par(3);
  content.sound = [UNNotificationSound defaultSound];

  // Store a unique identifier in userInfo to help with deletion later
  NSString *uuid = [[NSUUID UUID] UUIDString];
  content.userInfo = @{@"identifier" : uuid};

  hb_retnl((HB_LONG)content);
}

HB_FUNC(NOTIFYSETTITLE) {
  UNMutableNotificationContent *content =
      (UNMutableNotificationContent *)hb_parnl(1);
  content.title = hb_NSSTRING_par(2);
}

HB_FUNC(NOTIFYGETTITLE) {
  UNMutableNotificationContent *content =
      (UNMutableNotificationContent *)hb_parnl(1);
  NSString *title = content.title;
  hb_retc([title cStringUsingEncoding:NSWindowsCP1252StringEncoding]);
}

HB_FUNC(NOTIFYSETINFO) {
  UNMutableNotificationContent *content =
      (UNMutableNotificationContent *)hb_parnl(1);
  content.body = hb_NSSTRING_par(2);
}

HB_FUNC(NOTIFYSETSUBTITLE) {
  UNMutableNotificationContent *content =
      (UNMutableNotificationContent *)hb_parnl(1);
  content.subtitle = hb_NSSTRING_par(2);
}

HB_FUNC(NOTIFYDELIVER) {
  UNMutableNotificationContent *content =
      (UNMutableNotificationContent *)hb_parnl(1);
  UNUserNotificationCenter *center =
      [UNUserNotificationCenter currentNotificationCenter];

  if (sharedNotiDelegate == nil) {
    sharedNotiDelegate = [[NotiDelegate alloc] init];
  }
  [center setDelegate:sharedNotiDelegate];

  [center
      requestAuthorizationWithOptions:(UNAuthorizationOptionAlert |
                                       UNAuthorizationOptionSound)
                    completionHandler:^(BOOL granted,
                                        NSError *_Nullable error) {
                      if (granted) {
                        NSString *identifier = content.userInfo[@"identifier"];
                        UNNotificationRequest *request = [UNNotificationRequest
                            requestWithIdentifier:identifier
                                          content:content
                                          trigger:nil];
                        [center addNotificationRequest:request
                                 withCompletionHandler:nil];
                      }
                    }];
}

HB_FUNC(NOTIFISOUND) {
  UNMutableNotificationContent *content =
      (UNMutableNotificationContent *)hb_parnl(1);
  content.sound = [UNNotificationSound defaultSound];
}

HB_FUNC(NOTIFYDELETEALL) {
  UNUserNotificationCenter *center =
      [UNUserNotificationCenter currentNotificationCenter];
  [center removeAllDeliveredNotifications];
  [center removeAllPendingNotificationRequests];
}

HB_FUNC(NOTIFYDELETE) {
  UNMutableNotificationContent *content =
      (UNMutableNotificationContent *)hb_parnl(1);
  NSString *identifier = content.userInfo[@"identifier"];
  if (identifier) {
    UNUserNotificationCenter *center =
        [UNUserNotificationCenter currentNotificationCenter];
    [center removeDeliveredNotificationsWithIdentifiers:@[ identifier ]];
    [center removePendingNotificationRequestsWithIdentifiers:@[ identifier ]];
  }
}

HB_FUNC(NOTIFIISPRESENTED) {
  // UNNotification doesn't have a simple isPresented boolean like
  // NSUserNotification. Returning false as a placeholder or we could check
  // delivered notifications asynchronously.
  hb_retl(NO);
}

HB_FUNC(NOTIFIINTERVAL) {
  NSTimeInterval interval = hb_parnl(2);
  UNMutableNotificationContent *content =
      (UNMutableNotificationContent *)hb_parnl(1);
  UNUserNotificationCenter *center =
      [UNUserNotificationCenter currentNotificationCenter];

  if (sharedNotiDelegate == nil) {
    sharedNotiDelegate = [[NotiDelegate alloc] init];
  }
  [center setDelegate:sharedNotiDelegate];

  [center
      requestAuthorizationWithOptions:(UNAuthorizationOptionAlert |
                                       UNAuthorizationOptionSound)
                    completionHandler:^(BOOL granted,
                                        NSError *_Nullable error) {
                      if (granted) {
                        NSString *identifier = content.userInfo[@"identifier"];
                        UNTimeIntervalNotificationTrigger *trigger =
                            [UNTimeIntervalNotificationTrigger
                                triggerWithTimeInterval:interval
                                                repeats:NO];
                        UNNotificationRequest *request = [UNNotificationRequest
                            requestWithIdentifier:identifier
                                          content:content
                                          trigger:trigger];
                        [center addNotificationRequest:request
                                 withCompletionHandler:nil];
                      }
                    }];
}
