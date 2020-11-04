/*

  Author: Duckfine
  Date created:   30-04-2020 22:18

  Description:
    Toggles the GUI

    CODE MUST BE SPAWNED

  Params:
    -


  Returns:
    -

*/
#include "config.hpp"


if(!canSuspend) exitWith { false; };
if (!DUCV_HUD_CLOSED) exitWith { false; };
DUCV_HUD_CLOSED = false;

[] call CDUC_HUD_fnc_open;

uisleep 6;

[] call CDUC_HUD_fnc_close;
DUCV_HUD_CLOSED = true;






















//
