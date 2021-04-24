#include <stdio.h>
#include <stdint.h>
#include <AppKit/AppKit.h>

typedef uint8_t  uint8;
typedef uint16_t uint16;
typedef uint32_t uint32;
typedef uint64_t uint64;

typedef int8_t  int8;
typedef int16_t int16;
typedef int32_t int32;
typedef int64_t int64;


static float WIDTH  = 1280;
static float HEIGHT = 720;

struct OSX_Offscreen_Buffer {
  // NOTE: Pixels are always 32-bits wide.
  uint8 *memory;
  int width;
  int height;
  int pitch;
};

static bool running = true;
static OSX_Offscreen_Buffer global_back_buffer;

static void render_gradient(OSX_Offscreen_Buffer buffer, int x_offset, int y_offset) {
  uint8 *row = buffer.memory;

  for (int y = 0; y < buffer.height; y++) {
    // uint8 *pixel = (uint8 *) row;
    uint32 *pixel = (uint32 *) row;
    for (int x = 0; x < buffer.width; x++) {
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
    row += buffer.pitch;
  }
}

static void resize_window(OSX_Offscreen_Buffer *buffer, int width, int height) {
  if (buffer->memory) {
    free(buffer->memory);
  }

  // if (!deviceContext) {
  //   deviceContext = ;
  // }

  buffer->width  = width;
  buffer->height = height;
  int bytes_per_pixel = 4;

  buffer->pitch = bytes_per_pixel * width;
  buffer->memory = (uint8_t *)malloc(buffer->pitch * height);
}

static void display_buffer_in_window(NSWindow *window, OSX_Offscreen_Buffer buffer) {
  // TODO: FIX Aspect ratio
  @autoreleasepool {
    NSBitmapImageRep *imageRep = [[[NSBitmapImageRep alloc]
      initWithBitmapDataPlanes:&buffer.memory
                    pixelsWide:buffer.width
                    pixelsHigh:buffer.height
                 bitsPerSample:8
               samplesPerPixel:4
                      hasAlpha:YES
                      isPlanar:NO
                colorSpaceName:NSDeviceRGBColorSpace
                  bitmapFormat:NSBitmapFormatThirtyTwoBitBigEndian
                   bytesPerRow:buffer.pitch
                  bitsPerPixel:32] autorelease];


    NSSize image_size = NSMakeSize(buffer.width, buffer.height);
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
  // NOTE: Disable next lines makes stretchs on bitmap otherwise keep
  // all buffer size. Test it for more information!

  // NSWindow *window = (NSWindow *)notification.object;
  // NSSize size = window.contentView.bounds.size;
  // resize_window(&global_back_buffer, size.width, size.height);
  // render_gradient(global_back_buffer, 0, 0);
  // display_buffer_in_window(window, global_back_buffer);
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

  resize_window(&global_back_buffer, width, height);

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

      render_gradient(global_back_buffer, x_offset, y_offset);
      display_buffer_in_window(window, global_back_buffer);
      x_offset++;
      y_offset++;


    } while(event != nil);

  }

}
