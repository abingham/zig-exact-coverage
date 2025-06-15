const std = @import("std");
const testing = std.testing;
const ArrayList = std.ArrayList;
const assert = std.debug.assert;
const Node = @import("node.zig").Node;
const Matrix = @import("matrix.zig").Matrix;
const Index = @import("matrix.zig").Index;

const DLXError = error{
    InvalidStateError,
};

fn solve(header: *Node, solution: *ArrayList(usize)) !bool {
    if (header.right == header) {
        // Done
        return true;
    }

    // Loop over the columns
    const min_col = try find_min_col(header);

    if (min_col.count == 0) {
        return false;
    }

    // Loop over the rows in the column.
    var row = min_col.down;
    while (row != min_col) : (row = row.down) {
        try solution.append(row.id);

        // Cover each column in the selected row.
        var node = row;
        while (true) : (node = node.right) {
            cover(node);
            if (node.right == row) {
                break;
            }
        }
        const solved = try solve(header, solution);
        if (solved) {
            return true;
        }

        // Uncover each column in the selected row.
        node = row.left;
        while (true) : (node = node.left) {
            uncover(node);
            if (node.left == row) {
                break;
            }
        }

        if (solution.pop() == null) {
            return error.InvalidStateError;
        }
    }
    return false;
}

fn find_min_col(header_node: *Node) !*Node {
    var column_node = header_node.right;

    assert(column_node != header_node);
    if (column_node == header_node) {
        return error.InvalidStateError;
    }

    var min_count: usize = column_node.count;
    var min_col_node: *Node = column_node;

    while (column_node != header_node) : (column_node = column_node.right) {
        if (column_node.count <= min_count) {
            min_count = column_node.count;
            min_col_node = column_node;
        }
    }

    assert(min_col_node != header_node);
    return min_col_node;
}

// 'cover' means to remove a column from all future consideration.
//
// For each row that the column includes, we remove each node from its corresponding column.
// We also remove the column itself from the header.
fn cover(in_node: *Node) void {
    const column = in_node.column;

    // Remove the column from the header
    column.left.right = column.right;
    column.right.left = column.left;

    // For each row in the column.
    var row = column.down;
    while (row != column) : (row = row.down) {

        // for each entry in the row *except that in the column itself*
        var node = row.right;
        while (node != row) : (node = node.right) {
            node.up.down = node.down;
            node.down.up = node.up;
        }
    }
}

// 'uncover' reverses the action of 'cover'.
//
// TODO: This is as literally the reverse of cover as I can think to make it. Does
// it really need to be this way? I'm sure it works well as is, but does it
// really need to be so literally reversed? Understand things better.
fn uncover(in_node: *Node) void {
    const column = in_node.column;

    // For each row in the column.
    var row = column.up;
    while (row != column) : (row = row.up) {

        // for each entry in the row
        var node = row;
        while (true) : (node = node.left) {
            node.up.down = node;
            node.down.up = node;

            // If the next node in the iteration is the initial row node, then break.
            if (node.left == row) break;
        }
    }

    // Add the column back in to the header
    column.left.right = column;
    column.right.left = column;
}

test "basic matrix" {
    // var matrix = try Matrix.init(3);
    // defer matrix.deinit();
    //
    // // 0 1 1
    // // 1 1 0
    // // 1 0 0
    //
    // try matrix.set(.{ .row = 0, .col = 1 });
    // try matrix.set(.{ .row = 0, .col = 2 });
    //
    // try matrix.set(.{ .row = 1, .col = 0 });
    // try matrix.set(.{ .row = 1, .col = 1 }); t
    //
    // try matrix.set(.{ .row = 2, .col = 0 });
    //
    // var general_purpose_allocator: std.heap.GeneralPurposeAllocator(.{}) = .init;
    // const gpa = general_purpose_allocator.allocator();
    // var solution = ArrayList(usize).init(gpa);
    // const solved = try solve(matrix.header, &solution);
    // try testing.expect(solved);
}
