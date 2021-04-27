clearScreen.
switch to 0.
//-------------------launch veriables-------------//
set pitchRate to 0.0039.
set landMode to "RTLS".
//-----------------------------------------------//
set step to "launch".
set vdeg to 90.
set shipPitch to 90.
set shipHed to 90.
//-----------------------------------------------//
set STEERINGMANAGER:ROLLTS to 50.
function launch{
   TOGGLE AG4.
    WAIT 5.
    lock steering to heading(shipHed,shipPitch).
    lock throttle to 1.
    doSafeStage().
    wait 1.
    stage.
   // setEngineThrustLimit("core",55).
    until alt:radar > 100{updateReadoutslaunch.}.
    set shipHed to 90.
    until ship:apoapsis > 75000{
    updateReadoutslaunch().
    set shipPitch to vdeg.
    set vdeg to vdeg-pitchRate.
    if vdeg < 50 {set shipPitch to 50.} 
    else if vdeg > 50{set shipPitch to vdeg.}
  
    }
}


function BECO{
   // setEngineThrustLimit("core",100).
   set step to "Beco".
   updateReadoutslaunch().
   toggle ag2.
   updateReadoutslaunch().
   toggle ag7.
   wait 1. 
   updateReadoutslaunch(). 
   stage.
    wait 1.
    updateReadoutslaunch().
}
function core{
    until ship:apoapsis > 94000{
    set step to "Core".
    set shipPitch to 10.
    updateReadoutslaunch().
    }

}
function MECO{
     
    set step to "MECO".
    updateReadoutslaunch().
    lock throttle to 0.
    updateReadoutslaunch().
    wait 1.
    toggle ag8.
    updateReadoutslaunch().
    doSafeStage().
    wait 4.
    updateReadoutslaunch().
}

function stage2{
    set step to "Stage 2".
    lock throttle to 1.
    set shipPitch to 10.

    until ship:apoapsis > 140000{updateReadoutslaunch().}.
    lock throttle to 0.
    until eta:apoapsis < 30{updateReadoutslaunch().}.
    lock throttle to 1.
    until ship:periapsis > 105000{updateReadoutslaunch().}.
    lock throttle to 0.
}
function main {
 
  wait 1.
    launch().
    BECO().
    core().
    MECO().
    stage2().
}
main().
//---------------------Global Functions-----------------------//
function updateReadoutslaunch{
Print " FALCON HEAVY LAUNCH CONTROL COMPUTER" at ( 2, 1).
Print "-------------------------------------" at ( 2, 2).
Print "____________________________________" at ( 3, 3).
Print "Status: " + step at ( 3, 4).
PRINT "Altitude: " + Alt:radar at (3,5).
print "land mode: " + LandMode at (3,6).
print "Ship Pitch: " + shipPitch at (3,7).
}


function doAutoStage {
  if not(defined oldThrust) {
    declare global oldThrust to ship:availablethrust.
  }
  if ship:availablethrust < (oldThrust - 10) {
    doSafeStage(). 
    wait 1.
    declare global oldThrust to ship:availablethrust.
  }
}
function setEngineThrustLimit{
  parameter eng.
	parameter engineThrustLimit. // 0 - 100

	for e IN ship:partstagged(eng) { SET e:THRUSTLIMIT TO engineThrustLimit. }.

}
function doSafeStage {
  wait until stage:ready.
  stage.
}

function setThrustTOWeight{
parameter thrToWeight.
lock g to constant:g * body:mass / body:radius^2.
lock thrott to thrToWeight * ship:mass * g / ship:availablethrust.
return thrott.
}