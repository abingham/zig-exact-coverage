const node = @import("node.zig");
const Node = node.Node;

const std = @import("std");
const testing = std.testing;
const assert = std.debug.assert;
const DLXError = error{NodeNotFoundError};

pub const Index = struct {
    row: usize,
    col: usize,

    pub fn create(row: usize, col: usize) Index {
        return Index{ .row = row, .col = col };
    }
};

pub const Matrix = struct {
    header: *Node,
    columns: []Node,
    arena: std.heap.ArenaAllocator,

    pub fn init(num_cols: usize) !Matrix {
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);

        var columns = try arena.allocator().alloc(Node, num_cols);

        var header = try arena.allocator().create(Node);
        header.* = Node.init();
        header.right = &columns[0];
        header.left = &columns[num_cols - 1];
        header.up = header;
        header.down = header;
        header.column = header;

        var index: usize = 0;
        while (index < num_cols) : (index += 1) {
            columns[index] = Node{
                .up = &columns[index],
                .down = &columns[index],
                .left = if (index == 0) header else &columns[index - 1],
                .right = if (index == num_cols - 1) header else &columns[index + 1],
                .column = &columns[index],
                .count = 0,
                .id = index,
            };
        }
        return .{ .header = header, .columns = columns, .arena = arena };
    }

    pub fn deinit(self: Matrix) void {
        self.arena.deinit();
    }

    /// Determine if the matrix is set at a particular index
    pub fn get(self: Matrix, index: Index) bool {
        // Find the relevant column
        const col_node = &self.columns[index.col];

        // Look at each row in the column
        var row_node = col_node.down;
        while (row_node != col_node) : (row_node = row_node.down) {
            // If we find a row with the same id as the index, we found a match.
            if (row_node.id == index.row) {
                return true;
            }

            // If we find a row with and id greater than the index, break out of the loop
            if (row_node.id > index.row) {
                break;
            }
        }

        // If we found nothing return false.
        return false;
    }

    /// Ensure that row_index/col_index is included in the matrix.
    pub fn set(self: *Matrix, index: Index) !void {
        const col = &self.columns[index.col];
        var row = col.down;
        while (row != col) : (row = row.down) {
            // See if the location is already set.
            if (row.id == index.row) {
                return;
            }

            // If we encounter a row node with id > than row_index, we insert above it.
            if (row.id > index.row) {
                break;
            }
        }

        var new_node: *Node = try self.arena.allocator().create(Node);
        new_node = Node.init();
        new_node.up = row.up;
        new_node.down = row;
        new_node.column = row.column;
        new_node.id = index.row;
        new_node.count = 0;

        // initially the node refers to itself in the row.
        new_node.left = new_node;
        new_node.right = new_node;

        const left = self.find_left(index) catch new_node;
        new_node.left = left;
        new_node.right = left.right;
        left.right.left = new_node;
        left.right = new_node;

        row.up.down = new_node; 
        row.up = new_node;
    }

    /// Find the node that should be the 'left' of the node at col_index/row_index.
    fn find_left(self: *Matrix, index: Index) !*Node {
        const start_col = &self.columns[index.col];
        var column = start_col.left;
        while (column != start_col) : (column = column.left) {
            var row = column.down;
            while (row != column) : (row = row.down) {
                if (row.id == index.row) {
                    return row;
                } else if (row.id > index.row) {
                    break;
                }
            }
        }

        return error.NodeNotFoundError;
    }
};

test "basic structure after initialization" {
    const num_cols: usize = 10;
    const matrix = try Matrix.init(num_cols);
    defer matrix.deinit();
    try testing.expect(matrix.columns.len == num_cols);

    try testing.expect(matrix.header.right == &matrix.columns[0]);
    try testing.expect(matrix.header.left == &matrix.columns[num_cols - 1]);
    try testing.expect(matrix.header.up == matrix.header);
    try testing.expect(matrix.header.id == 0);
    try testing.expect(matrix.header.column == matrix.header);

    var col: usize = 0;
    while (col != num_cols) : (col += 1) {
        const col_node = &matrix.columns[col];
        try testing.expect(col_node.up == col_node);
        try testing.expect(col_node.down == col_node);
        try testing.expect(col_node.column == col_node);

        try testing.expect(col_node.left == if (col == 0) matrix.header else &matrix.columns[col - 1]);
        try testing.expect(col_node.right == if (col == num_cols - 1) matrix.header else &matrix.columns[col + 1]);
    }
}

test "get is false for unset indexes" {
    const num_cols = 10;
    const num_rows = 10;
    const matrix = try Matrix.init(num_cols);
    defer matrix.deinit();

    var col: usize = 0;
    while (col != num_cols) : (col += 1){
        var row: usize = 0;
        while (row != num_rows) : (row += 1) {
            try testing.expect(!matrix.get(Index.create(row, col)));
        }
    }
}

test "structure after set r0, c0" {
    var matrix = try Matrix.init(10);
    defer matrix.deinit();

    try matrix.set(Index.create(0, 0));

    const inserted = matrix.columns[0].down;

    try testing.expect(matrix.columns[0].down == inserted);
    try testing.expect(matrix.columns[0].up == inserted);
    try testing.expect(matrix.columns[0].down.up == &matrix.columns[0]);
    try testing.expect(matrix.columns[0].up.down == &matrix.columns[0]);

    try testing.expect(inserted.up == &matrix.columns[0]);
    try testing.expect(inserted.down == &matrix.columns[0]);
    try testing.expect(inserted.down.up == inserted);
    try testing.expect(inserted.up.down == inserted);
}

test "structure after set r0,c0 followed by r4,c0" {
    var matrix = try Matrix.init(10);
    defer matrix.deinit();

    try matrix.set(Index.create(0, 0));
    try matrix.set(Index.create(4, 0));

    const col = &matrix.columns[0];
    const in1 = col.down;
    const in2 = in1.down;

    try testing.expect(col.down == in1);
    try testing.expect(col.up == in2);
    try testing.expect(col.up.down == col);
    try testing.expect(col.down.up == col);

    try testing.expect(in1.down == in2);
    try testing.expect(in1.up == col);
    try testing.expect(in1.up.down == in1);
    try testing.expect(in1.down.up == in1);

    try testing.expect(in2.down == col);
    try testing.expect(in2.up == in1);
    try testing.expect(in2.up.down == in2);
    try testing.expect(in2.down.up == in2);
}

test "structure after set r3,c1 followed by r3,c6" {
    var matrix = try Matrix.init(10);
    defer matrix.deinit();

    try matrix.set(Index.create(3, 1));
    try matrix.set(Index.create(3, 6));

    const c1 = &matrix.columns[1];
    const in1 = c1.down;

    const c2 = &matrix.columns[6];
    const in2 = c2.down;

    try testing.expect(c1.down == in1);
    try testing.expect(c1.up == in1);
    try testing.expect(in1.down == c1);
    try testing.expect(in1.up == c1);
    try testing.expect(in1.down == c1);

    try testing.expect(c2.down == in2);
    try testing.expect(c2.up == in2);
    try testing.expect(in2.down == c2);
    try testing.expect(in2.up == c2);
    try testing.expect(in2.down == c2);

    try testing.expect(in1.right == in2);
    try testing.expect(in1.left == in2);
    try testing.expect(in2.right == in1);
    try testing.expect(in2.left == in1);
}

test "get is true for a set index" {
    var matrix = try Matrix.init(10);
    defer matrix.deinit();

    var index = Index.create(0, 0);
    try matrix.set(index);

    try testing.expect(matrix.get(index));

    index = Index.create(2, 5);
    try matrix.set(index);

    try testing.expect(matrix.get(index));
}
