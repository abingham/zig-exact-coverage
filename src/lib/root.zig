pub const matrix = @import("matrix.zig");
pub const solver = @import("solver.zig");

test {
    @import("std").testing.refAllDecls(@This());
}
