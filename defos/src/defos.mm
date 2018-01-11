#include <dmsdk/sdk.h>
#include "defos_private.h"

#if defined(DM_PLATFORM_OSX)
#include <AppKit/AppKit.h>
#include <CoreGraphics/CoreGraphics.h>
#define DLIB_LOG_DOMAIN "DefOS"

static NSWindow* window = NULL;

static bool is_maximized = false;
static bool is_mouse_inside_window = false;
static NSRect previous_state;

static void enable_mouse_tracking();
static void disable_mouse_tracking();

void defos_init() {
    window = dmGraphics::GetNativeOSXNSWindow();
    enable_mouse_tracking();
}

void defos_final() {
    disable_mouse_tracking();
}

void defos_event_handler_was_set(DefosEvent event) {
}

void defos_disable_maximize_button() {
    [[window standardWindowButton:NSWindowZoomButton] setHidden:YES];
}

void defos_disable_minimize_button() {
    [[window standardWindowButton:NSWindowMiniaturizeButton] setHidden:YES];
}

void defos_disable_window_resize() {
    [window setStyleMask:[window styleMask] & ~NSResizableWindowMask];
}

void defos_disable_mouse_cursor() {
    [NSCursor hide];
}

void defos_enable_mouse_cursor() {
    [NSCursor unhide];
}

void defos_toggle_fullscreen() {
    if (is_maximized){
        defos_toggle_maximize();
    }
    [window setCollectionBehavior:NSWindowCollectionBehaviorFullScreenPrimary];
    [window toggleFullScreen:window];
}

void defos_toggle_maximize() {
    if (defos_is_fullscreen()){
        defos_toggle_fullscreen();
    }
    if (is_maximized){
        is_maximized = false;
        [window setFrame:previous_state display:YES];
    }
    else
    {
        is_maximized = true;
        previous_state = [window frame];
        [window setFrame:[[NSScreen mainScreen] visibleFrame] display:YES];
    }
}

void defos_show_console() {
	dmLogInfo("Method 'defos_show_console' is not supported in macOS");
}

void defos_hide_console() {
	dmLogInfo("Method 'defos_hide_console' is not supported in macOS");
}

bool defos_is_console_visible() {
	dmLogInfo("Method 'defos_is_console_visible' is not supported in macOS");
	return false;
}

bool defos_is_fullscreen() {
    BOOL fullscreen = (([window styleMask] & NSFullScreenWindowMask) == NSFullScreenWindowMask);
    return fullscreen == YES;
}

bool defos_is_maximized() {
    return is_maximized;
}

bool defos_is_mouse_inside_window() {
    return is_mouse_inside_window;
}

void defos_set_window_size(int x, int y, int w, int h) {
    // correction for result like on Windows PC
    int win_y = [[window screen] frame].size.height - h - y;
    [window setFrame:NSMakeRect(x, win_y, w , h) display:YES];
}

void defos_set_client_size(int x, int y, int w, int h){
    dmLogInfo("Method 'defos_set_client_size' is not supported in macOS");
}

void defos_set_window_title(const char* title_lua) {
    NSString* title = [NSString stringWithUTF8String:title_lua];
    [window setTitle:title];
}

WinRect defos_get_window_size(){
    WinRect rect;
    NSRect frame = [window frame];
    rect.x = frame.origin.x;
    rect.y = [[window screen] frame].size.height - frame.size.height - frame.origin.y;
    rect.w = frame.size.width;
    rect.h = frame.size.height;
    return rect;
}

void defos_set_cursor_pos(int x, int y)
{
    dmLogInfo("Method 'defos_set_cursor_pos' is not supported in macOS");
}

void defos_move_cursor_to(int x, int y)
{
    dmLogInfo("Method 'defos_move_cursor_to' is not supported in macOS");
}

void defos_clip_cursor()
{
    dmLogInfo("Method 'defos_clip_cursor' is not supported in macOS");
}

void defos_restore_cursor_clip()
{
    dmLogInfo("Method 'defos_restore_cursor_clip' is not supported in macOS");
}

@interface DefOSMouseTracker : NSObject
@end
@implementation DefOSMouseTracker
- (void)mouseEntered:(NSEvent *)event {
    is_mouse_inside_window = true;
    defos_emit_event(DEFOS_EVENT_MOUSE_ENTER);
}
- (void)mouseExited:(NSEvent *)event {
    is_mouse_inside_window = false;
    defos_emit_event(DEFOS_EVENT_MOUSE_LEAVE);
}
@end

static DefOSMouseTracker* mouse_tracker = nil;
static NSTrackingArea* tracking_area = nil;

static void enable_mouse_tracking() {
    if (tracking_area) { return; }
    mouse_tracker = [[DefOSMouseTracker alloc] init];
    tracking_area = [[NSTrackingArea alloc]
        initWithRect:NSZeroRect
        options: NSTrackingMouseEnteredAndExited | NSTrackingInVisibleRect | NSTrackingActiveAlways
        owner: mouse_tracker
        userInfo: nil
    ];
    [dmGraphics::GetNativeOSXNSView() addTrackingArea:tracking_area];
    [tracking_area release];
}

static void disable_mouse_tracking() {
    if (!tracking_area) { return; }

    [dmGraphics::GetNativeOSXNSView() removeTrackingArea:tracking_area];
    tracking_area = nil;

    [mouse_tracker release];
    mouse_tracker = nil;
}

#endif
