const sdl = @import("sdl.zig");
const Vec2 = @import("math.zig").Vec2;
const Rect = @import("math.zig").Rect;

const speed_scalar = 5;
var size: Vec2 = .{ .x = 100, .y = 100 };
var position: Vec2 = Vec2.ZERO;
var speed: Vec2 = Vec2.ZERO;

var screen_size: Vec2 = Vec2.ZERO;

pub fn update() void {
    position = position.add(speed);
    const pos_rect = Rect.from_vec2(position, size);

    if (pos_rect.left() < 0) {
        position = position.newX(0);
    } else if (pos_rect.right() > screen_size.x) {
        position = position.newX(screen_size.x - size.x);
    }

    if (pos_rect.top() < 0) {
        position = position.newY(0);
    } else if (pos_rect.bottom() > screen_size.y) {
        position = position.newY(screen_size.y - size.y);
    }
}

pub fn draw(rendering_window: *sdl.RenderingWindow) !void {
    try rendering_window.fillRect(&sdl.FRect.init(position.x, position.y, size.x, size.y), sdl.Color.init(50, 50, 50, sdl.Color.OPAQUE));
}

pub fn event(e: sdl.Event) void {
    switch (e) {
        .window_resized => screen_size = e.window_resized.asVec2(),
        .key_down => {
            if (e.key_down.repeat) return;

            switch (e.key_down.scan_code) {
                .A => speed = speed.subX(speed_scalar),
                .D => speed = speed.addX(speed_scalar),
                .W => speed = speed.subY(speed_scalar),
                .S => speed = speed.addY(speed_scalar),
                else => return,
            }
        },
        .key_up => {
            switch (e.key_up.scan_code) {
                .A => speed = speed.addX(speed_scalar),
                .D => speed = speed.subX(speed_scalar),
                .W => speed = speed.addY(speed_scalar),
                .S => speed = speed.subY(speed_scalar),
                else => return,
            }
        },
        else => {},
    }
}
