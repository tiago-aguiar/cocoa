#include <stdio.h>
#include <AppKit/AppKit.h>

static float WIDTH  = 1024;
static float HEIGHT = 768;

static bool Running = true;

@interface WindowDelegate: NSObject<NSWindowDelegate>;
@end

@implementation WindowDelegate

- (void)windowWillClose:(NSNotification *)notification {
  Running = false;
}

- (void)windowDidResize:(NSNotification *)notification {
}

- (NSSize)windowWillResize:(NSWindow *)sender
                    toSize:(NSSize)frameSize
{
  static bool isWhite = true;

  sender.backgroundColor = isWhite ? NSColor.blackColor : NSColor.whiteColor;;

  isWhite = !isWhite;

  printf("size is %d - %d\n", (int)frameSize.width, (int)frameSize.height);
  return frameSize;
}

@end


int main(int argc, const char *argv[]) {

  NSRect screenRect = [[NSScreen mainScreen] frame];

  NSRect windowRect = NSMakeRect(
      (screenRect.size.width  / 2) - (WIDTH  / 2),
      (screenRect.size.height / 2) - (HEIGHT / 2),
      WIDTH,
      HEIGHT);

  WindowDelegate *windowDelegate = [[WindowDelegate alloc] init];

  NSWindow *window = [[NSWindow alloc] initWithContentRect:windowRect
                                                 styleMask:NSWindowStyleMaskTitled
                                                 | NSWindowStyleMaskClosable
                                                 | NSWindowStyleMaskMiniaturizable
                                                 | NSWindowStyleMaskResizable
                                                 backing:NSBackingStoreBuffered
                                                   defer:YES];

  window.title = @"Cocoa";
  window.backgroundColor = NSColor.whiteColor;
  [window makeKeyAndOrderFront:nil];


  // [NSApp activateIgnoringOtherApps:YES];

  [window setDelegate:windowDelegate];
  [window setLevel:NSScreenSaverWindowLevel + 1];
  [window orderFront:nil];

  printf("level is %ld\n", window.level);

  while(Running) {
    NSEvent *event;

    do {
      event = [[NSApplication sharedApplication] nextEventMatchingMask:NSEventMaskAny
                                                             untilDate:nil
                                                                inMode:NSDefaultRunLoopMode
                                                               dequeue:YES];
      switch([event type]) {
        default:
          [NSApp sendEvent:event];
      }

    } while(event != nil);

  }

}
