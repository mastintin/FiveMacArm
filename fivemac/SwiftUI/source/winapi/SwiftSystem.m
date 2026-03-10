#import <Foundation/Foundation.h>
#include <hbapi.h>
#include <hbapiitm.h>
#include <hbvm.h>

extern const char *swift_get_file(const char *title, const char *types,
                                  const char *prompt);
extern const char *swift_get_dir(const char *title, const char *prompt);
extern void swift_alert(const char *msg, const char *title, int type);
extern BOOL swift_msg_yes_no(const char *msg, const char *title);
extern int swift_get_color(void);
extern const char *swift_get_path(void);
extern const char *swift_get_app_path(void);
extern const char *swift_get_res_path(void);
extern const char *swift_get_image(const char *title, const char *prompt);

// Observation Bridge (from SwiftMacro generated names)
extern void SW_OBS_SET_COUNT(const char *val);
extern void SW_OBS_SET_MSG(const char *nombre);
extern int sw_obs_get_count(void);

HB_FUNC(CSWGETFILE) {
  const char *title = hb_parc(1);
  const char *types = hb_parc(2);
  const char *prompt = hb_parc(3);
  const char *path = swift_get_file(title, types, prompt);
  if (path)
    hb_retc(path);
  else
    hb_retc("");
}

HB_FUNC(CSWGETDIR) {
  const char *title = hb_parc(1);
  const char *prompt = hb_parc(2);
  const char *path = swift_get_dir(title, prompt);
  if (path)
    hb_retc(path);
  else
    hb_retc("");
}

HB_FUNC(SW_MSGINFO) {
  const char *msg = hb_parc(1);
  const char *title = hb_pcount() > 1 ? hb_parc(2) : "Attention";
  swift_alert(msg, title, 0);
}

HB_FUNC(SW_MSGYESNO) {
  const char *msg = hb_parc(1);
  const char *title = hb_pcount() > 1 ? hb_parc(2) : "Select";
  hb_retl(swift_msg_yes_no(msg, title));
}

HB_FUNC(CSWGETCOLOR) { hb_retni(swift_get_color()); }

HB_FUNC(CSWPATH) { hb_retc(swift_get_path()); }

HB_FUNC(CSWAPPPATH) { hb_retc(swift_get_app_path()); }

HB_FUNC(CSWRESPATH) { hb_retc(swift_get_res_path()); }

// Observation Bridge Functions (HB_FUNCs)
HB_FUNC(SW_OBS_SETCOUNT) { SW_OBS_SET_COUNT(hb_parc(1)); }

HB_FUNC(SW_OBS_SETMSG) { SW_OBS_SET_MSG(hb_parc(1)); }

HB_FUNC(SW_OBS_GETCOUNT) { hb_retni(sw_obs_get_count()); }

HB_FUNC(CSWGETIMAGEFILE) {
  const char *title = hb_parc(1);
  const char *prompt = hb_parc(2);
  const char *path = swift_get_image(title, prompt);
  if (path)
    hb_retc(path);
  else
    hb_retc("");
}
