switch to 0.
clearScreen.
sas off.
wait 1.
lock steering to heading(270,10).
wait 4.
rcs on.
set done  to 1.
LOCAL oldTime IS TIME:SECONDS.	
set steeringManager:maxstoppingtime to 0.25.
// set landingPadB1 to vessel("Drone Ship 1"):geoposition.
 //set landingPadB2 to vessel("Drone Ship 2"):geoposition.
set landingPadB1 to latlng(-0.18549138101820,-74.4730209803288).
set landingPadB2 to latlng(-0.205735798275871,-74.4733322465625).
set LburnAlt to 3400.
set landingPad to 1.
set landAltitude to 80.
SET minLandVelocity TO 3.

set radarOffsetB1 to 24.6.
set radarOffsetB2 to 25.6.


set boosterHeight to 25.6.
set STEERINGMANAGER:ROLLTS to 50.
set boosterLandMode to true.
BoosterSep().
SetTrueRadar().
setBoosterHeight().
set looping to true.
set controlPart to 1.
set thrott to 0.
lock throttle to thrott.
set shipPitch to 10.
set steeringDir to 90.
SET geoDist TO 1.
set boosterAdjustPitch to 10.
SET boosterAdjustLatOffset TO 0. 
SET boosterAdjustLngOffset TO 0.01.// set's the overshot distance
set errorScaling to 1.
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

function setBoosterHeight{

if isShip("B1"){
	set boosterHeight to radarOffsetB1.
}
else if isShip("B1"){
	set boosterHeight to radarOffsetB2.
}
}
function BoosterSep{

if isShip("B1"){
set landingPad to landingPadB1.
SET thrott TO 0.
SET SHIP:NAME TO "Booster1".

kuniverse:forcesetactivevessel(SHIP).

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
    steerToTargetB1(boosterAdjustPitch,boosterAdjustLatOffset,boosterAdjustLngOffset).
	wait 15.
	SET thrott TO 1.
}
function Booster2{
  steerToTargetB1(boosterAdjustPitch,boosterAdjustLatOffset,boosterAdjustLngOffset).
	wait 15.
	SET thrott TO 1.
}
 
 
function BoostBackB1{
	//---------------------boost Back------------------//
	until ImpactDist < 500{
	steerToTargetB1(boosterAdjustPitch,boosterAdjustLatOffset,boosterAdjustLngOffset).		
	 if(impactDist < 20000){		
		SET thrott TO 0.5.
	}else{
		SET thrott TO 1.
		if(isShip("B1")){
		}
	}
	}	
  if ImpactDist < 500{
	SET thrott TO 0.
	WAIT 1.
	}
	//-----------------------------------//
  }
		

 
function BoostBack{
	//---------------------boost Back------------------//
	until ImpactDist < 500{
	steerToTargetB1(boosterAdjustPitch,boosterAdjustLatOffset,boosterAdjustLngOffset).		
	 if(impactDist < 20000){		
		SET thrott TO 0.5.
	}else{
		SET thrott TO 1.
	}
	}	
  if ImpactDist < 500{
	SET thrott TO 0.
	WAIT 1.
	//-----------------------------------//
  }
		
} 
 
function BoostBackB2{
	//---------------------boost Back------------------//
	until ImpactDist < 500{
	steerToTargetB2(boosterAdjustPitch,boosterAdjustLatOffset,boosterAdjustLngOffset).		
	 if(impactDist < 20000){		
		SET thrott TO 0.5.
	}else{
		SET thrott TO 1.
	}
	}	
  if ImpactDist < 500{
	SET thrott TO 0.
	WAIT 1.
	//-----------------------------------//
  }
		
} 
function entry{
	set thrott to 0.
	lock steering to up.
    brakes on .
wait until alt:radar < 33000.

//-------Entry Burn-------//	
set thrott to 1.
//activateBurnedTexture().
toggle ag5.
wait until ship:verticalspeed > - 230.

 set thrott to 0.
//--------------------------//



}


function glide{
until alt:radar < LburnAlt{
rcs on.
if isShip("B1"){
brakes on.
setHoverPIDLOOPS(). //you can manually set them, but these are some good defaults.
setHoverTarget(landingPadB1:lat,landingPadB1:LNG).
SET geoDist TO calcDistance(landingPadB1, getImpact()).
}
else if isShip("B2"){
brakes on.
setHoverPIDLOOPS(). //you can manually set them, but these are some good defaults.
setHoverTarget(landingPadB2:lat,landingPadB2:LNG).
SET geoDist TO calcDistance(landingPadB2, getImpact()).
}

print geoDist.
lock steering to EntryControl(20.3).
}
}

function ThreeEngineLanding{
	updateVars().
  lock throttle to thrott.
lock steering to EntryControl(-3.3).
set thrott to 1.
until ship:verticalSpeed > -90{
set thrott to 1.
}
set errorScaling to 1.
  toggle ag1.
}


function SingleEngineBurn{
until ship:status="landed"{ 
SET minLandVelocity TO 5.
lock steering to EntryControl(-1.3).
	SET maxDescendSpeed TO 35.
setHoverPIDLOOPS().
	if alt:radar < 300{
		gear on.
		lock steering to up.
	}
    //logSburnData().
    if(ship:Altitude<210){
		setHoverDescendSpeed(6).
	}else{
		setHoverDescendSpeed(maxDescendSpeed).
	}
	
	updateHoverSteering("Engine").
}
}

function Sland{
until ship:verticalspeed >-0.05{ 
	updateVars().
	logSburnData().
	if alt:radar < 100{
		gear on.
		setHoverDescendSpeed(5).
		lock steering to up.
	}
	else {
		lock throttle to getSburnThrottle().
		lock steering to EntryControl(-6).
	}
	if alt:radar < 110{
		gear on.
	}

}

}

function main{
	wait 2.
	until looping =false{
	if isShip("B1"){
	Booster1().
	BoostBack().
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
	updateReadoutsLand().
	processCommCommands().

	if isShip("B2"){
	Booster2().
	BoostBack().
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
local g to constant:g * body:mass / body:radius^2.            
local maxDecel to (ship:availablethrust / ship:mass) - g.    
local stopDist to ship:verticalspeed^2 / (2 * maxDecel).        
return stopDist / trueRadar.                      
}
function steerToTargetB1{
	parameter pitch is 1.
	parameter overshootLatModifier is 0.
	parameter overshootLngModifier is 0.
	SET overshootLatLng TO LATLNG(landingPadB1:LAT + overshootLatModifier, landingPADB1:LNG + overshootLngModifier).
	SET targetDir TO geoDir(getImpact(),overshootLatLng).
	SET impactDist TO calcDistance(overshootLatLng, getImpact()).
	SET steeringDir TO targetDir - 180.
	print ImpactDist at(3,3) .
	LOCK STEERING TO HEADING(steeringDir,pitch).
  	//lockSteeringToStandardVector(HEADING(steeringDir,pitch):VECTOR).
}
function steerToTargetB2{
	parameter pitch is 1.
	parameter overshootLatModifier is 0.
	parameter overshootLngModifier is 0.
	SET overshootLatLng TO LATLNG(landingPadB2:LAT + overshootLatModifier, landingPADB2:LNG + overshootLngModifier).
	SET targetDir TO geoDir(getImpact(),overshootLatLng).
	SET impactDist TO calcDistance(overshootLatLng, getImpact()).
	SET steeringDir TO targetDir - 180.
	print ImpactDist at(3,3) .
	LOCK STEERING TO HEADING(steeringDir,pitch).
  	//lockSteeringToStandardVector(HEADING(steeringDir,pitch):VECTOR).
}

function lngError {     
    return getImpact():lng - landingPad:lng.
}
function latError {
    return getImpact():lat - landingPad:lat.
}

function errorVector {
    return getImpact():position - landingPad:position.
}
function EntryControl{            
 parameter angle.
    local errorVector is errorVector().
        local velVector is -ship:velocity:surface.
        local result is velVector + errorVector*1.
        if vang(result, velVector) > angle
        {
            set result to velVector:normalized
                          + tan(angle)*errorVector:normalized.
        }
       return lookdirup(result, facing:topvector).
}
function getImpact {
	LOCAL localTime IS TIME:SECONDS.
	IF periapsis > 0 {
		CLEARSCREEN.
		PRINT "no impact detected.".
	} ELSE {
		LOCAL impactData IS impact_UTs().
		LOCAL impactLatLng IS ground_track(POSITIONAT(SHIP,impactData["time"]),impactData["time"]).  
	    print impactLatLng at(2,2).
    return impactLatLng.
    }   
SET oldTime TO localTime.   
}
FUNCTION impact_UTs {//returns the UTs of the ship's impact, NOTE: only works for non hyperbolic orbits
	PARAMETER minError IS 1.
	IF NOT (DEFINED impact_UTs_impactHeight) { GLOBAL impact_UTs_impactHeight IS 0. }
	LOCAL startTime IS TIME:SECONDS.
	LOCAL craftOrbit IS SHIP:ORBIT.
	LOCAL sma IS craftOrbit:SEMIMAJORAXIS.
	LOCAL ecc IS craftOrbit:ECCENTRICITY.
	LOCAL craftTA IS craftOrbit:TRUEANOMALY.
	LOCAL orbitPeriod IS craftOrbit:PERIOD.
	LOCAL ap IS craftOrbit:APOAPSIS.
	LOCAL pe IS craftOrbit:PERIAPSIS.
	LOCAL impactUTs IS time_betwene_two_ta(ecc,orbitPeriod,craftTA,alt_to_ta(sma,ecc,SHIP:BODY,MAX(MIN(impact_UTs_impactHeight,ap - 1),pe + 1))[1]) + startTime.
	LOCAL newImpactHeight IS ground_track(POSITIONAT(SHIP,impactUTs),impactUTs):TERRAINHEIGHT.
	SET impact_UTs_impactHeight TO (impact_UTs_impactHeight + newImpactHeight) / 2.
	RETURN LEX("time",impactUTs,//the UTs of the ship's impact
	"impactHeight",impact_UTs_impactHeight,//the aprox altitude of the ship's impact
	"converged",((ABS(impact_UTs_impactHeight - newImpactHeight) * 2) < minError)).//will be true when the change in impactHeight between runs is less than the minError
}

FUNCTION alt_to_ta {//returns a list of the true anomalies of the 2 points where the craft's orbit passes the given altitude
	PARAMETER sma,ecc,bodyIn,altIn.
	LOCAL rad IS altIn + bodyIn:RADIUS.
	LOCAL taOfAlt IS ARCCOS((-sma * ecc^2 + sma - rad) / (ecc * rad)).
	RETURN LIST(taOfAlt,360-taOfAlt).//first true anomaly will be as orbit goes from PE to AP
}

FUNCTION time_betwene_two_ta {//returns the difference in time between 2 true anomalies, traveling from taDeg1 to taDeg2
	PARAMETER ecc,periodIn,taDeg1,taDeg2.
	
	LOCAL maDeg1 IS ta_to_ma(ecc,taDeg1).
	LOCAL maDeg2 IS ta_to_ma(ecc,taDeg2).
	
	LOCAL timeDiff IS periodIn * ((maDeg2 - maDeg1) / 360).
	
	RETURN MOD(timeDiff + periodIn, periodIn).
}

FUNCTION ta_to_ma {//converts a true anomaly(degrees) to the mean anomaly (degrees) NOTE: only works for non hyperbolic orbits
	PARAMETER ecc,taDeg.
	LOCAL eaDeg IS ARCTAN2(SQRT(1-ecc^2) * SIN(taDeg), ecc + COS(taDeg)).
	LOCAL maDeg IS eaDeg - (ecc * SIN(eaDeg) * CONSTANT:RADtoDEG).
	RETURN MOD(maDeg + 360,360).
}

FUNCTION ground_track {	//returns the geocoordinates of the ship at a given time(UTs) adjusting for planetary rotation over time, only works for non tilted spin on bodies 
	PARAMETER pos,posTime,localBody IS SHIP:BODY.
	LOCAL bodyNorth IS v(0,1,0).//using this instead of localBody:NORTH:VECTOR because in many cases the non hard coded value is incorrect
	LOCAL rotationalDir IS VDOT(bodyNorth,localBody:ANGULARVEL) * CONSTANT:RADTODEG. //the number of degrees the body will rotate in one second
	LOCAL posLATLNG IS localBody:GEOPOSITIONOF(pos).
	LOCAL timeDif IS posTime - TIME:SECONDS.
	LOCAL longitudeShift IS rotationalDir * timeDif.
	LOCAL newLNG IS MOD(posLATLNG:LNG + longitudeShift,360).
	IF newLNG < - 180 { SET newLNG TO newLNG + 360. }
	IF newLNG > 180 { SET newLNG TO newLNG - 360. }
	RETURN LATLNG(posLATLNG:LAT,newLNG).
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
	SET eastVelPID:SETPOINT TO eastPosPID:UPDATE(TIME:SECONDS, getImpact:LNG).
	SET northVelPID:SETPOINT TO northPosPID:UPDATE(TIME:SECONDS,getImpact:LAT).
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
	LOG Ship:verticalspeed to B1Log.xlsx.
	log alt:radar to B1Alt.xlsx.
	}
	else if isShip("B2"){
	LOG Ship:verticalspeed to B2Log.xlsx.
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

function setThrottleSensitivity{
	parameter a.
	SET climbPID:KP TO a.
}
function isShip{
	parameter tagName.
	SET thisParts TO SHIP:PARTSTAGGED(tagName).
	if(thisParts:LENGTH>0){
		return true.
	}
	return false.
}

function DistToTarget{
parameter Targ.
return calcDistance(targ, getImpact()).
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


function getVectorSurfaceRetrograde{
	return -1*ship:velocity:surface.
}

