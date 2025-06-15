const std = @import("std");
const sdl = @import("sdl.zig");
const globals = @import("globals.zig");
const Vec2 = @import("math.zig").Vec2;
const Rect = @import("math.zig").Rect;

pub const Rock = struct {
    position: Vec2 = Vec2.ZERO,
    size: Vec2 = Vec2.ZERO,
    speed: Vec2 = Vec2.ZERO,

    pub fn alloc(allocater: std.mem.Allocator) !*Rock {
        const pointer = try allocater.create(Rock);
        pointer.position = .{ .x = 250, .y = 250 };
        pointer.size = .{ .x = 50, .y = 50 };
        pointer.speed = .{ .x = 0, .y = 5 };

        return pointer;
    }

    pub fn update(self: *Rock) bool {
        const outside = !globals.current_screen.areRectsOverlapping(Rect.from_vec2(self.position, self.size));
        if (outside) {
            self.speed = self.speed.newY(-self.speed.y);
        }

        self.position = self.position.addY(self.speed.y);
        return outside;
    }

    pub fn draw(self: *Rock, rendering_window: *sdl.RenderingWindow) !void {
        try rendering_window.fillRect(&sdl.FRect.init(self.position.x, self.position.y, self.size.x, self.size.y), sdl.Color.init(150, 0, 50, sdl.Color.OPAQUE));
    }
};
