// Chaos Clock
// Developed by: Michael McCool
// Copyright 2018 
include <tols.scad>
include <smooth_model.scad>
//include <smooth_make.scad>
include <bolt_params.scad>
use <bolts.scad>

explode = 3;
plate_h = 3;

//sm = 4*sm_base;
sm = sm_base;

bearing_R = 8/2;
bearing_r = 4/2;
bearing_h = 3;
bearing_fr = 9.2/2;
bearing_fh = 0.55;
bearing_sm = 5*sm;

washer_h = 0.5;
washer_R = 6/2;
washer_r = 4/2;
washer_sm = 5*sm;

ball_r = plate_h/2;
ball_sm = 5*sm;

mag_r = 3/2;
mag_h = 1;
mag_t = 0.05;
mag_n = 3;
mag_sm = 5*sm;

rotor_r = bearing_r;
rotor_R = 50/2;
rotor_mag_s = 1;
rotor_mag_xo = rotor_R - mag_r - rotor_mag_s;
rotor_h = plate_h;
rotor_sm = 10*sm;
rotor_n = 5;

pendulum_L1 = rotor_R + 50;
pendulum_R1 = bearing_R + 2;
pendulum_r = 20/2;
pendulum_s = 1;
pendulum_Wr = pendulum_r + ball_r + pendulum_s;
pendulum_n = 10;
pendulum_R2 = pendulum_Wr + pendulum_s;
pendulum_L2 = rotor_R + 45 - pendulum_R2;

module ball() {
  sphere(r=ball_r,$fn=ball_sm);
}

module bearing (flange=false) {
  color([0.25,0.25,0.5,1]) {
    difference() {
      union() {
        cylinder(r=bearing_R,h=bearing_h,$fn=bearing_sm);
        if (flange) cylinder(r=bearing_fr,h=bearing_fh,$fn=bearing_sm);
      }
      translate([0,0,-1])
        cylinder(r=bearing_r,h=bearing_h+2,$fn=bearing_sm);
    }
  }
}

module mag() {
  color([0.5,0.5,0.5,1]) {
    cylinder(r1=mag_r-mag_t,r2=mag_r,h=mag_t,$fn=mag_sm);
    translate([0,0,mag_t]) cylinder(r=mag_r,h=mag_h-2*mag_t,$fn=mag_sm);
    translate([0,0,mag_h-mag_t]) cylinder(r1=mag_r,r2=mag_r-mag_t,h=mag_t,$fn=mag_sm);
  }
}

module mag_stack() {
  for (i = [0:mag_n-1]) {
    translate([0,0,i*(mag_h+explode/10)]) mag();
  }
}

module washer () {
  color([0.25,0.5,0.25,1]) {
    difference() {
      cylinder(r=washer_R,h=washer_h,$fn=washer_sm);
      translate([0,0,-1])
        cylinder(r=washer_r,h=washer_h+2,$fn=washer_sm);
    }
  }
}

module rotor_slice() {
  difference() {
    hull() {
      circle(r=rotor_R,$fn=rotor_sm);
      translate([0,-pendulum_L1,0]) circle(r=pendulum_R1,$fn=rotor_sm);
    }
    // main shaft hole
    circle(r=rotor_r,$fn=rotor_sm);
    // secondary pendulum shaft hole
    translate([0,-pendulum_L1,0]) circle(r=bearing_R,$fn=rotor_sm);
    // magnet holes
    for (i = [0:rotor_n-1]) {
      rotate(90+i*360/rotor_n) 
        translate([rotor_mag_xo,0]) 
           circle(r=mag_r,$fn=mag_sm);
    }
  }
}

module rotor() {
  color([0.75,0.70,0.05,1]) {
    linear_extrude(plate_h) {
      rotor_slice();
    }
  }
}

module pendulum_slice() {
  difference() {
    union() {
      hull() {
        circle(r=pendulum_R1,$fn=rotor_sm);
        translate([0,-pendulum_L2,0]) circle(r=pendulum_R1,$fn=rotor_sm);
      }
      translate([0,-pendulum_L2,0]) circle(r=pendulum_R2,$fn=rotor_sm);
    }
    // shaft hole
    circle(r=rotor_r,$fn=rotor_sm);
    // ball holes (jam fit; for weight)
    translate([0,-pendulum_L2,0]) 
      for (i = [0:pendulum_n-1]) {
        rotate(90+i*360/pendulum_n) 
          translate([pendulum_r,0,0]) 
            circle(r=ball_r,$fn=ball_sm);
      } 
  }
}

module pendulum() {
  color([0.70,0.70,0.05,1]) {
    linear_extrude(plate_h) {
      pendulum_slice();
    }
  }
}

module rotor_mags() {
  for (i = [0:rotor_n-1]) {
    rotate(90+i*360/rotor_n) 
      translate([rotor_mag_xo,0,0]) 
           mag_stack();
  } 
}

a1 = 15;
a2 = 45;

module assembly() {
  bearing();
  translate([0,0,bearing_h + explode]) washer();
  rotate(a1) {
    translate([0,0,bearing_h + washer_h + 2*explode]) rotor();
    translate([0,0,bearing_h + washer_h + 3*explode]) rotor_mags();
    translate([0,-pendulum_L1,bearing_h + washer_h + 4*explode]) bearing();
    translate([0,-pendulum_L1,bearing_h + washer_h + plate_h + 5*explode]) washer();
    translate([0,-pendulum_L1,bearing_h + 2*washer_h + plate_h + 6*explode]) 
      rotate(a2) pendulum();
  }
}

assembly();
//rotor();
//mag_stack();
//pendulum();