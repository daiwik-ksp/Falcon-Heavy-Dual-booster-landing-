switch to 0.
clearScreen.
sas off.
wait 1.
lock steering to heading(270,10).
wait 4.
rcs on.
set done  to 1.
//set landingPadB1 to vessel("Lz 1"):geoposition.
//set landingPadB2 to vessel("lz 2"):geoposition.
set landingPadB1 to latlng(-0.18549138101820,-74.4730209803288).
set landingPadB2 to latlng(-0.205735798275871,-74.4733322465625).
set LburnAlt to 1900.
set landingPad to 1.
set landAltitude to 80.
SET minLandVelocity TO 3.

set radarOffsetB1 to 31.6.
set radarOffsetB2 to 31.6.

set STEERINGMANAGER:ROLLTS to 50.
set boosterLandMode to true.
BoosterSep().
SetTrueRadar().
set looping to true.
set controlPart to 1.
set thrott to 0.
lock throttle to thrott.
set shipPitch to 10.
set steeringDir to 90.
SET geoDist TO 1.
set boosterAdjustPitch to 10.
SET boosterAdjustLatOffset TO 0.02. 
SET boosterAdjustLngOffset TO -0.1.// set's the overshot distance
lock errorScaling to 1.
lock aoa to 0.
lock throttle to thrott.
lock steering to heading(steeringDir,shipPitch).

lock g to constant:g * body:mass / body:radius^2.  
SET distMargin TO 1300.
SET maxVertAcc TO (SHIP:AVAILABLETHRUST) / SHIP:MASS - g. 
SET vertAcc TO sProj(SHIP:SENSORS:ACC, UP:VECTOR).
SET dragAcc TO g + vertAcc. 
sET sBurnDist TO (SHIP:VERTICALSPEED^2 / (2 * (maxVertAcc + dragAcc/2)))+distMargin.
SEt ImpactDist TO 1.
      


main().

function BoosterSep{

if isShip("B1"){
set landingPad to landingPadB1.
SET thrott TO 0.
SET SHIP:NAME TO "Booster1".

//kuniverse:forcesetactivevessel(SHIP).

toggle ag1.
}
else if isShip("B2"){
set landingPad to landingPadB2.
SET thrott TO 0.
SET SHIP:NAME TO "Booster2". 
toggle ag1. 
}

}

function Booster1{
	SET commTargetVessel TO VESSEL("Booster2").
    steerToTargetB1(boosterAdjustPitch,boosterAdjustLatOffset,boosterAdjustLngOffset).
	wait 15.
	SET thrott TO 1.
}
function Booster2{
 until Done = 0{
	processCommCommands().
	lock steering to CopyVessleHed("Booster1").
	lock throttle to thrott.
 }
}
 
 
function BoostBackB1{
	//---------------------boost Back------------------//
	until ImpactDist < 500{
	steerToTargetB1(boosterAdjustPitch,boosterAdjustLatOffset,boosterAdjustLngOffset).		
	 if(impactDist < 20000){		
		SET thrott TO 0.5.
		sendCommToVessel(commTargetVessel,list("thrott",thrott)).
	}else{
		SET thrott TO 1.
		if(isShip("B1")){
			sendCommToVessel(commTargetVessel,list("thrott",thrott)).
		}
	}
	}	
	if ImpactDist < 580{sendCommToVessel(commTargetVessel,list("thrott",0)).}
  if ImpactDist < 500{
	SET thrott TO 0.
	WAIT 1.
	if(isShip("B1")){
		if(boosterLandMode=true){
		//	sendCommToVessel(commTargetVessel,list("thrott",0)).
			sendCommToVessel(commTargetVessel,list("done",0)).
			//wait 2.
			kuniverse:forcesetactivevessel(commTargetVessel).
			wait 2.
		}
	}
	//-----------------------------------//
  }
		
}
function entry{


	set thrott to 0.
	lock steering to up.
    brakes on .
wait until alt:radar < 30000.

//-------Entry Burn-------//	
set thrott to 1.
//activateBurnedTexture().
toggle ag5.
until ship:verticalspeed > - 230{ 
setHoverPIDLOOPS(). //you can manually set them, but these are some good defaults.
setHoverTarget(landingPadB1:lat,landingPadB1:LNG).}.
 set thrott to 0.
//--------------------------//


}


function glide{
until alt:radar < LburnAlt{

if isShip("B1"){
brakes on.
setHoverPIDLOOPS(). //you can manually set them, but these are some good defaults.
setHoverTarget(landingPadB1:lat,landingPadB1:LNG).
SET geoDist TO calcDistance(landingPadB1, SHIP:GEOPOSITION).
}
else if isShip("B2"){
brakes on.
setHoverPIDLOOPS(). //you can manually set them, but these are some good defaults.
setHoverTarget(landingPadB2:lat,landingPadB2:LNG).
SET geoDist TO calcDistance(landingPadB2, SHIP:GEOPOSITION).
}

print geoDist.
gridFinSteer().
}
}

function ThreeEngineLanding{
	updateVars().
  lock throttle to thrott.
setHoverMaxSteerAngle(3).
setHoverMaxHorizSpeed(8).
updateHoverSteering("Engine").
set thrott to 1.
until ship:verticalSpeed > -90{
set thrott to 1.
}
  toggle ag1.
}

function Sland{
	until ship:status="landed"{ 
	updateVars().
	setHoverMaxSteerAngle(6).
	setHoverMaxHorizSpeed(3).
	logSburnData().
    lock throttle to getSburnThrottle().
	if alt:radar < 100{
		gear on.
	}
	updateHoverSteering("Engine").
}

}


function main{
	wait 2.
	until looping =false{
	if isShip("B1"){
	Booster1().
	BoostBackB1().
	entry().
	rcs off.
    glide().
    ThreeEngineLanding().
    Sland().
	brakes off.
	lock throttle to 0.
	lock steering to up.
	set ship:control:pilotmainthrottle to 0.
	RCS off.
	wait 10.
    shutdown.
	}
when throttle = 0 then { 
      set STEERINGMANAGER:MAXSTOPPINGTIME to 25.
      set STEERINGMANAGER:PITCHPID:KD to 3.
      set STEERINGMANAGER:YAWPID:KD to 3.
preserve.	
} 

when throttle > 0 then {
      set STEERINGMANAGER:MAXSTOPPINGTIME to 2.
      set STEERINGMANAGER:PITCHPID:KD to 1.
      set STEERINGMANAGER:YAWPID:KD to 1.
preserve.
}
	updateReadoutsLand().
	processCommCommands().

	if isShip("B2"){
	Booster2().
	entry().
	rcs off.
	glide().
	ThreeEngineLanding().
    Sland().
     brakes off.
    lock throttle to 0.
    lock steering to up.
    wait 10.
	brakes off.
	lock throttle to 0.
	set ship:control:pilotmainthrottle to 0.
	RCS off.
    shutdown.
	}
	}

}

///////////////////functions///////////////////////////

function SetTrueRadar{	
if isShip("B1"){
lock trueRadar to alt:radar - radarOffsetB1.    
}
else if isShip("B2"){
 lock trueRadar to alt:radar - radarOffsetB2.    
}

}

function getSburnThrottle{	                 
lock g to constant:g * body:mass / body:radius^2.            
lock maxDecel to (ship:availablethrust / ship:mass) - g.    
lock stopDist to ship:verticalspeed^2 / (2 * maxDecel).        
return stopDist / trueRadar.                      
}
function steerToTargetB1{
	parameter pitch is 1.
	parameter overshootLatModifier is 0.
	parameter overshootLngModifier is 0.
	SET overshootLatLng TO LATLNG(landingPadB1:LAT + overshootLatModifier, landingPADB1:LNG + overshootLngModifier).
	SET targetDir TO geoDir(ADDONS:TR:IMPACTPOS,overshootLatLng).
	SET impactDist TO calcDistance(overshootLatLng, ADDONS:TR:IMPACTPOS).
	SET steeringDir TO targetDir - 180.
	print ImpactDist at(3,3) .
	LOCK STEERING TO HEADING(steeringDir,pitch).
  	//lockSteeringToStandardVector(HEADING(steeringDir,pitch):VECTOR).
}

function setHoverPIDLOOPS{

	SET bodyRadius TO 1700. //note Kerbin is around 1700
	
	//Controls altitude by changing climbPID setpoint
	SET hoverPID TO PIDLOOP(1, 0.01, 0.0, -50, 50). 
	//Controls vertical speed
	SET climbPID TO PIDLOOP(0.1, 0.3, 0.005, 0, 1). 
	//Controls horizontal speed by tilting rocket
	SET eastVelPID TO PIDLOOP(3, 0.01, 0.0, -20, 20).
	SET northVelPID TO PIDLOOP(3, 0.01, 0.0, -20, 20). 
	 //controls horizontal position by changing velPID setpoints
	SET eastPosPID TO PIDLOOP(bodyRadius, 0, 100, -40,40).
	SET northPosPID TO PIDLOOP(bodyRadius, 0, 100, -40,40).
}
function sProj { //Scalar projection of two vectors.
	parameter a.
	parameter b.
	if b:mag = 0 { PRINT "sProj: Divide by 0. Returning 1". RETURN 1. }
	RETURN VDOT(a, b) * (1/b:MAG).
}

function updateReadoutsLand{
Print "FALCON HEAVY LANDING CONTROL COMPUTER" at ( 2, 1).
Print "-------------------------------------" at ( 2, 2).
Print "____________________________________" at ( 3, 3).
//Print "step: " + step at ( 3, 4).
PRINT "Altitude: " + Alt:radar at (3,5).
print "land mode: RTLS" at (3,6).
print "Geografical Distance to target: " + geoDist at(3,7).
}

function cVel {
	local v IS SHIP:VELOCITY:SURFACE.
	local eVect is VCRS(UP:VECTOR, NORTH:VECTOR).
	local eComp IS sProj(v, eVect).
	local nComp IS sProj(v, NORTH:VECTOR).
	local uComp IS sProj(v, UP:VECTOR).
	RETURN V(eComp, uComp, nComp).
}
function updateHoverSteering{
	parameter reverse .
	SET cVelLast TO cVel().
	SET eastVelPID:SETPOINT TO eastPosPID:UPDATE(TIME:SECONDS, SHIP:GEOPOSITION:LNG).
	SET northVelPID:SETPOINT TO northPosPID:UPDATE(TIME:SECONDS,SHIP:GEOPOSITION:LAT).
	LOCAL eastVelPIDOut IS eastVelPID:UPDATE(TIME:SECONDS, cVelLast:X).
	LOCAL northVelPIDOut IS northVelPID:UPDATE(TIME:SECONDS, cVelLast:Z).
	LOCAL eastPlusNorth is MAX(ABS(eastVelPIDOut), ABS(northVelPIDOut)).
	SET steeringPitch TO 90 - eastPlusNorth.
	LOCAL steeringDirNonNorm IS ARCTAN2(eastVelPID:OUTPUT, northVelPID:OUTPUT). //might be negative
	if steeringDirNonNorm >= 0 {
		SET steeringDir TO steeringDirNonNorm.
	} else {
		SET steeringDir TO 360 + steeringDirNonNorm.
	}
	if reverse="Gridfin" {
		SET steeringDir TO steeringDir - 180.
		if steeringDir < 0 {
			SET steeringDir TO 360 + steeringDir.
	}
	}
	else if reverse="Engine"{
		Print "0" at (1,1).
	}
	LOCK STEERING TO HEADING(steeringDir,steeringPitch).
}

function logSburnData{
	if isShip("B1"){
	LOG Ship:verticalspeed to B1Ver.xlsx.
	log alt:radar to B1Alt.xlsx.
	}
	else if isShip("B2"){
	LOG Ship:verticalspeed to B2Ver.xlsx.
	log alt:radar to B2Alt.xlsx.
	}
}

function gridFinSteer{
	if(geoDist>100){
		setHoverMaxSteerAngle(20).
		setHoverMaxHorizSpeed(260). //booster will start reducing it's horizontal with limit of 260m/s
	}else{
		setHoverMaxSteerAngle(15).
		setHoverMaxHorizSpeed(150). //booster will start reducing it's horizontal with limit of 150m/s
	}	
	updateHoverSteering("Gridfin"). //will automatically steer the vessel towards the target.
}
function processCommCommands{
	WHEN NOT SHIP:MESSAGES:EMPTY THEN{
	  SET RECEIVED TO SHIP:MESSAGES:POP.
	  SET cmd TO RECEIVED:CONTENT[0].
	  SET val TO RECEIVED:CONTENT[1].
	  if(cmd="thrott"){
		SET thrott TO val. //just make following vessel lag behind a little.
	  }
	  if(cmd="done"){
		SET Done TO val.
	  }
	}
}
function setHoverTarget{
	parameter lat.
	parameter lng.
	SET eastPosPID:SETPOINT TO lng.
	SET northPosPID:SETPOINT TO lat.
}
function sendCommToVessel{
	parameter v.
	parameter msg.
	SET C TO v:CONNECTION.
	C:SENDMESSAGE(msg).
}
function setHoverAltitude{ //set just below landing altitude to touchdown smoothly
	parameter a.
	SET hoverPID:SETPOINT TO a.
}
function CopyVessleHed{
	parameter ves.
	Return  vessel(ves):facing:vector.
	
}
function setHoverDescendSpeed{
	parameter a.
	SET hoverPID:MAXOUTPUT TO a.
	SET hoverPID:MINOUTPUT TO -1*a.
	SET climbPID:SETPOINT TO hoverPID:UPDATE(TIME:SECONDS, SHIP:ALTITUDE). //control descent speed with throttle
	SET thrott TO climbPID:UPDATE(TIME:SECONDS, SHIP:VERTICALSPEED).	
}
function setHoverMaxSteerAngle{
	parameter a.
	SET eastVelPID:MAXOUTPUT TO a.
	SET eastVelPID:MINOUTPUT TO -1*a.
	SET northVelPID:MAXOUTPUT TO a.
	SET northVelPID:MINOUTPUT TO -1*a.
}
function setHoverMaxHorizSpeed{
	parameter a.
	SET eastPosPID:MAXOUTPUT TO a.
	SET eastPosPID:MINOUTPUT TO -1*a.
	SET northPosPID:MAXOUTPUT TO a.
	SET northPosPID:MINOUTPUT TO -1*a.
}


function updateVars { //Scalar projection of two vectors. Find component of a along b. a(dot)b/||b||	
	SET distMargin TO 1300.
	SET maxVertAcc TO (SHIP:AVAILABLETHRUST) / SHIP:MASS - g. //max acceleration in up direction the engines can create
	SET vertAcc TO sProj(SHIP:SENSORS:ACC, UP:VECTOR).
	SET dragAcc TO g + vertAcc. //vertical acceleration due to drag. Same as g at terminal velocity
	SET sBurnDist TO (SHIP:VERTICALSPEED^2 / (2 * (maxVertAcc + dragAcc/2)))+distMargin.//-SHIP:VERTICALSPEED * sBurnTime + 0.5 * -maxVertAcc * sBurnTime^2.//SHIP:VERTICALSPEED^2 / (2 * maxVertAcc).	
}

function isShip{
	parameter tagName.
	SET thisParts TO SHIP:PARTSTAGGED(tagName).
	if(thisParts:LENGTH>0){
		return true.
	}
	return false.
}

function calcDistance { //Approx in meters
	parameter geo1.
	parameter geo2.
	return (geo1:POSITION - geo2:POSITION):MAG.
}
function geoDir {
	parameter geo1.
	parameter geo2.
	return ARCTAN2(geo1:LNG - geo2:LNG, geo1:LAT - geo2:LAT).
}
function updateMaxAccel {
	SET g TO constant:G * BODY:Mass / BODY:RADIUS^2.
	SET maxAccel TO (SHIP:AVAILABLETHRUST) / SHIP:MASS - g. //max acceleration in up direction the engines can create
}
