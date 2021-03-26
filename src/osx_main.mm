#include <stdio.h>
#include <AppKit/AppKit.h>

static float WIDTH  = 1024;
static float HEIGHT = 768;

static bool running = true;
static uint8_t *buffer;
static NSBitmapImageRep *imageRep;


static void resizeSection(int width, int height) {
  if (imageRep) {
    free(buffer);
    [imageRep release];
  }

  // if (!deviceContext) {
  //   deviceContext = ;
  // }

  int bytesPerPixel = 4;
  int pitch = bytesPerPixel * width;
  buffer = (uint8_t *)malloc(pitch * height);

  imageRep = [[NSBitmapImageRep alloc]
    initWithBitmapDataPlanes:&buffer
                  pixelsWide:width
                  pixelsHigh:height
               bitsPerSample:8
             samplesPerPixel:4
                    hasAlpha:YES
                    isPlanar:NO
              colorSpaceName:NSDeviceRGBColorSpace
                bitmapFormat:NSBitmapFormatThirtyTwoBitBigEndian
                 bytesPerRow:pitch
                bitsPerPixel:32];

}

static void updateWindow(NSWindow *window, int width, int height) {
  @autoreleasepool {
    NSImage *image = [[[NSImage alloc] initWithSize:NSMakeSize(width, height)] autorelease];
    [image addRepresentation:imageRep];
    window.contentView.layer.contents = image;
  }
}

@interface WindowDelegate: NSObject<NSWindowDelegate>;
@end

@implementation WindowDelegate

- (void)windowWillClose:(NSNotification *)notification {
  running = false;
}

- (void)windowDidResize:(NSNotification *)notification {
}

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize {
  resizeSection(frameSize.width, frameSize.height);

  // static bool isWhite = true;
  // sender.backgroundColor = isWhite ? NSColor.blackColor : NSColor.whiteColor;;
  // isWhite = !isWhite;

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
  window.backgroundColor = NSColor.blackColor;
  [window makeKeyAndOrderFront:nil];

  // [NSApp activateIgnoringOtherApps:YES];

  [window setDelegate:windowDelegate];
  [window setLevel:NSScreenSaverWindowLevel + 1];
  [window orderFront:nil];

  printf("level is %ld\n", window.level);

  while(running) {
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

      int w = window.contentView.bounds.size.width;
      int h = window.contentView.bounds.size.height;
      updateWindow(window, w, h);

    } while(event != nil);

  }

}
