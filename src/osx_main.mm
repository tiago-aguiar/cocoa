#include <stdio.h>
#include <stdint.h>
#include <AppKit/AppKit.h>

typedef uint8_t  uint8;
typedef uint16_t uint16;

typedef int8_t  int8;
typedef int16_t int16;


static float WIDTH  = 1024;
static float HEIGHT = 768;

static int bitmap_width;
static int bitmap_height;
static int bytesPerPixel = 4;

static bool running = true;
static uint8 *buffer;

static void render_gradient(int x_offset, int y_offset) {
  int width  = bitmap_width;
  int height = bitmap_height;

  uint8 *row = buffer;
  int pitch = bytesPerPixel * width;

  for (int y = 0; y < height; y++) {
    // uint8 *pixel = (uint8 *) row;
    uint32 *pixel = (uint32 *) row;
    for (int x = 0; x < width; x++) {

      /*
      // R
       *pixel = 0;
       ++pixel;

      // G
       *pixel = (uint8) (y + y_offset);
       ++pixel;

      // B
       *pixel = (uint8) (x + x_offset);
       ++pixel;

      // A
       *pixel = 255;
       ++pixel;
       */

      uint8 alpha = 255;
      uint8 red   = 0;
      uint8 green = (y + y_offset);
      uint8 blue  = (x + x_offset);

      // AA BB GG RR
      *pixel++ = ((alpha << 24) | (red) | (green << 8) | (blue << 16));

    }
    row += pitch;
  }
}

static void resize_window(int width, int height) {
  if (buffer) {
    free(buffer);
  }

  // if (!deviceContext) {
  //   deviceContext = ;
  // }

  bitmap_width  = width;
  bitmap_height = height;

  int pitch = bytesPerPixel * width;
  buffer = (uint8_t *)malloc(pitch * height);
}

static void redraw_buffer(NSWindow *window) {
  @autoreleasepool {
    int pitch = bytesPerPixel * bitmap_width;
    NSBitmapImageRep *imageRep = [[[NSBitmapImageRep alloc]
      initWithBitmapDataPlanes:&buffer
                    pixelsWide:bitmap_width
                    pixelsHigh:bitmap_height
                 bitsPerSample:8
               samplesPerPixel:4
                      hasAlpha:YES
                      isPlanar:NO
                colorSpaceName:NSDeviceRGBColorSpace
                  bitmapFormat:NSBitmapFormatThirtyTwoBitBigEndian
                   bytesPerRow:pitch
                  bitsPerPixel:32] autorelease];


    NSSize image_size = NSMakeSize(bitmap_width, bitmap_height);
    NSImage *image = [[[NSImage alloc] initWithSize:image_size] autorelease];
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
  NSWindow *window = (NSWindow *)notification.object;
  NSSize size = window.contentView.bounds.size;
  resize_window(size.width, size.height);
  render_gradient(0,0);
  redraw_buffer(window);
}

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize {
  // resize_window(frameSize.width, frameSize.height);

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

  int x_offset = 0;
  int y_offset = 0;

  int width  = window.contentView.bounds.size.width;
  int height = window.contentView.bounds.size.height;

  resize_window(width, height);

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

      render_gradient(x_offset, y_offset);
      redraw_buffer(window);
      x_offset++;
      y_offset++;


    } while(event != nil);

  }

}
