const std = @import("std");
const raylib = @import("raylib");

// This redeclaration of types is 🤮
fn AddSharedComponentFields(comptime T: type) type {
    return struct {
        entityId: u16,
        data: T,
    };
}

pub const ComponentTypes = enum { position, velocity, sprite };

pub const PositionComponent = AddSharedComponentFields(raylib.Vector2);
pub const VelocityComponent = AddSharedComponentFields(raylib.Vector3);
pub const SpriteComponent = AddSharedComponentFields(raylib.Texture2D);

pub const ComponentUnion = union(ComponentTypes) { position: PositionComponent, velocity: VelocityComponent, sprite: SpriteComponent };

pub const Register = struct {
    entities: std.ArrayList(u16) = undefined,
    components: struct {
        position: std.ArrayList(PositionComponent),
        velocity: std.ArrayList(VelocityComponent),
        sprite: std.ArrayList(SpriteComponent),
    } = undefined,

    pub fn init(self: *Register, allocator: std.mem.Allocator) void {
        self.entities = std.ArrayList(u16).init(allocator);
        self.components = .{
            .position = std.ArrayList(PositionComponent).init(allocator),
            .velocity = std.ArrayList(VelocityComponent).init(allocator),
            .sprite = std.ArrayList(SpriteComponent).init(allocator),
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

    pub fn addComponent(self: *Register, data: ComponentUnion) !void {
        // TODO: add functionality to ignore dupes
        switch (data) {
            .position => {
                std.debug.print("Adding position component with entity id: {}\n", .{data.position.entityId});
                try self.components.position.append(data.position);
            },
            .velocity => {
                std.debug.print("Adding velocity component with entity id: {}\n", .{data.velocity.entityId});
                try self.components.velocity.append(data.velocity);
            },
            .sprite => {
                std.debug.print("Adding sprite component with entity id: {}\n", .{data.sprite.entityId});
                try self.components.sprite.append(data.sprite);
            },
        }
    }

    pub fn getComponentByEntity(self: *Register, entityId: u16, component: ComponentTypes) ?ComponentUnion {
        switch (component) {
            .position => {
                for (self.components.position.items) |item| {
                    if (item.entityId == entityId) {
                        return ComponentUnion{ .position = item };
                    }
                }
            },
            .velocity => {
                for (self.components.velocity.items) |item| {
                    if (item.entityId == entityId) {
                        return ComponentUnion{ .velocity = item };
                    }
                }
            },
            .sprite => {
                for (self.components.sprite.items) |item| {
                    if (item.entityId == entityId) {
                        return ComponentUnion{ .sprite = item };
                    }
                }
            },
        }
        return null;
    }

    pub fn getAllComponentsByType(self: *Register, comptime T: type) ?[](T) {
        std.debug.print("Type: {}", .{T});
        switch (T) {
            PositionComponent => {
                return self.components.position.items;
            },
            VelocityComponent => {
                return self.components.velocity.items;
            },
            SpriteComponent => {
                return self.components.sprite.items;
            },
            else => {
                std.debug.print("Whoops", .{});
            },
        }
        return null;
    }
};
