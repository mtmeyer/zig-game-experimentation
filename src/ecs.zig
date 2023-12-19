const std = @import("std");

// Way to instantiate entity register

pub const Register = struct {
    const Self = @This();
    entities: std.ArrayList(u16),

    pub fn init(allocator: std.mem.Allocator) Register {
        return initRegister(allocator);
    }

    pub fn deinit(self: Self) void {
        self.entities.deinit();
    }

    pub fn add() u16 {
        std.debug.print("Add entity");
        return 15;
    }
};

fn initRegister(allocator: std.mem.Allocator) Register {
    var entities = std.ArrayList(u16).init(allocator);

    return Register{ .entities = entities };
}

// Way to instantiate new list of components
