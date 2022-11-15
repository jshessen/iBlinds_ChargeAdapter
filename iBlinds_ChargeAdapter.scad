/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
&&  iBlinds_ChargeAdapter: iBlinds_ChargeAdapter.scad

        Copyright (c) 2022, Jeff Hessenflow
        All rights reserved.
        
        https://github.com/jshessen/iBlinds_ChargeAdapter
      
        Parametric OpenSCAD file in support of the "iBlinds_ChargeAdapter"
        https://www.thingiverse.com/thing:???
&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
&&  GNU GPLv3
&&
This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program. If not, see <https://www.gnu.org/licenses/>.
&&
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/





/*?????????????????????????????????????????????????????????????????
??
/*???????????????????????????????????????????????????????
?? Section: Customizer
??
    Description:
        The Customizer feature provides a graphic user interface for editing model parameters.
??
???????????????????????????????????????????????????????*/
/* [Global] */
// Display Verbose Output?
$VERBOSE=1; // [0:No,1:Level=1,2:Level=2,3:Developer]

/* [Headrail Access Parameters] */
// Headrail Opening Width
headrail_width=15.8;        // [10:0.01:20]
// Headrail Wall Thickness
wall=2.25;         // [1:0.01:4]

/* [Adapter Plate Parameters] */
// Adapter Plate Width
plate_width=23.31;          // [15:0.01:30]
// Adapter Plate Depth/Height
plate_depth=19;             // [15:0.01:30]

/* [USB Access Parameters] */
// USB Access Width
usb_width=8.8;              // [6:0.1:10]
// USB Access Depth
usb_depth=3.9;              // [2:0.1:5]

/* [Button Access Parameters] */
// Button Access Diameter
button_diameter=6.2;        // [4:0.1:8]

/* [Latch Mechanism Parameters] */
// Latch Depth
latch_depth=3;              // [1:0.1:5]
// Latch Height
latch_height=11.5;          // [8:0.1:15]
// Latch "Hook" Depth
step_size=1.2;              // [0:0.1:2]
// Number of "Hooks"
steps=6;                    // [0:8]

/* [Advanced] */
// Adapter Plate Bevel
bevel=1.45;                 // [0:0.01:2]
// USB/Latch Inset to accomodate adapter case
inset=2.7;                  // [0:0.1:5]
/*
?????????????????????????????????????????????????????????????????*/





/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Section: Defined/Derived Variables
*/
/* [Hidden] */
base_offset=wall+bevel-0.2;
headrail_depth=plate_depth+base_offset;
/*
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/





/*/////////////////////////////////////////////////////////////////
// Section: Modules
*/
/*///////////////////////////////////////////////////////
// Module: make_ChargeAdapterClip()
//
    Description:
        Wrapper module to create Charge Adapter object

    Arguments:
        N/A
*/
// Example: Make sample objects
   make_ChargeAdapterClip();
///////////////////////////////////////////////////////*/
module make_ChargeAdapterClip(){
    difference(){
        union(){
            if($VERBOSE) echo("--> Make \"External\" Headrail Structure");
            clip_plate(plate_width,plate_depth,bevel);
            if($VERBOSE) echo("--> Make \"Internal\" Headrail Structure");
            translate([0,0,bevel])
                    headrail_insert(headrail_width,headrail_depth,wall, base_offset);
                translate([0,wall/2,(headrail_depth/3)/2+bevel])
                    cube([headrail_width,wall,headrail_depth/3], center=true);
            if($VERBOSE) echo("--> Make \"Latch\" Structures");
            translate([0,wall+inset-step_size/4,0])
                latch(headrail_width,latch_depth,latch_height, steps,step_size);
            translate([0,wall+inset+2.4+usb_depth+button_diameter*.9,0])
                rotate(180) latch(headrail_width,button_diameter/2,latch_height, steps,step_size);
        }
        if($VERBOSE) echo("--> Create USB/Button Access");
        translate([0,wall+inset,bevel+wall]){
            usb_access(usb_width,usb_depth, latch_height);
            translate([0,usb_depth+1,0])
                button_access(button_diameter, latch_height);
        }
        if($VERBOSE) echo("--> Clean-Up \"Latch\" Structures");
        difference(){
            translate([0,plate_depth/2+wall,bevel+latch_height/2])
                cube([plate_width,plate_depth,latch_height], center=true);
            translate([0,0,bevel]) scale([1,1,latch_height/wall])
                headrail_insert(headrail_width,headrail_depth,wall, base_offset);
        }
    }
}



/*///////////////////////////////////////////////////////
// Module: clip_plate()
//
    Description:
        Creates external headrail structure

    Parameter(s):
        x   =   width
        y   =   depth

        b   =   bevel height
*/
// Example: Make sample object
//  clip_plate(plate_width,plate_depth,bevel);
///////////////////////////////////////////////////////*/
module clip_plate(x,y, b) {
    bevel_offset=2;
    ext=0.1;
    
    translate([0,y/2,0]){
        difference(){
            hull(){
                if($VERBOSE>1) echo("-----> Create simple cube(s) with rounded corners along the X-axis");
                linear_extrude(ext) offset(r=bevel_offset, $fn=360)
                    square([x-(bevel_offset*3),y-(bevel_offset*3)], center=true);
                translate([0,0,b])
                    linear_extrude(ext) offset(r=bevel_offset, $fn=360)
                        square([x-(bevel_offset*2),y-(bevel_offset*2)], center=true);
                
                if($VERBOSE>1) echo("-----> Create simple cube(s) with rounded corners along the Y-axis");
                translate([0,-(y/2-ext)-b,(y*0.4)-b]) {
                    rotate([-90,0,0]) {
                        linear_extrude(ext) offset(r=bevel_offset, $fn=360)
                            square([x-(bevel_offset*3),y*0.3], center=true);
                        translate([0,0,b]) {
                            linear_extrude(ext) offset(r=bevel_offset, $fn=360)
                                square([x-(bevel_offset*2),y*0.4], center=true);
                        }
                    }
                }
            }
            if($VERBOSE>2) echo("-----> Clean-Up merged structures");
            translate([0,0,(y*0.35+4*b)/2+b])
                cube([x+ext,y,y*0.35+4*b], center=true);
        }
    }
}
/*///////////////////////////////////////////////////////
// Module: headrail_insert()
//
    Description:
        Creates internal headrail structure

    Parameter(s):
        x       =   width
        y       =   depth
        z       =   height

        base    =   base offset
*/
// Example: Make sample object
//  headrail_insert(headrail_width,headrail_depth,wall, base_offset);
///////////////////////////////////////////////////////*/
module headrail_insert(x,y,z, base){
    translate([0,z-0.00001,-0.00001]){
        difference(){
            union(){
                if($VERBOSE>1) echo("-----> Create simple cube \"insert\" structure");
                translate([0,(base-z)/2,z/2])
                    cube([x,base+z,z], center=true);
                if($VERBOSE>1) echo("-----> Create simple oval \"insert\" structure");
                translate([0,base,z/2])
                    scale([1,y/x,1]) cylinder(h=z,d=x, center=true, $fn=360);
            }
            if($VERBOSE>1) echo("-----> Create \"Button\" lever access");
            translate([0,-(z*3),z/2]) 
                cube([x,z*4,(z*1.1)], center=true);
        }
    }
}

/*///////////////////////////////////////////////////////
// Module: usb_access()
//
    Description:
        Creates USB access

    Parameter(s):
        x       =   width
        y       =   depth
        z       =   height
*/
// Example: Make sample object
//  usb_access(usb_width,usb_depth, latch_height);
///////////////////////////////////////////////////////*/
module usb_access(x,y,z) {
    translate([0,y/2,z/3])
        cube([x,y,z*2], center=true);
    translate([0,0,z/2])
        cube([x,y,z], center=true);
}
/*///////////////////////////////////////////////////////
// Module: button_access()
//
    Description:
        Create Button access

    Parameter(s):
        d       =   diameter
        z       =   height
*/
// Example: Make sample object
//  button_access(button_diameter, latch_height);
///////////////////////////////////////////////////////*/
module button_access(d,z) {
    translate([0,d/2,z/3])
        cylinder(h=z*2,d=d, center=true, $fn=360);
    translate([0,d,z/2])
        cube([d*0.8,d*0.8,z], center=true);
}
/*///////////////////////////////////////////////////////
// Module: latch()
//
    Description:
        Creates internal headrail structure

    Parameter(s):
        x       =   width
        y       =   depth
        z       =   height

        base    =   base offset
*/
// Example: Make sample object
//  latch(headrail_width,latch_depth,latch_height, steps,step_size);
///////////////////////////////////////////////////////*/
module latch(x,y,z, steps, latch) {
    ext=0.1;
    
    difference(){
        if($VERBOSE>1) echo("-----> Create \"latch\" structure");
        translate([0,y/2,z/2])
            cube([x*0.99,y,z], center=true);
        if($VERBOSE>1) echo("-----> Notch \"latch\" structure");
        for(i=[0:steps] ){
            if($VERBOSE>2) echo(str("--------> Notch \"latch\" structure: ",i));
            translate([-(x+ext)/2,latch,z-(i*latch)+ext]) rotate([180,0,0])
                prism(x+ext,latch+ext,latch+ext);
        }
    }
}



// https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Primitive_Solids#polyhedron
module prism(l, w, h){
    polyhedron(//pt 0        1        2        3        4        5
        points=[[0,0,0], [l,0,0], [l,w,0], [0,w,0], [0,w,h], [l,w,h]],
        faces=[[0,1,2,3],[5,4,3,2],[0,4,5,1],[0,3,4],[5,2,1]]
        );
}