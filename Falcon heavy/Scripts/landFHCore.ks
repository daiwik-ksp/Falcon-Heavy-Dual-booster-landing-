clearscreen.
switch to 0.
set landingsite to kerbin:geopositionlatlng(-0.104784247151881,-69.575826141172).
brakes on.				
toggle ag1.
set sLandAlt to 1900.
set radarOffset to 33.2.
////////////////////////////////////////////////////////////////
lock trueRadar to alt:radar - radarOffset.                    
lock g to constant:g * body:mass / body:radius^2.            
lock maxDecel to (ship:availablethrust / ship:mass) - g.    
lock stopDist to ship:verticalspeed^2 / (2 * maxDecel).        
lock idealThrottle to stopDist / trueRadar.                    
lock impactTime to trueRadar / abs(ship:verticalspeed).    
lock aoa to 30.  
lock errorScaling to 1.
/////////////////////////////////////////////////////////////////


RCS on.
lock steering to EntryControl(10.5). 
 until ALT:RADAR < 31000{updateReadoutsLand.}.
    lock throttle to 1.
	RCS off.
    toggle ag5.
 lock aoa to -1.5.
 toggle AG6.
    lock steering to EntryControl(-9.5).
 until ship:verticalspeed > -300{updateReadoutsLand.}.
    lock throttle to 0.
  
    // Landing Burn
when impactTime < 1.5 then {lock steering to up.}
when impactTime < 2.9 then {gear on . preserve.}

until alt:radar < 8000 {
//setHoverPIDLOOPS(). //you can manually set them, but these are some good defaults.
lock steering to EntryControl(30.5).
updateReadoutsLand().   
}.


wait until alt:radar < sLandAlt.
lock throttle to 1.
 until ship:verticalspeed > -210{
lock aoa to 15. 
lock steering to boosterGuidance(). 
 }
  until ship:verticalspeed > -90{
lock aoa to -10. 
lock steering to boosterGuidance(). 
 }
lock throttle to idealThrottle.
toggle ag1.
 until ship:status = "landed"{
     if throttle < 0.6{
        lock aoa to 7.
     }
     else {
        lock aoa to -7.
     }
    
    lock steering to boosterGuidance(). 
 }
lock throttle to 0.
brakes off.
rcs off.
set ship:control:pilotmainthrottle to 0.
shutdown.



function errorVectorG {
    return getImpact():position - landingSite:position.
}
function EntryControl{            
 parameter angle.
 lock aoa to angle.
    local errorVector is errorVectorG().
        local velVector is -ship:velocity:surface.
        local result is velVector + errorVector*1.
        if vang(result, velVector) > aoa
        {
            set result to velVector:normalized
                          + tan(aoa)*errorVector:normalized.
        }
       return lookdirup(result, facing:topvector).
}

function updateReadoutsLand{
Print "FALCON 9 LANDING CONTROL COMPUTER" at ( 2, 1).
Print "-------------------------------------" at ( 2, 2).
Print "____________________________________" at ( 3, 3).
//Print "step: " + step at ( 3, 4).
PRINT "Altitude: " + Alt:radar at (3,5).
print "land mode: ASDS" at (3,6).
//print "Distance to target: " + langoffset at(3,7).
}

function getImpact {
    if addons:tr:hasimpact { return addons:tr:impactpos. }       
        return ship:geoposition.
}

function positioningFunc {
    return getImpact():position - landingsite:position.
}

function boosterGuidance {
    local errorVector is positioningFunc().
    local velVector is -ship:velocity:surface.
    local result is velVector + errorVector * errorScaling.

    if vAng(result, velVector) > aoa {
        set result to velVector:normalized + tan(aoa) * errorVector:normalized.
    }

    return lookDirUp(result, facing:topvector).
}