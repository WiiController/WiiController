//
//  NotificationWindowView.m
//  UserNotification
//
//  Created by alxn1 on 19.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "NotificationWindowView.h"

#import <objc/message.h>

#define NotificationWindowViewWidth      300.0f
#define NotificationWindowViewMaxHeight  600.0f

@interface NotificationWindowView (PrivatePart)

- (BOOL)isHowered;
- (void)setHowered:(BOOL)hovered;

- (BOOL)isCloseButtonPressed;
- (void)setCloseButtonPressed:(BOOL)pressed;

- (BOOL)isMouseInside;

- (void)removeTrackingRect;
- (void)updateTrackingRect;

- (NSRect)closeButtonRect:(NSRect)rect;
- (NSRect)iconRect:(NSRect)rect;
- (NSRect)titleRect:(NSRect)rect attributes:(NSDictionary*)attributes;
- (NSSize)maxTextSize:(NSRect)rect titleHeight:(float)titleHeight;
- (NSRect)textRect:(NSRect)rect titleHeight:(float)titleHeight attributes:(NSDictionary*)attributes;

- (void)drawCloseButton:(NSRect)rect;

+ (NSDictionary*)titleTextAttributes;
+ (NSDictionary*)textAttributes;

+ (NSSize)titleSize:(NSString*)title;
+ (NSSize)textSize:(NSString*)text;

+ (NSString*)pathForImage:(NSString*)name;

+ (NSImage*)closeButtonImage;
+ (NSImage*)pressedCloseButtonImage;

@end

@implementation NotificationWindowView

+ (NSRect)bestViewRectForTitle:(NSString*)title text:(NSString*)text
{
    NSRect result       = NSZeroRect;
    NSSize titleSize    = [NotificationWindowView titleSize:title];
    NSSize textSize     = [NotificationWindowView textSize:text];

    result.size.width   = NotificationWindowViewWidth;
    result.size.height  = 10.0f + titleSize.height + 10.0f + textSize.height + 20.0f;

    if(result.size.height > NotificationWindowViewMaxHeight)
        result.size.height = NotificationWindowViewMaxHeight;

    return result;
}

- (id)initWithFrame:(NSRect)rect
{
    self = [super initWithFrame:rect];
    if(self == nil)
        return nil;

    _isHowered             = NO;
    _isMouseDragged        = NO;
    _isCloseButtonDragged  = NO;
    _isCloseButtonPressed  = NO;
    _isAlreadyClicked      = NO;
    _trackingRectTag       = 0;

    [self updateTrackingRect];

    return self;
}

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super initWithCoder:decoder];
    if(self == nil)
        return nil;

    _isHowered             = NO;
    _isCloseButtonDragged  = NO;
    _isCloseButtonPressed  = NO;
    _isAlreadyClicked      = NO;
    _trackingRectTag       = 0;

    [self updateTrackingRect];

    return self;
}

- (void)dealloc
{
    [self removeTrackingRect];

}

- (NSImage*)icon
{
    return _icon;
}

- (void)setIcon:(NSImage*)img
{
    if(_icon == img)
        return;

    _icon = img;

    [_icon setSize:NSMakeSize(32.0f, 32.0f)];
    [self setNeedsDisplay:YES];
}

- (NSString*)title
{
    return _title;
}

- (void)setTitle:(NSString*)str
{
    if(_title == str)
        return;

    _title = str;

    [self setNeedsDisplay:YES];
}

- (NSString*)text
{
    return _text;
}

- (void)setText:(NSString*)str
{
    if(_text == str)
        return;

    _text = str;

    [self setNeedsDisplay:YES];
}

- (id)target
{
    return _target;
}

- (void)setTarget:(id)obj
{
    _target = obj;
}

- (SEL)action
{
    return _action;
}

- (void)setAction:(SEL)sel
{
    _action = sel;
}

- (id<NotificationWindowViewDelegate>)delegate
{
    return _delegate;
}

- (void)setDelegate:(id<NotificationWindowViewDelegate>)obj
{
    _delegate = obj;
}

- (void)viewDidHide
{
    [self removeTrackingRect];
}

- (void)viewDidUnhide
{
    [self updateTrackingRect];
}

- (BOOL)acceptsFirstMouse:(NSEvent*)event
{
    return YES;
}

- (void)mouseDown:(NSEvent*)event
{
    NSPoint mousePosition = [self convertPoint:[event locationInWindow]
                                      fromView:nil];

    if(NSPointInRect(
            mousePosition,
            [self closeButtonRect:[self bounds]]))
    {
        _isCloseButtonDragged = YES;
        [self setCloseButtonPressed:YES];
    }

    _isMouseDragged = YES;
}

- (void)mouseDragged:(NSEvent*)event
{
    NSPoint mousePosition = [self convertPoint:[event locationInWindow]
                                      fromView:nil];

    [self setHowered:NSPointInRect(mousePosition, [self frame])];

    if(_isCloseButtonDragged)
    {
        [self setCloseButtonPressed:
                            NSPointInRect(
                                mousePosition,
                                [self closeButtonRect:[self bounds]])];
    }
}

- (void)mouseUp:(NSEvent*)event
{
    if(!_isCloseButtonPressed && [self isHowered])
    {
        if(_target != nil && _action != nil && !_isAlreadyClicked)
        {
            ((void(*)(id self, SEL _cmd, NotificationWindowView *sender))objc_msgSend)
                (_target, _action, self);
            _isAlreadyClicked = YES;
        }
    }

    [self setCloseButtonPressed:NO];
    _isCloseButtonDragged = NO;
    _isMouseDragged = NO;

    if([self isHowered])
        [[self window] close];
}

- (void)mouseEntered:(NSEvent*)event
{
    if(_isMouseDragged)
        return;

    [self setHowered:YES];
}

- (void)mouseExited:(NSEvent*)event
{
    if(_isMouseDragged)
        return;

    [self setHowered:NO];
}

+ (NSGradient*)bgGradient
{
    static NSGradient *result = nil;

    if(result == nil)
    {
        result = [[NSGradient alloc] initWithColorsAndLocations:
                                                [NSColor clearColor],                            0.0f,
                                                [NSColor colorWithDeviceWhite:0.0f alpha:0.25f], 0.5f,
                                                [NSColor colorWithDeviceWhite:0.5f alpha:0.35f], 0.9f,
                                                nil];
    }

    return result;
}

- (void)drawRect:(NSRect)rect
{
    rect = [self bounds];

    [NSGraphicsContext saveGraphicsState];
    CGContextSetShouldSmoothFonts([[NSGraphicsContext currentContext] graphicsPort], NO);

    NSBezierPath *bgPath = [NSBezierPath bezierPathWithRoundedRect:rect xRadius:10.0f yRadius:10.0f];
    [[NSColor colorWithDeviceWhite:0.0f alpha:0.7f] setFill];

    [bgPath fill];
    [[NotificationWindowView bgGradient] drawInBezierPath:bgPath angle:90.0f];

    if(_icon != nil)
    {
        [_icon drawInRect:[self iconRect:rect]
                  fromRect:NSZeroRect
                 operation:NSCompositingOperationSourceOver
                  fraction:1.0f];
    }

    float titleHeight = 0.0f;
    if(_title != nil)
    {
        NSDictionary    *attributes = [NotificationWindowView titleTextAttributes];
        NSRect           textRect   = [self titleRect:rect attributes:attributes];

        [_title drawWithRect:textRect
                      options:0
                   attributes:attributes];

        titleHeight = textRect.size.height;
    }

    if(_text != nil)
    {
        NSDictionary *attributes = [NotificationWindowView textAttributes];

        [_text drawWithRect:[self textRect:rect titleHeight:titleHeight attributes:attributes]
                     options:NSStringDrawingUsesLineFragmentOrigin
                attributes:attributes];
    }

    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(rect, 1.0f, 1.0f)
                                                         xRadius:10.0f
                                                         yRadius:10.0f];

    if([self isHowered])
    {
        [[NSColor colorWithDeviceWhite:1.0f alpha:1.0f] setStroke];
        [path setLineWidth:2.0f];
    }
    else
    {
        [[NSColor colorWithDeviceWhite:1.0f alpha:0.45f] setStroke];
        [path setLineWidth:1.5f];
    }
    
    [path stroke];

    if([self isHowered])
        [self drawCloseButton:rect];

    [NSGraphicsContext restoreGraphicsState];
}

@end

@implementation NotificationWindowView (PrivatePart)

- (BOOL)isHowered
{
    return _isHowered;
}

- (void)setHowered:(BOOL)hovered
{
    if(_isHowered == hovered)
        return;

    _isHowered = hovered;
    [self setNeedsDisplay:YES];

    if(hovered)
        [_delegate notificationWindowViewMouseEntered:self];
    else
        [_delegate notificationWindowViewMouseExited:self];
}

- (BOOL)isCloseButtonPressed
{
    return _isCloseButtonPressed;
}

- (void)setCloseButtonPressed:(BOOL)pressed
{
    if(_isCloseButtonPressed == pressed)
        return;

    _isCloseButtonPressed = pressed;
    [self setNeedsDisplay:YES];
}

- (BOOL)isMouseInside
{
    NSPoint mousePosition = [[self window] mouseLocationOutsideOfEventStream];
    mousePosition         = [self convertPoint:mousePosition
                                      fromView:nil];

    return NSPointInRect(mousePosition, [self bounds]);
}

- (void)removeTrackingRect
{
    if(_trackingRectTag != 0)
    {
        [self removeTrackingRect:_trackingRectTag];
        _trackingRectTag = 0;
    }
}

- (void)updateTrackingRect
{
    [self removeTrackingRect];

    _trackingRectTag = [self addTrackingRect:[self bounds]
                                        owner:self
                                     userData:NULL
                                 assumeInside:[self isMouseInside]];
}

- (NSRect)closeButtonRect:(NSRect)rect
{
    NSSize closeButtonSize = [[NotificationWindowView closeButtonImage] size];

    return NSMakeRect(
                rect.origin.x + 3.0f,
                rect.origin.y + rect.size.height - closeButtonSize.height - 5.0f,
                closeButtonSize.width,
                closeButtonSize.height);
}

- (NSRect)iconRect:(NSRect)rect
{
    return NSMakeRect(
                    rect.origin.x + 10.0f,
                    rect.origin.y + rect.size.height - 32.0f - 10.0f,
                    32.0f,
                    32.0f);
}

- (NSRect)titleRect:(NSRect)rect attributes:(NSDictionary*)attributes
{
    NSSize size = [_title sizeWithAttributes:attributes];

    if(size.width > (rect.size.width - 10.0f - 32.0f - 10.0f - 20.0f))
        size.width = rect.size.width - 10.0f - 32.0f - 10.0f - 20.0f;

    return NSMakeRect(
                    rect.origin.x + 10.0f + 32.0f + 10.0f,
                    rect.origin.y + rect.size.height - size.height - 10.0f,
                    size.width,
                    size.height);
}

- (NSSize)maxTextSize:(NSRect)rect titleHeight:(float)titleHeight
{
    return NSMakeSize(
                rect.size.width - 10.0f - 32.0f - 10.0f - 20.0f,
                rect.size.height - 10.0f - titleHeight - 10.0f - 10.0f);
}

- (NSRect)textRect:(NSRect)rect titleHeight:(float)titleHeight attributes:(NSDictionary*)attributes
{
    NSRect maxRect = rect;

    maxRect.origin.x += 10.0f + 32.0f + 10.0f;
    maxRect.origin.y += 10.0f;
    maxRect.size      = [self maxTextSize:rect titleHeight:titleHeight];

    NSRect result =
           [_text boundingRectWithSize:maxRect.size
                                options:NSStringDrawingUsesLineFragmentOrigin
                             attributes:attributes];

    if(result.size.height > maxRect.size.height)
        result.size.height = maxRect.size.height;

    result.origin.x = maxRect.origin.x;
    result.origin.y = maxRect.origin.y + maxRect.size.height - result.size.height;

    return result;
}

- (void)drawCloseButton:(NSRect)rect
{
    NSImage *image = (_isCloseButtonPressed)?
                                ([NotificationWindowView pressedCloseButtonImage]):
                                ([NotificationWindowView closeButtonImage]);

    [image drawInRect:[self closeButtonRect:rect]
             fromRect:NSZeroRect
            operation:NSCompositingOperationSourceOver
             fraction:1.0f];
}

+ (NSDictionary*)titleTextAttributes
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];

    [style setAlignment:NSTextAlignmentLeft];
    [style setLineBreakMode:NSLineBreakByTruncatingTail];

    return @{
        NSForegroundColorAttributeName: [NSColor whiteColor],
        NSFontAttributeName: [NSFont boldSystemFontOfSize:13.0f],
        NSParagraphStyleAttributeName: style
    };
}

+ (NSDictionary*)textAttributes
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];

    [style setAlignment:NSTextAlignmentLeft];
    [style setLineBreakMode:NSLineBreakByWordWrapping];

    return @{
        NSForegroundColorAttributeName: [NSColor whiteColor],
        NSFontAttributeName: [NSFont menuFontOfSize:12.0f],
        NSParagraphStyleAttributeName: style
    };
}

+ (NSSize)titleSize:(NSString*)title
{
    NSSize size = [title sizeWithAttributes:[NotificationWindowView titleTextAttributes]];

    if(size.width > (NotificationWindowViewWidth - 10.0f - 32.0f - 10.0f - 20.0f)) {
        size.width = NotificationWindowViewWidth - 10.0f - 32.0f - 10.0f - 20.0f;
    }

    return size;
}

+ (NSSize)textSize:(NSString*)text
{
    NSRect result =
           [text boundingRectWithSize:NSMakeSize(
                                            NotificationWindowViewWidth - 10.0f - 32.0f - 10.0f - 20.0f,
                                            NotificationWindowViewMaxHeight)
                              options:NSStringDrawingUsesLineFragmentOrigin
                           attributes:[NotificationWindowView textAttributes]];

    if(result.size.height > NotificationWindowViewMaxHeight)
        result.size.height = NotificationWindowViewMaxHeight;

    return result.size;
}

+ (NSString*)pathForImage:(NSString*)name
{
    return [[NSBundle bundleForClass:[NotificationWindowView class]]
                                                            pathForResource:name
                                                                     ofType:@"png"];
}

+ (NSImage*)closeButtonImage
{
    static NSImage *result = nil;

    if(result == nil)
    {
        result = [[NSImage alloc] initWithContentsOfFile:
                            [NotificationWindowView pathForImage:@"closebutton"]];
    }

    return result;
}

+ (NSImage*)pressedCloseButtonImage
{
    static NSImage *result = nil;

    if(result == nil)
    {
        result = [[NSImage alloc] initWithContentsOfFile:
                            [NotificationWindowView pathForImage:@"closebutton_pressed"]];
    }

    return result;
}

@end
