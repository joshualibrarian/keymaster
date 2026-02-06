// ============================================
// KeyMaster - OpenSCAD 3D Model
// Hardware Password Manager and Data Vault
// ============================================
//
// Face A (bottom): Recessed capacitive keypad (3x4)
// Face B (top): E-paper display with LED illumination on sides
// Top edge (short): Keychain hole centered
// Bottom edge (short): USB-C Port A centered
// Right edge (long): USB-C Port B + MicroSD slot near top

/* [Main Dimensions] */
width = 50;          // X dimension (short edges)
length = 75;         // Y dimension (long edges)
thickness = 15;      // Z dimension
corner_radius = 4;
wall = 2.5;
edge_chamfer = 0.6;

/* [Display - Face B (top)] */
display_margin = 5;
display_recess = 1.2;
display_top_margin = 12;  // Extra space at top for keychain hole area

/* [Keypad - Face A (bottom)] */
key_cols = 3;
key_rows = 4;
key_diameter = 11;
key_depth = 2;
key_spacing = 13;
key_chamfer = 0.5;

/* [USB-C Ports] */
usbc_width = 9;
usbc_height = 3.2;
usbc_depth = 8;
usbc_radius = 1.2;

/* [MicroSD Slot] */
sd_width = 12;
sd_height = 2;
sd_depth = 4;

/* [Keychain Attachment] */
keychain_hole_d = 5;
keychain_inset = 10;  // From top edge

/* [Display LEDs] */
led_diameter = 2.5;
led_depth = 1.5;

/* [Shell Construction] */
split_height = 6;
seam_width = 0.3;

/* [Render Quality] */
$fn = 60;

// ============================================
// Calculated values
// ============================================
display_width = width - display_margin * 2;
display_height = length - display_margin - display_top_margin;
display_offset_y = (display_margin - display_top_margin) / 2;  // Center accounting for top margin

// ============================================
// Helper Modules
// ============================================

module rounded_box(w, l, h, r) {
    hull() {
        for (x = [-1, 1], y = [-1, 1]) {
            translate([x*(w/2-r), y*(l/2-r), 0])
                cylinder(h=h, r=r);
        }
    }
}

module chamfered_rounded_box(w, l, h, r, chamfer) {
    hull() {
        translate([0, 0, chamfer])
            rounded_box(w, l, 0.01, r);
        translate([0, 0, chamfer])
            rounded_box(w - chamfer*2, l - chamfer*2, h - chamfer*2, r - chamfer);
        translate([0, 0, h - chamfer])
            rounded_box(w, l, 0.01, r);
    }
}

module usbc_cutout() {
    hull() {
        for (x = [-1, 1], z = [-1, 1]) {
            translate([x*(usbc_width/2 - usbc_radius), 0, z*(usbc_height/2 - usbc_radius)])
                rotate([-90, 0, 0])
                    cylinder(h=usbc_depth, r=usbc_radius);
        }
    }
}

module microsd_cutout() {
    hull() {
        cube([sd_width, 0.1, sd_height], center=true);
        translate([0, sd_depth, 0])
            cube([sd_width - 1, 0.1, sd_height - 0.5], center=true);
    }
}

// ============================================
// Keypad (Face A - Bottom)
// ============================================

module single_key() {
    union() {
        cylinder(h=key_depth + 1, d=key_diameter);
        translate([0, 0, key_depth])
            cylinder(h=key_chamfer + 0.1, d1=key_diameter, d2=key_diameter + key_chamfer*2);
    }
}

module keypad_array() {
    for (col = [0:key_cols-1], row = [0:key_rows-1]) {
        x = (col - (key_cols-1)/2) * key_spacing;
        y = ((key_rows-1)/2 - row) * key_spacing;
        translate([x, y, -1])
            single_key();
    }
}

// ============================================
// Display Window (Face B - Top)
// ============================================

module display_recess() {
    translate([0, display_offset_y, thickness - display_recess])
        linear_extrude(display_recess + 0.1)
            offset(r=3) offset(r=-3)
                square([display_width, display_height], center=true);
}

module display_leds() {
    // LEDs on LEFT and RIGHT sides of the display (to illuminate it)
    // Positioned at vertical center of display
    led_y = display_offset_y;

    // Left LED - on left edge of display
    translate([-(display_width/2 - 3), led_y, thickness - led_depth])
        cylinder(h=led_depth + 0.1, d=led_diameter);

    // Right LED - on right edge of display
    translate([(display_width/2 - 3), led_y, thickness - led_depth])
        cylinder(h=led_depth + 0.1, d=led_diameter);
}

// ============================================
// Edge Features
// ============================================

module bottom_edge_usb() {
    // USB-C Port A - centered on bottom short edge, centered on thickness
    translate([0, -length/2, thickness/2])
        rotate([90, 0, 180])
            usbc_cutout();
}

module right_edge_features() {
    // USB-C Port B - on right long edge, near top, centered on thickness
    usb_y_pos = length/2 - 18;
    translate([width/2, usb_y_pos, thickness/2])
        rotate([0, 0, 90])
        rotate([90, 0, 0])
            usbc_cutout();

    // MicroSD slot - below the USB port, centered on thickness
    sd_y_pos = length/2 - 30;
    translate([width/2, sd_y_pos, thickness/2])
        rotate([0, 0, 90])
            microsd_cutout();
}

module keychain_hole() {
    // Centered on top edge, properly inset
    hole_y = length/2 - keychain_inset;

    // Main through hole
    translate([0, hole_y, -1])
        cylinder(h=thickness + 2, d=keychain_hole_d);

    // Countersink bottom
    translate([0, hole_y, -0.1])
        cylinder(h=1.5, d1=keychain_hole_d + 3, d2=keychain_hole_d);

    // Countersink top
    translate([0, hole_y, thickness - 1.3])
        cylinder(h=1.5, d1=keychain_hole_d, d2=keychain_hole_d + 3);
}

// ============================================
// Shell Construction
// ============================================

module shell_seam_line() {
    difference() {
        translate([0, 0, split_height])
            rounded_box(width + 0.1, length + 0.1, seam_width, corner_radius);
        translate([0, 0, split_height - 0.1])
            rounded_box(width - seam_width*2, length - seam_width*2, seam_width + 0.2, corner_radius - seam_width);
    }
}

// ============================================
// Complete Assembly
// ============================================

module keymaster_body() {
    difference() {
        chamfered_rounded_box(width, length, thickness, corner_radius, edge_chamfer);
        translate([0, 0, wall])
            rounded_box(width - wall*2, length - wall*2, thickness - wall*2, corner_radius - wall);
    }
}

module keymaster_complete() {
    difference() {
        keymaster_body();

        // Face A (bottom) - Keypad
        keypad_array();

        // Face B (top) - Display
        display_recess();
        display_leds();

        // Edges
        bottom_edge_usb();
        right_edge_features();
        keychain_hole();

        // Shell seam
        shell_seam_line();
    }
}

// ============================================
// Split Shells
// ============================================

module lower_shell() {
    intersection() {
        keymaster_complete();
        translate([0, 0, -50])
            cube([200, 200, 100 + split_height], center=true);
    }
}

module upper_shell() {
    intersection() {
        keymaster_complete();
        translate([0, 0, 50 + split_height])
            cube([200, 200, 100], center=true);
    }
}

// ============================================
// Render
// ============================================

color("DimGray") keymaster_complete();

// === Other views ===
// rotate([180, 0, 0]) color("DimGray") keymaster_complete();  // Keypad side
// color("DimGray") lower_shell();  // Lower shell only
// color("Silver") translate([0, 0, 20]) upper_shell();  // Exploded
