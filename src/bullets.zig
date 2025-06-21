const std = @import("std");
const sdl = @import("sdl.zig");
const globals = @import("globals.zig");
const Vec2 = @import("math.zig").Vec2;
const Rect = @import("math.zig").Rect;

var bullets: std.ArrayList(Bullet) = undefined;

pub const Bullet = struct {
    position: Vec2 = .{ .x = 250, .y = 250 },
    size: Vec2 = .{ .x = 50, .y = 50 },

    pub fn init(self: *Bullet) void {
        self.position = .{ .x = 250, .y = 250 };
        self.size = .{ .x = 50, .y = 50 };
    }

    pub fn update(self: *Bullet) bool {
        self.position = self.position.addX(4);
        return globals.current_screen.areRectsOverlapping(Rect.from_vec2(self.position, self.size));
    }

    pub fn draw(self: *Bullet, rendering_window: *sdl.RenderingWindow) !void {
        try rendering_window.fillRect(&sdl.FRect.init(self.position.x, self.position.y, self.size.x, self.size.y), sdl.Color.init(0, 150, 0, sdl.Color.OPAQUE));
    }
};

pub fn init() void {
    bullets = std.ArrayList(Bullet).init(globals.allocater);
}

/// Increase length by 1, returning pointer to the new item.
/// The returned pointer becomes invalid when the list resized.
pub fn addOne() !*Bullet {
    return try bullets.addOne();
}

pub fn update() void {
    if (bullets.items.len > 0) {
        var i = bullets.items.len;
        while (i > 0) {
            i = i - 1;
            if (!bullets.items[i].update()) {
                _ = bullets.swapRemove(i);
            }
        }
    }
}

pub fn draw(rendering_window: *sdl.RenderingWindow) !void {
    for (bullets.items) |*bullet| {
        try bullet.draw(rendering_window);
    }
}
