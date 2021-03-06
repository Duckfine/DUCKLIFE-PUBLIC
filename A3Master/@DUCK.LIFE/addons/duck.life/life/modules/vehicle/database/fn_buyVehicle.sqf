#include "\duck.core\script_macros.hpp"
/*

  Author: Duckfine
  Date created: 03-09-2020 10:37

  Description
    Gets called if a player buys a vehicle
	The buyed vehicle gets stored in players garage
	if the player wants to see it at the car dealer its part of the buy script to spawn the vehicle

  Parameter:
    - int shop
	- string vehicle
	- int quant
	- string steamid64

  Returns:
    - <type> <name>


 */

 private[

  "_placeholder01",
  "_placeholder02"

];

params[

  ["_shop", 0, [1]],     // Shopid
  ["_vehicle", "", ["a"]],     // ItemClassname
  ["_quant", 0, [1]],    // Quantity
  ["_steamID64", "", ["a"]] // Player

];


_shopDataID = DEF_DB_REDIS_GET_DBID("shopdata");
_playerDataID = DEF_DB_REDIS_GET_DBID("playerdata");
_schemaWarehouseItem = DEF_DB_GET_SCHEMA("db_life", "tblEcoShopServerInfo", "schemaWarehouseItem");
_schemaPlayer = DEF_DB_GET_SCHEMA("db_life", "tblplayers", "playerRelated");
_schemaShop = DEF_DB_GET_SCHEMA("db_life", "tblEcoShopServerInfo", "schemaCache");

_shopWarehouse = [_shopDataID, str(_shop), _schemaShop, "warehouse"] call DUC_CORE_redis_fnc_listEntryGet;

// Find correct item in warehouse
_warehouseItem = "";
{
  _xClassName = DEF_CORE_GET_OBJECT_VALUE(_schemaWarehouseItem, _x, "className");
  if(_xClassName isEqualTo _vehicle) exitWith { _warehouseItem = _x; };
} forEach _shopWarehouse;
if (_warehouseItem isEqualTo "") exitWith { false; };

// Check if Shop has enough items
_itemStock = DEF_CORE_GET_OBJECT_VALUE(_schemaWarehouseItem, _warehouseItem, "stock");
if (_itemStock < _quant) exitWith { false; };

// Check if player has enough money
_playerMoney = [_playerDataID, _steamID64, _schemaPlayer, "bank"] call DUC_CORE_redis_fnc_listEntryGet;
_itemPriceBuy = DEF_CORE_GET_OBJECT_VALUE(_schemaWarehouseItem, _warehouseItem, "priceBuy");

if(_playerMoney < _itemPriceBuy * _quant) exitWith { false; };

// Set inventory counts
_playerMoney = _playerMoney - _itemPriceBuy * _quant;

// Update Warehouse
{
  _xClassName = DEF_CORE_GET_OBJECT_VALUE(_schemaWarehouseItem, _x, "className");
  if (_xClassName isEqualTo _item) exitWith
  {
      
	  if (_itemStock isEqualTo _quant) then
	  {
      _shopWarehouse deleteAt _forEachIndex;
	  } else
	  {
      _shopWarehouseItem = [_schemaWarehouseItem, _x, "stock", _itemStock - _quant] call DUC_CORE_fnc_setArrayValue;
      _shopWarehouse set [_forEachIndex, _shopWarehouseItem];
	  };

  };
	
} forEach _shopWarehouse;



// TODO handle to add to player garage

// TODO 
[] call DUC_LIFE_VEH_fnc_playerGarageAddVehicle;


/////////////


// update bank(player), warehouse and inv of shop to database 
[_playerDataID, _steamID64, _playerMoney, _schemaPlayer, "bank"] call DUC_CORE_redis_fnc_listEntryUpdate;
[_shopDataID, str(_shop), _shopWarehouse, _schemaShop, "warehouse"] call DUC_CORE_redis_fnc_listEntryUpdate;
[_playerDataID, _steamID64, _playerInv, _schemaPlayer, "invVirtual"] call DUC_CORE_redis_fnc_listEntryUpdate;






