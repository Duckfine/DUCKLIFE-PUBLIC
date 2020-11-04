/*

  Author: Duckfine
  Date created: 28-5-2020 21:36

  Description
    Transfers one item from inv a to b (player to player)

  Parameter:
    - <type> <name>

  Returns:
    - <type> <name>
[0, getArray(configFile >> "CfgSettings" >> "db_life" >> "tblplayers" >> "playerRelated"), "76561198216442289", "invVirtual", 0, getArray(configFile >> "CfgSettings" >> "db_life" >> "tblplayers" >> "playerRelated"), "76561198248607510", "invVirtual", "dasIstEinGeheimdfghdfghdfhdfghre", 1] call DUC_LIFE_VITEM_FNC_transferItem

 */




private[

  "_senderInv",
  "_receiverInv",
  "_itemCheckSenderInv"

];


params[

  "_senderDatabaseID",
  "_senderDatabaseSchema",
  "_senderDatabaseKey", //i.e. the steamid
  "_senderDatabaseKeyValue", // i.e. invVirtual
  "_receiverDatabaseID",
  "_receiverDatabaseSchema",
  "_receiverDatabaseKey",
  "_receiverDatabaseKeyValue", // i.e. invVirtual
  "_item",
  "_count"

];
// errorchecks
if(_senderDatabaseKeyValue isEqualTo "" || _receiverDatabaseKeyValue isEqualTo "" || _item isEqualTo "" || _count isEqualTo "" || _count <= 0) exitWith { false; };


// get inventory from sender
_senderInv = [_senderDatabaseID, _senderDatabaseKey, _senderDatabaseSchema, _senderDatabaseKeyValue] call DUC_CORE_redis_fnc_listEntryGet;
_itemCheckSenderInv = [_senderInv, _item] call DUC_LIFE_VITEM_FNC_invGetItem;

// check if sender has enough items
if (_itemCheckSenderInv - _count < 0) exitWith { false; };

// remove item from the sender (not updated yet)
_senderInv = [_senderInv, _item, _count] call DUC_LIFE_VITEM_FNC_invRemoveItem;

_receiverInv =  [_receiverDatabaseID, _receiverDatabaseKey, _receiverDatabaseSchema, _receiverDatabaseKeyValue] call DUC_CORE_redis_fnc_listEntryGet;
// add item to the receiver (not updated yet)
_receiverInv =  [_receiverInv, _item, _count] call DUC_LIFE_VITEM_FNC_invAddItem;

// update both invs to cache
[_senderDatabaseID, _senderDatabaseKey, _senderInv, _senderDatabaseSchema, _senderDatabaseKeyValue] call DUC_CORE_redis_fnc_listEntryUpdate;
[_receiverDatabaseID, _receiverDatabaseKey, _receiverInv, _receiverDatabaseSchema, _receiverDatabaseKeyValue] call DUC_CORE_redis_fnc_listEntryUpdate;


true;