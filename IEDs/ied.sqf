params ["_logic","_IEDSize","_IEDType","_collapsing"];
private _IEDClass = "";
switch (_IEDSize) do {
	case "Dug In Small": {_IEDClass = "ACE_IEDLandSmall_Command_Ammo"};
	case "Dug In Large": {_IEDClass = "ACE_IEDLandBig_Command_Ammo"};
	case "Urban Small": {_IEDClass = "ACE_IEDUrbanSmall_Command_Ammo"};
	case "Urban Large": {_IEDClass = "ACE_IEDUrbanBig_Command_Ammo"};
};

private _syncedObjects = synchronizedObjects _logic;
_triggers = [];
_friendlySides = [];

{
	if (_x isKindOf "Man") then {
		_triggers pushBack _x;	
		_friendlySides pushBackUnique (side _x);
	};
} forEach _syncedObjects;
_ied = _iedClass createVehicle (position _logic);
_ied setDir (random 360);
private _circuit = objnull;
if (_collapsing) then {
	_circuit = "Land_MetalWire_F" createVehicle (position _logic);
	_circuit attachTo [_ied,[0,0,0.06]];
};

switch (_IEDType) do {
case "CWIED": {
		private _deleteThese = [];
		{
			[_x, _ied, "ACE_Clacker"] call ace_explosives_fnc_connectExplosive;
			_x setVariable ["H_cwPos",position _x,true];
			private _switch = createVehicle ["Land_CarBattery_02_F",(position _x),[],0,"CAN_COLLIDE"];
			_deleteThese pushBack _switch;
			_switch enableRopeAttach true;
			private _fakeVeh = createVehicle ["B_Quadbike_01_F",(position _x),[],0,"CAN_COLLIDE"];
			_deleteThese pushBack _fakeVeh;
			ropeCreate [_fakeVeh,[0,0,-1.6],_ied,[0,0,0]];
			hideObjectGlobal _fakeVeh;
		} forEach _triggers;

		waitUntil {
			((({((_x distance _ied) < 5) && !((side _x) in _friendlySides) && !(unitIsUAV vehicle _x)} count allUnits) > 0) && 
			
			((count ([_triggers,{(alive _x) && (([objNull, "VIEW"] checkVisibility [eyepos _x, [getPosASL _ied # 0,getPosASL _ied # 1,(getPosASL _ied # 2)+1]]) > 0) && ((_x distance (_x getVariable "H_cwPos")) < 5)}] call BIS_fnc_conditionalSelect)) > 0) )
			
			 
			 || (!(alive _ied) || isNull(ropeAttachedTo _ied))};
		{
			deleteVehicle _x;
		} forEach _deleteThese;
		if (!(alive _ied) || isNull(ropeAttachedTo _ied)) exitWith {
			if (_collapsing) then {
				waitUntil {!(alive _ied)};
				sleep 0.1;
				if (({(((position _x) distance _logic) < 0.5)} count (allMissionobjects "GroundWeaponHolder")) > 0) then {
					private _iedN = _iedClass createVehicle (position _logic);
					[_iedN, _iedN, "ACE_Clacker"] call ace_explosives_fnc_connectExplosive;
					[[_iedN]] call ace_explosives_fnc_scriptedExplosive;
					deleteVehicle _circuit;
					deleteVehicle ((position _logic) nearestObject "GroundWeaponHolder");
				};
			};
		};
		[[_ied]] call ace_explosives_fnc_scriptedExplosive;
	};
case "RCIED": {
	private _switchType = selectRandom ["Land_MobilePhone_old_F","Land_PortableLongRangeRadio_F"];
	private _switch = _switchType createVehicle (position _logic);
	_switch attachTo [_ied,[0,0,0.1]];
	{
		[_x, _ied, "ACE_Clacker"] call ace_explosives_fnc_connectExplosive;
	} forEach _triggers;


	waitUntil {
		((({((_x distance _ied) < 5) && !((side _x) in _friendlySides) && !(unitIsUAV vehicle _x)} count allUnits) > 0) && 
		
		((count ([_triggers,{(alive _x) && (([objNull, "VIEW"] checkVisibility [eyepos _x, [getPosASL _ied # 0,getPosASL _ied # 1,(getPosASL _ied # 2)+1]]) > 0)}] call BIS_fnc_conditionalSelect)) > 0) &&
		
		 !({(_x distance _ied) < (_x getVariable "H_ECM")} count allUnits > 0)) 
		 
		 || !(alive _ied)};
	deleteVehicle _switch;
	if (!(alive _ied)) exitWith {
			if (_collapsing) then {
				waitUntil {!(alive _ied)};
				sleep 0.1;
				if (({(((position _x) distance _logic) < 0.5)} count (allMissionobjects "GroundWeaponHolder")) > 0) then {
					private _iedN = _iedClass createVehicle (position _logic);
					[_iedN, _iedN, "ACE_Clacker"] call ace_explosives_fnc_connectExplosive;
					[[_iedN]] call ace_explosives_fnc_scriptedExplosive;
					deleteVehicle _circuit;
					deleteVehicle ((position _logic) nearestObject "GroundWeaponHolder");
				};
			};
		};
	[[_ied]] call ace_explosives_fnc_scriptedExplosive;
};
	 
	 };