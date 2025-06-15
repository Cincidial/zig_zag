const std = @import("std");

pub const Vec2 = struct {
    pub const ZERO: Vec2 = .{ .x = 0, .y = 0 };

    x: f32,
    y: f32,

    pub inline fn newX(vec2: Vec2, value: f32) Vec2 {
        return .{ .x = value, .y = vec2.y };
    }

    pub inline fn newY(vec2: Vec2, value: f32) Vec2 {
        return .{ .x = vec2.x, .y = value };
    }

    pub inline fn addX(vec2: Vec2, scalar: f32) Vec2 {
        return .{ .x = vec2.x + scalar, .y = vec2.y };
    }

    pub inline fn addY(vec2: Vec2, scalar: f32) Vec2 {
        return .{ .x = vec2.x, .y = vec2.y + scalar };
    }

    pub inline fn add(l: Vec2, r: Vec2) Vec2 {
        return .{ .x = l.x + r.x, .y = l.y + r.y };
    }

    pub inline fn subX(vec2: Vec2, scalar: f32) Vec2 {
        return .{ .x = vec2.x - scalar, .y = vec2.y };
    }

    pub inline fn subY(vec2: Vec2, scalar: f32) Vec2 {
        return .{ .x = vec2.x, .y = vec2.y - scalar };
    }

    pub fn print(self: Vec2) void {
        std.debug.print("({d}, {d})\n", .{ self.x, self.y });
    }
};

pub const Rect = struct {
    tl: Vec2 = undefined,
    bl: Vec2 = undefined,
    br: Vec2 = undefined,
    tr: Vec2 = undefined,

    pub inline fn from_vec2(pos_tl: Vec2, size: Vec2) Rect {
        return .{
            .tl = pos_tl,
            .bl = .{ .x = pos_tl.x, .y = pos_tl.y + size.y },
            .br = .{ .x = pos_tl.x + size.x, .y = pos_tl.y + size.y },
            .tr = .{ .x = pos_tl.x + size.x, .y = pos_tl.y },
        };
    }

    pub inline fn left(self: Rect) f32 {
        return self.tl.x;
    }

    pub inline fn right(self: Rect) f32 {
        return self.tr.x;
    }

    pub inline fn top(self: Rect) f32 {
        return self.tl.y;
    }

    pub inline fn bottom(self: Rect) f32 {
        return self.bl.y;
    }

    pub fn isPointWithin(self: Rect, point: Vec2) bool {
        return point.x >= self.left() and point.y <= self.right() and point.y >= self.top() and point.y <= self.bottom();
    }

    pub fn areRectsOverlapping(r1: Rect, r2: Rect) bool {
        return r1.isPointWithin(r2.tl) or r1.isPointWithin(r2.bl) or r1.isPointWithin(r2.br) or r1.isPointWithin(r2.tr) or r2.isPointWithin(r1.tl) or r2.isPointWithin(r1.bl) or r2.isPointWithin(r1.br) or r2.isPointWithin(r1.tr);
    }

    pub fn print(self: Rect) void {
        std.debug.print("tl: ({d}, {d}), bl: ({d}, {d}), br: ({d}, {d}), tr: ({d}, {d})\n", .{ self.tl.x, self.tl.y, self.bl.x, self.bl.y, self.br.x, self.br.y, self.tr.x, self.tr.y });
    }
};
