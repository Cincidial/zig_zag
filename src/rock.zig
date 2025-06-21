const std = @import("std");
const sdl = @import("sdl.zig");
const globals = @import("globals.zig");
const Vec2 = @import("math.zig").Vec2;
const Rect = @import("math.zig").Rect;

pub const Rock = struct {
    active: bool = false,
    position: Vec2 = .{ .x = 250, .y = 250 },
    size: Vec2 = .{ .x = 50, .y = 50 },
    speed: Vec2 = .{ .x = 0, .y = 5 },

    pub fn update(self: *Rock) void {
        if (!self.active) {
            if (globals.rng.uintAtMost(u16, std.math.maxInt(u16)) > std.math.maxInt(u16) - 2) {
                self.active = true;
                self.position = .{ .x = globals.rng.float(f32) * (globals.current_screen.right() - self.size.x), .y = -self.size.y };
            }
        } else {
            self.active = globals.current_screen.areRectsOverlapping(Rect.from_vec2(self.position, self.size));
            if (!self.active) return;
        }

        self.position = self.position.addY(self.speed.y);
    }

    pub fn draw(self: *Rock, rendering_window: *sdl.RenderingWindow) !void {
        if (!self.active) return;

        try rendering_window.fillRect(&sdl.FRect.init(self.position.x, self.position.y, self.size.x, self.size.y), sdl.Color.init(150, 0, 50, sdl.Color.OPAQUE));
    }
};
