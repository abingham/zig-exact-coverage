const std = @import("std");
const testing = std.testing;
const ArrayList = std.ArrayList;
const Matrix = struct { nrows: usize, ncols: usize, data: ArrayList(u8) };

// TODO: Try following the init/deinit pattern used by ArrayList

pub fn make_matrix(nrows: usize, ncols: usize, allocator: std.mem.Allocator) !Matrix {
    var list = ArrayList(u8).init(allocator);
    try list.resize(nrows * ncols);
    return Matrix{ .nrows = nrows, .ncols = ncols, .data = list };
}

pub fn free_matrix(matrix: Matrix) void {
    matrix.data.deinit();
}

pub fn set(matrix: *Matrix, row: usize, col: usize, value: u8) void {
    const offset = row * matrix.ncols + col;
    matrix.data.items[offset] = value;
}

test "basic make_matrix" {
    const allocator = std.heap.page_allocator;
    const matrix = try make_matrix(100, 100, allocator);
    defer free_matrix(matrix);
    try testing.expect(matrix.ncols == 100);
    try testing.expect(matrix.nrows == 100);
    try testing.expect(matrix.data.items.len == 10000);
}

test "set value" {
    const allocator = std.heap.page_allocator;
    var matrix = try make_matrix(100, 100, allocator);
    defer free_matrix(matrix);
    set(&matrix, 2, 2, 42);
    try testing.expect(matrix.data.items[2 * matrix.ncols + 2] == 42);
}
