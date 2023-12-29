const std = @import("std");
const raylib = @import("raylib");

// This redeclaration of types is 🤮
fn AddSharedComponentFields(comptime T: type) type {
    return struct {
        entityId: usize,
        data: T,
    };
}

pub const ComponentTypes = enum { transform, velocity, sprite, position };

pub const TransformComponent = AddSharedComponentFields(raylib.Rectangle);
pub const PositionComponent = AddSharedComponentFields(raylib.Vector2);
pub const VelocityComponent = AddSharedComponentFields(raylib.Vector3);
pub const SpriteComponent = AddSharedComponentFields(raylib.Texture2D);

pub const ComponentUnion = union(ComponentTypes) { transform: TransformComponent, velocity: VelocityComponent, sprite: SpriteComponent, position: PositionComponent };

pub const Register = struct {
    entities: std.ArrayList(usize) = undefined,
    components: struct {
        transform: std.ArrayList(TransformComponent),
        velocity: std.ArrayList(VelocityComponent),
        sprite: std.ArrayList(SpriteComponent),
        position: std.ArrayList(PositionComponent),
    } = undefined,

    pub fn init(self: *Register, allocator: std.mem.Allocator) void {
        self.entities = std.ArrayList(usize).init(allocator);
        self.components = .{
            .transform = std.ArrayList(TransformComponent).init(allocator),
            .velocity = std.ArrayList(VelocityComponent).init(allocator),
            .sprite = std.ArrayList(SpriteComponent).init(allocator),
            .position = std.ArrayList(PositionComponent).init(allocator),
        };
    }

    pub fn deinit(self: *Register) void {
        self.entities.deinit();
        self.components.transform.deinit();
        self.components.velocity.deinit();
        self.components.sprite.deinit();
        self.components.position.deinit();
    }

    pub fn addEntity(self: *Register) !usize {
        const id = self.entities.items.len + 1;
        std.debug.print("\nAdd entity w/ ID: {}\n", .{id});

        try self.entities.append(id);
        return id;
    }

    pub fn addComponent(self: *Register, data: ComponentUnion) !void {
        // TODO: add functionality to ignore dupes
        switch (data) {
            .transform => {
                std.debug.print("Adding transform component with entity id: {}\n", .{data.transform.entityId});
                try self.components.transform.append(data.transform);
            },
            .velocity => {
                std.debug.print("Adding velocity component with entity id: {}\n", .{data.velocity.entityId});
                try self.components.velocity.append(data.velocity);
            },
            .sprite => {
                std.debug.print("Adding sprite component with entity id: {}\n", .{data.sprite.entityId});
                try self.components.sprite.append(data.sprite);
            },
            .position => {
                std.debug.print("Adding sprite component with entity id: {}\n", .{data.position.entityId});
                try self.components.position.append(data.position);
            },
        }
    }

    pub fn getComponentByEntity(self: *Register, entityId: u16, component: ComponentTypes) ?ComponentUnion {
        switch (component) {
            .transform => {
                for (self.components.transform.items) |item| {
                    if (item.entityId == entityId) {
                        return ComponentUnion{ .transform = item };
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
            .position => {
                for (self.components.position.items) |item| {
                    if (item.entityId == entityId) {
                        return ComponentUnion{ .position = item };
                    }
                }
            },
        }
        return null;
    }

    pub fn getAllComponentsByType(self: *Register, comptime T: type) ?[](T) {
        std.debug.print("Type: {}", .{T});
        switch (T) {
            TransformComponent => {
                return self.components.transform.items;
            },
            VelocityComponent => {
                return self.components.velocity.items;
            },
            SpriteComponent => {
                return self.components.sprite.items;
            },
            PositionComponent => {
                return self.components.position.items;
            },
            else => {
                std.debug.print("Whoops", .{});
            },
        }
        return null;
    }
};
