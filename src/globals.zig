const std = @import("std");
const Rect = @import("math.zig").Rect;

pub var allocater: std.mem.Allocator = undefined;
pub var rng: std.Random = undefined;
pub var current_screen: Rect = undefined;
