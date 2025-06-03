pub const matrix = @import("matrix.zig");

test {
    @import("std").testing.refAllDecls(@This());
}
