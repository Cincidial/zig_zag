const sdl = @import("sdl.zig");
const globals = @import("globals.zig");
const bullets = @import("bullets.zig");
const Vec2 = @import("math.zig").Vec2;
const Rect = @import("math.zig").Rect;

const speed_scalar = 5;
var size: Vec2 = .{ .x = 100, .y = 100 };
var position: Vec2 = Vec2.ZERO;
var speed: Vec2 = Vec2.ZERO;

pub fn update() void {
    position = position.add(speed);
    const pos_rect = Rect.from_vec2(position, size);

    if (pos_rect.left() < globals.current_screen.left()) {
        position = position.newX(globals.current_screen.left());
    } else if (pos_rect.right() > globals.current_screen.right()) {
        position = position.newX(globals.current_screen.right() - size.x);
    }

    if (pos_rect.top() < globals.current_screen.top()) {
        position = position.newY(globals.current_screen.top());
    } else if (pos_rect.bottom() > globals.current_screen.bottom()) {
        position = position.newY(globals.current_screen.bottom() - size.y);
    }
}

pub fn draw(rendering_window: *sdl.RenderingWindow) !void {
    try rendering_window.fillRect(&sdl.FRect.init(position.x, position.y, size.x, size.y), sdl.Color.init(50, 50, 50, sdl.Color.OPAQUE));
}

pub fn event(e: sdl.Event) !void {
    switch (e) {
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
        .mouse_down => |md| {
            const bullet = try bullets.addOne();
            bullet.init();
            bullet.position = .{ .x = md.x, .y = md.y };
        },
        else => {},
    }
}
