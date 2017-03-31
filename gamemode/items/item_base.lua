local ITEM = {};

/*
**	General item settings.
*/
ITEM.ID = "base";
ITEM.Name = "Item Base";
ITEM.Desc = "";
ITEM.FlavorText = "";
ITEM.Weight = 0;
ITEM.Size = ITEM_TINY;
ITEM.DefaultPrice = 0;

/*
**	Storage item settings.
*/
ITEM.IsStorage = false;
ITEM.StorageSpace = {x = 0, y = 0};
//	Override option that allows an item to store items larger than itself.
ITEM.AllowSize = nil;
ITEM.Lockable = true;
ITEM.LockedByDefault = false;

//	Register the base.
//BASH.Items:NewBase(ITEM);
