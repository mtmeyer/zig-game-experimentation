const std = @import("std");
const raylib = @import("raylib");

// This redeclaration of types is 🤮
pub const ComponentDataTypes = .{ .position = raylib.Vector2, .velocity = raylib.Vector2, .sprite = raylib.Texture2D };
pub const Components = struct { position: std.ArrayList(ComponentDataTypes.position), velocity: std.ArrayList(ComponentDataTypes.velocity), sprite: std.ArrayList(ComponentDataTypes.sprite) };
pub const ComponentTypes = enum { position, velocity, sprite };

pub const Register = struct {
    entities: std.ArrayList(u16) = undefined,
    components: Components = undefined,

    pub fn init(self: *Register, allocator: std.mem.Allocator) void {
        self.entities = std.ArrayList(u16).init(allocator);
        self.components = Components{
            .position = std.ArrayList(raylib.Vector2).init(allocator),
            .velocity = std.ArrayList(raylib.Vector2).init(allocator),
            .sprite = std.ArrayList(raylib.Texture2D).init(allocator),
        };
    }

    pub fn deinit(self: *Register) void {
        self.entities.deinit();
    }

    pub fn addEntity(self: *Register) !u16 {
        var rand = std.rand.DefaultPrng.init(0);
        const id = rand.random().uintAtMost(u16, 65535);
        std.debug.print("\nAdd entity w/ ID: {}\n", .{id});

        try self.entities.append(id);
        return id;
    }

    pub fn addComponent(self: *Register, comptime T: type, componentType: ComponentTypes, data: T) void {
        _ = self;
        std.debug.print("componentType: {}\n", .{componentType});
        std.debug.print("data: {}\n", .{data});
        std.debug.print("type: {}\n", .{T});
    }
};

// Way to instantiate new list of components
