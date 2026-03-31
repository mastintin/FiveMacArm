#import <Foundation/Foundation.h>
#import <Network/Network.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <arpa/inet.h>
#import <fivemac.h>
#import <ifaddrs.h>
#import <net/if.h>
#import <net/if_dl.h>
#import <sys/sysctl.h>

extern void hb_jsonDecode( const char * szJSON, PHB_ITEM pItem );

// Almacén global para cabeceras personalizadas (Singleton)
static NSMutableDictionary *_g_customHeaders = nil;

//----------------------------------------------------------------------------//

static void _ensureHeadersInitialized() {
  if (!_g_customHeaders) {
    _g_customHeaders = [[NSMutableDictionary alloc] init];
  }
}

//----------------------------------------------------------------------------//

HB_FUNC(NET_HTTPSETHEADER) {
  NSString *key = hb_NSSTRING_par(1);
  NSString *value = hb_NSSTRING_par(2);

  if (key) {
    _ensureHeadersInitialized();
    if (value && [value length] > 0) {
      [_g_customHeaders setObject:value forKey:key];
    } else {
      [_g_customHeaders removeObjectForKey:key];
    }
  }
}

//----------------------------------------------------------------------------//

HB_FUNC(NET_HTTPCLEARHEADERS) {
  if (_g_customHeaders) {
    [_g_customHeaders removeAllObjects];
  }
}

//----------------------------------------------------------------------------//

// AUXILIAR 1: Realiza la petición sincrónica con semáforo y aplica headers
static NSData *_net_http_sync_request(NSMutableURLRequest *request,
                                      double timeout) {
  // Aplicamos User-Agent por defecto si no existe
  if (![request valueForHTTPHeaderField:@"User-Agent"]) {
    [request setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
                      @"AppleWebKit/537.36 (KHTML, like Gecko) "
                      @"Chrome/91.0.4472.124 Safari/537.36"
        forHTTPHeaderField:@"User-Agent"];
  }

  // Aplicamos cabeceras personalizadas
  if (_g_customHeaders) {
    for (NSString *key in _g_customHeaders) {
      [request setValue:[_g_customHeaders objectForKey:key]
          forHTTPHeaderField:key];
    }
  }

  dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
  __block NSData *data = nil;

  NSURLSessionDataTask *task = [[NSURLSession sharedSession]
      dataTaskWithRequest:request
        completionHandler:^(NSData *d, NSURLResponse *r, NSError *e) {
          if (d) {
            data = [d retain]; // Retain para pasarlo a Harbour
          } else if (e) {
            NSLog(@"NET_HTTP Error: %@", [e localizedDescription]);
          }
          dispatch_semaphore_signal(semaphore);
        }];

  [task resume];

  dispatch_semaphore_wait(
      semaphore,
      dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)));

  // IMPORTANTE: En No-ARC hay que liberar el semáforo
  dispatch_release(semaphore);

  return data;
}

// AUXILIAR 2: Procesa el resultado y libera memoria
static void _processAndReturn(NSData *data) {
  if (data) {
    NSString *res = [[NSString alloc] initWithData:data
                                           encoding:NSUTF8StringEncoding];
    [data release]; // Libera el retain que hicimos en la descarga

    if (res) {
      hb_retc([res UTF8String]);
      [res release];
    } else {
      hb_retc("");
    }
  } else {
    hb_retc(""); // Error de red o timeout
  }
}

//----------------------------------------------------------------------------//

HB_FUNC(NET_HTTPGETJSON) {
  NSString *urlString = hb_NSSTRING_par(1);
  double timeout = (hb_pcount() >= 2) ? hb_parnd(2) : 30.0;

  NSURL *url = [NSURL URLWithString:urlString];
  if (!url) {
    hb_retc("");
    return;
  }

  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  [request setHTTPMethod:@"GET"];
  [request setTimeoutInterval:timeout];

  NSData *data = _net_http_sync_request(request, timeout);

  if (data) {
    NSString *content = [[NSString alloc] initWithData:data
                                              encoding:NSUTF8StringEncoding];
    PHB_ITEM pItem = hb_itemNew(NULL);

    if (content) {
      hb_jsonDecode([content UTF8String], pItem);
      hb_itemReturn(pItem);
      [content release];
    } else {
      hb_retc("");
    }

    hb_itemRelease(pItem);
    [data release];
  } else {
    hb_retc("");
  }
}

//----------------------------------------------------------------------------//

HB_FUNC(NET_HTTPGET) {
  NSString *urlString = hb_NSSTRING_par(1);
  double timeout = (hb_pcount() >= 2) ? hb_parnd(2) : 30.0;

  NSURL *url = [NSURL URLWithString:urlString];
  if (!url) {
    hb_retc("");
    return;
  }

  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  [request setHTTPMethod:@"GET"];
  [request setTimeoutInterval:timeout];

  _processAndReturn(_net_http_sync_request(request, timeout));
}

//----------------------------------------------------------------------------//

HB_FUNC(NET_HTTPPOST) {
  NSURL *url = [NSURL URLWithString:hb_NSSTRING_par(1)];
  NSString *body = hb_NSSTRING_par(2);
  double timeout = (hb_pcount() >= 3) ? hb_parnd(3) : 30.0;

  if (!url) {
    hb_retc("");
    return;
  }

  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  [request setHTTPMethod:@"POST"];
  [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
  [request setTimeoutInterval:timeout];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

  _processAndReturn(_net_http_sync_request(request, timeout));
}

//----------------------------------------------------------------------------//

HB_FUNC(NET_HTTPPUT) {
  NSURL *url = [NSURL URLWithString:hb_NSSTRING_par(1)];
  NSString *jsonBody = hb_NSSTRING_par(2);
  double timeout = (hb_pcount() >= 3) ? hb_parnd(3) : 30.0;

  if (!url) {
    hb_retc("");
    return;
  }

  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  [request setHTTPMethod:@"PUT"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [request setHTTPBody:[jsonBody dataUsingEncoding:NSUTF8StringEncoding]];
  [request setTimeoutInterval:timeout];

  _processAndReturn(_net_http_sync_request(request, timeout));
}

//----------------------------------------------------------------------------//

HB_FUNC(NET_HTTPDELETE) {
  NSURL *url = [NSURL URLWithString:hb_NSSTRING_par(1)];
  double timeout = (hb_pcount() >= 2) ? hb_parnd(2) : 30.0;

  if (!url) {
    hb_retc("");
    return;
  }

  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  [request setHTTPMethod:@"DELETE"];
  [request setTimeoutInterval:timeout];

  _processAndReturn(_net_http_sync_request(request, timeout));
}

//----------------------------------------------------------------------------//

HB_FUNC(NET_HTTPDOWNLOAD) {
  NSString *urlString = hb_NSSTRING_par(1);
  NSString *destPath = hb_NSSTRING_par(2);
  double timeout = (hb_pcount() >= 3) ? hb_parnd(3) : 60.0;

  NSURL *url = [NSURL URLWithString:urlString];
  if (!url || !destPath) {
    hb_retl(NO);
    return;
  }

  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  [request setHTTPMethod:@"GET"];
  [request setTimeoutInterval:timeout];

  NSData *data = _net_http_sync_request(request, timeout);

  if (data) {
    BOOL success = [data writeToFile:destPath atomically:YES];
    [data release];
    hb_retl(success);
  } else {
    hb_retl(NO);
  }
}

//----------------------------------------------------------------------------//

// NET_HTTPUPLOAD( cUrl, cLocalPath, [nTimeout] )
HB_FUNC(NET_HTTPUPLOAD) {
  NSString *urlString = hb_NSSTRING_par(1);
  NSString *filePath = hb_NSSTRING_par(2);
  double timeout = (hb_pcount() >= 3) ? hb_parnd(3) : 60.0;

  NSURL *url = [NSURL URLWithString:urlString];
  if (!url || !filePath) {
    hb_retl(NO);
    return;
  }

  NSData *fileData = [NSData dataWithContentsOfFile:filePath];
  if (fileData) {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:fileData];
    [request setTimeoutInterval:timeout];

    NSData *response = _net_http_sync_request(request, timeout);
    if (response) {
      [response release];
      hb_retl(YES);
    } else {
      hb_retl(NO);
    }
  } else {
    hb_retl(NO);
  }
}

//----------------------------------------------------------------------------//

HB_FUNC(NET_ISCONNECTED) {
  nw_path_monitor_t monitor = nw_path_monitor_create();
  dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
  __block BOOL connected = NO;

  nw_path_monitor_set_update_handler(monitor, ^(nw_path_t path) {
    if (nw_path_get_status(path) == nw_path_status_satisfied) {
      connected = YES;
    }
    dispatch_semaphore_signal(semaphore);
  });

  nw_path_monitor_set_queue(
      monitor, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
  nw_path_monitor_start(monitor);

  dispatch_semaphore_wait(
      semaphore, dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC));
  nw_path_monitor_cancel(monitor);

  dispatch_release(semaphore);
  if (monitor) {
    dispatch_release((dispatch_object_t)monitor);
  }
  hb_retl(connected);
}

//----------------------------------------------------------------------------//

HB_FUNC(NET_GETMACADDRESS) {
  int mib[6];
  size_t len;
  char *buf;
  unsigned char *ptr;
  struct if_msghdr *ifm;
  struct sockaddr_dl *sdl;

  mib[0] = CTL_NET;
  mib[1] = AF_ROUTE;
  mib[2] = 0;
  mib[3] = AF_LINK;
  mib[4] = NET_RT_IFLIST;

  if ((mib[5] = if_nametoindex("en0")) == 0) {
    hb_retc("");
    return;
  }

  if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
    hb_retc("");
    return;
  }

  if ((buf = malloc(len)) == NULL) {
    hb_retc("");
    return;
  }

  if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
    free(buf);
    hb_retc("");
    return;
  }

  ifm = (struct if_msghdr *)buf;
  sdl = (struct sockaddr_dl *)(ifm + 1);
  ptr = (unsigned char *)LLADDR(sdl);

  NSString *out =
      [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", ptr[0],
                                 ptr[1], ptr[2], ptr[3], ptr[4], ptr[5]];

  free(buf);
  hb_retc([out UTF8String]);
}

//----------------------------------------------------------------------------//

HB_FUNC(NET_GETIP) {
  NSString *address = @"0.0.0.0";
  struct ifaddrs *interfaces = NULL;
  struct ifaddrs *temp_addr = NULL;

  if (getifaddrs(&interfaces) == 0) {
    temp_addr = interfaces;
    while (temp_addr != NULL) {
      if (temp_addr->ifa_addr->sa_family == AF_INET) {
        if (![[NSString stringWithUTF8String:temp_addr->ifa_name]
                isEqualToString:@"lo0"]) {
          address = [NSString
              stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)
                                                  temp_addr->ifa_addr)
                                                 ->sin_addr)];
          break;
        }
      }
      temp_addr = temp_addr->ifa_next;
    }
  }
  freeifaddrs(interfaces);
  hb_retc([address UTF8String]);
}

//----------------------------------------------------------------------------//

HB_FUNC(NET_GETPUBLICIP) {
  double timeout = (hb_pcount() >= 1) ? hb_parnd(1) : 15.0;
  NSURL *url = [NSURL URLWithString:@"https://api.ipify.org"];

  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  [request setHTTPMethod:@"GET"];
  [request setTimeoutInterval:timeout];

  _processAndReturn(_net_http_sync_request(request, timeout));
}
