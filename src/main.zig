const std = @import("std");
const sdl = @import("sdl.zig");
const globals = @import("globals.zig");
const math = @import("math.zig");
const player = @import("player.zig");
const Rock = @import("rock.zig").Rock;

const init_window_size_width = 640;
const init_window_size_height = 480;
var default_rng: std.Random.Xoshiro256 = undefined;

const Entity = union(enum) {
    rock: *Rock,
};

const EntityEntry = struct {
    entity: Entity,
    is_valid: bool = true,
};

const App = struct {
    allocater: std.mem.Allocator = undefined,
    rng: std.Random = undefined,
    rendering_window: sdl.RenderingWindow = undefined,
    entities: std.ArrayList(EntityEntry) = undefined,

    pub fn init(self: *App) !sdl.Result {
        sdl.logVersion();
        self.rendering_window = try sdl.createWindow("Zig Zag", "0.0.1", "zig_zag", init_window_size_width, init_window_size_height);
        errdefer self.cleanupWindow();

        _ = try self.event(.{ .window_resized = .{ .width = init_window_size_width, .height = init_window_size_height } });

        self.entities = std.ArrayList(EntityEntry).init(self.allocater);
        errdefer self.cleanupEntities();

        try self.entities.append(.{ .entity = .{ .rock = try Rock.alloc(self.allocater) } });
        return .persist;
    }

    pub fn iterate(self: *App) !sdl.Result {
        try self.rendering_window.clear(sdl.Color.init(1, 100, 1, sdl.Color.OPAQUE));
        player.update();

        if (self.rng.uintAtMost(u8, std.math.maxInt(u8)) > std.math.maxInt(u8) - 10) {
            var rock = try Rock.alloc(self.allocater);
            rock.position = .{ .x = self.rng.float(f32) * globals.current_screen.right(), .y = 0 };

            try self.entities.append(.{ .entity = .{ .rock = rock } });
        }

        var invalid_count: u16 = 0;
        for (self.entities.items) |*value| {
            if (!value.is_valid) {
                invalid_count += 1;
                continue;
            }

            if (value.entity.rock.update()) {
                self.allocater.destroy(value.entity.rock);
                value.is_valid = false;
            } else {
                try value.entity.rock.draw(&self.rendering_window);
            }
        }
        if (invalid_count > self.entities.items.len / 2) {
            var new_entities = try std.ArrayList(EntityEntry).initCapacity(self.allocater, self.entities.items.len - invalid_count);
            for (self.entities.items) |value| {
                if (value.is_valid) {
                    try new_entities.append(value);
                }
            }
            self.entities.clearAndFree();
            self.entities = new_entities;
        }

        try player.draw(&self.rendering_window);
        try self.rendering_window.present();
        return .persist;
    }

    pub fn event(self: *App, e: sdl.Event) !sdl.Result {
        if (e == .quit) {
            return .success;
        }

        player.event(e);
        return switch (e) {
            .key_down => {
                return switch (e.key_down.scan_code) {
                    .ESCAPE => {
                        sdl.quit();
                        return .success;
                    },
                    .N => {
                        var rock = try Rock.alloc(self.allocater);
                        rock.position = .{ .x = 5, .y = 100 };

                        try self.entities.append(.{ .entity = .{ .rock = rock } });
                        return .persist;
                    },
                    .P => {
                        std.debug.print("Count: {d}", .{self.entities.items.len});
                        return .persist;
                    },
                    else => .persist,
                };
            },
            .window_resized => {
                globals.current_screen = math.Rect.from_vec2(math.Vec2.ZERO, e.window_resized.asVec2());
                return .persist;
            },
            else => .persist,
        };
    }

    pub fn quit(self: *App, _: sdl.Result) void {
        self.cleanupWindow();
        self.cleanupEntities();
    }

    fn cleanupWindow(self: *App) void {
        self.rendering_window.destroy();
        self.rendering_window = undefined;
    }

    fn cleanupEntities(self: *App) void {
        for (self.entities.items) |value| {
            if (value.is_valid) {
                self.allocater.destroy(value.entity.rock);
            }
        }
        self.entities.deinit();
    }
};
var app: App = .{};

pub fn main() !u8 {
    default_rng = std.Random.DefaultPrng.init(std.crypto.random.int(u64));

    app.allocater = std.heap.page_allocator;
    app.rng = default_rng.random();

    return sdl.start(.{
        .init = struct {
            fn init() anyerror!sdl.Result {
                return app.init();
            }
        }.init,
        .iterate = struct {
            fn iterate() anyerror!sdl.Result {
                return app.iterate();
            }
        }.iterate,
        .event = struct {
            fn event(e: sdl.Event) anyerror!sdl.Result {
                return app.event(e);
            }
        }.event,
        .quit = struct {
            fn quit(r: sdl.Result) void {
                app.quit(r);
            }
        }.quit,
    });
}
