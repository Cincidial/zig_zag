const std = @import("std");
const sdl = @import("sdl.zig");
const Vec2 = @import("math.zig").Vec2;

pub const Rock = struct {
    position: Vec2 = Vec2.ZERO,
    size: Vec2 = Vec2.ZERO,

    pub fn alloc(allocater: std.mem.Allocator) !*Rock {
        const pointer = try allocater.create(Rock);
        pointer.size = .{ .x = 50, .y = 50 };

        return pointer;
    }

    pub fn update(self: *Rock) bool {
        self.position = self.position.addY(5);

        return false; // TODO: Return true when cleanup required and do cleanup in here before hand
    }

    pub fn draw(self: *Rock, rendering_window: *sdl.RenderingWindow) !void {
        try rendering_window.fillRect(&sdl.FRect.init(self.position.x, self.position.y, self.size.x, self.size.y), sdl.Color.init(150, 0, 50, sdl.Color.OPAQUE));
    }
};
