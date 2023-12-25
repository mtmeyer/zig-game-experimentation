const std = @import("std");

// Way to instantiate entity register

pub const Register = struct {
    const Self = @This();
    entities: std.ArrayList(u16),

    pub fn init(allocator: std.mem.Allocator) Register {
        var entities = std.ArrayList(u16).init(allocator);

        return Register{ .entities = entities };
    }

    pub fn deinit(self: Self) void {
        self.entities.deinit();
    }

    pub fn add(self: *Register) !u16 {
        var rand = std.rand.DefaultPrng.init(0);
        const id = rand.random().uintAtMost(u16, 65535);
        std.debug.print("\nAdd entity w/ ID: {}\n", .{id});

        try self.entities.append(id);
        return id;
    }
};

// Way to instantiate new list of components
