const std = @import("std");
const testing = std.testing;
const ArrayList = std.ArrayList;
const assert = std.debug.assert;

const DLXError = error{
    InvalidStateError,
};

pub const Node = struct {
    up: *Node,
    down: *Node,
    left: *Node,
    right: *Node,
    column: *Node,
    id: usize,
    count: usize,

    // pub fn init(x: f32, y: f32, z: f32) Vec3 {
    //     return Vec3{
    //         .x = x,
    //         .y = y,
    //         .z = z,
    //     };
    // }
    //
    // pub fn dot(self: Vec3, other: Vec3) f32 {
    //     return self.x * other.x + self.y * other.y + self.z * other.z;
    // }
};

fn solve(header: *Node, solution: *ArrayList(usize)) bool {
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
        solution.append(row.id);

        // Cover each column in the selected row.
        var node = row;
        while (true) : (node = node.right) {
            cover(node);
            if (node.right == row) {
                break;
            }
        }

        if (solve(header, solution)) {
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

        solution.pop();
    }
}

fn find_min_col(header: *Node) !*Node {
    var column = header.right;

    assert(column != header);
    if (column == header) {
        return error.InvalidStateError;
    }

    var min_count: usize = std.math.maxInt(usize);
    var min_col: *Node = null;

    while (column != header) : (column = column.right) {
        if (column.count <= min_count) {
            min_count = column.count;
            min_col = column;
        }
    }

    assert(min_col != null);
    assert(min_col != header);
    return min_col;
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
            node.bottom.up = node.up;
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
            node.down.top = node;

            // If the next node in the iteration is the initial row node, then break.
            if (node.left == row) break;
        }
    }

    // Add the column back in to the header
    column.left.right = column;
    column.right.left = column;
}
