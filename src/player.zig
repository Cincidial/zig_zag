const sdl = @import("sdl.zig");
const Vec2 = @import("math.zig").Vec2;

var position: Vec2 = Vec2.ZERO;
var speed: Vec2 = Vec2.ZERO;

pub fn update() void {
    position = position.add(speed);
}

pub fn draw(rendering_window: *sdl.RenderingWindow) !void {
    try rendering_window.fillRect(&sdl.FRect.init(position.x, position.y, 100, 100), sdl.Color.init(50, 50, 50, sdl.Color.OPAQUE));
}

pub fn event(e: sdl.Event) void {
    switch (e) {
        .key_down => {
            if (e.key_down.scan_code == sdl.ScanCode.A and !e.key_down.repeat) {
                speed = .{ .x = speed.x - 5, .y = speed.y };
            } else if (e.key_down.scan_code == sdl.ScanCode.D and !e.key_down.repeat) {
                speed = .{ .x = speed.x + 5, .y = speed.y };
            }
        },
        .key_up => {
            if (e.key_up.scan_code == sdl.ScanCode.A) {
                speed = .{ .x = speed.x + 5, .y = speed.y };
            } else if (e.key_up.scan_code == sdl.ScanCode.D) {
                speed = .{ .x = speed.x - 5, .y = speed.y };
            }
        },
        else => {},
    }
}
