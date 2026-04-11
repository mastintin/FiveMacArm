#import <Foundation/Foundation.h>
int main() {
#if __has_feature(objc_arc)
    printf("ARC is ON\n");
#else
    printf("ARC is OFF\n");
#endif
    return 0;
}
