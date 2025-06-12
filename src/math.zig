pub const Vec2 = struct {
    pub const ZERO: Vec2 = .{ .x = 0, .y = 0 };

    x: f32,
    y: f32,

    pub fn add(l: Vec2, r: Vec2) Vec2 {
        return .{ .x = l.x + r.x, .y = l.y + r.y };
    }
};
