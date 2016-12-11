// Grab & edit the vanilla weapons

class GrenadeHook extends X2AmbientNarrativeCriteria config(RTRGrenades);

//Configs
var config bool INFINITE_FRAG;
var config bool INFINITE_SMOKE;
var config bool INFINITE_FLASH;
var config bool BUILDABLE_GAS;
//var config bool CHANGE_FIRE;

var config bool SINGLE_ACTION_SMOKE;
var config bool SHADOWSTEP_SMOKE;

var config int FRAG_SUPPLIES;
var config int FRAG_ALLOYS;
var config int FRAG_ELERIUM;

var config int SMOKE_SUPPLIES;
var config int SMOKE_ALLOYS;
var config int SMOKE_ELERIUM;

var config int FLASH_SUPPLIES;
var config int FLASH_ALLOYS;
var config int FLASH_ELERIUM;

var config int GAS_SUPPLIES;
var config int GAS_ALLOYS;
var config int GAS_ELERIUM;


var localized string SmokeShadowstepEffectDisplayName;
var localized string SmokeShadowstepEffectDisplayDesc;

//Constructor
static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
		
	local X2ItemTemplateManager ItemTemplateManager;

	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	ChangeFragGrenade(ItemTemplateManager, 'FragGrenade', 0, default.FRAG_SUPPLIES, default.FRAG_ALLOYS, default.FRAG_ELERIUM);
	ChangeFragGrenade(ItemTemplateManager, 'AlienGrenade', 1, default.FRAG_SUPPLIES, default.FRAG_ALLOYS, default.FRAG_ELERIUM);
	
	ChangeSmokeGrenade(ItemTemplateManager, 'SmokeGrenade', 0, default.SMOKE_SUPPLIES, default.SMOKE_ALLOYS, default.SMOKE_ELERIUM);
	ChangeSmokeGrenade(ItemTemplateManager, 'SmokeGrenadeMk2', 1, default.SMOKE_SUPPLIES, default.SMOKE_ALLOYS, default.SMOKE_ELERIUM);

	ChangeFlashBangGrenade(ItemTemplateManager, 'FlashbangGrenade', default.FLASH_SUPPLIES, default.FLASH_ALLOYS, default.FLASH_ELERIUM);

	if (default.BUILDABLE_GAS == true)
	{
		ChangeGasGrenade(ItemTemplateManager, 'GasGrenade', 0, default.GAS_SUPPLIES, default.GAS_ALLOYS, default.GAS_ELERIUM);
		ChangeGasGrenade(ItemTemplateManager, 'GasGrenadeMK2', 1, default.GAS_SUPPLIES, default.GAS_ALLOYS, default.GAS_ELERIUM);
	}

	return Templates;
}

//Frag Grenades
static function ChangeFragGrenade(X2ItemTemplateManager Manager, name Grenade, int Tier, int Supplies, int Alloys, int Elerium)
{
	local X2ItemTemplate Item;
	local X2GrenadeTemplate Template;
	local ArtifactCost Resources;

	Item = Manager.FindItemTemplate(Grenade);
	Template = X2GrenadeTemplate(Item);

	if (default.INFINITE_FRAG == false)
	{
		Template.CanBeBuilt = true;
		Template.bInfiniteItem = false;
		Template.StartingItem = false;
		if (Tier == 0)
		{
			Template.HideIfResearched = 'AdvancedGrenades';
		}
		else if(Tier == 1)
		{
			Template.Requirements.RequiredTechs.AddItem('AdvancedGrenades');
		}
		if (Supplies > 0)
		{
			Resources.ItemTemplateName = 'Supplies';
			Resources.Quantity = Supplies;
			Template.Cost.ResourceCosts.AddItem(Resources);
		}

		if (Alloys > 0)
		{
			Resources.ItemTemplateName = 'AlienAlloy';
			Resources.Quantity = Alloys;
			Template.Cost.ResourceCosts.AddItem(Resources);
		}

		if (Elerium > 0)
		{
			Resources.ItemTemplateName = 'EleriumDust';
			Resources.Quantity = Elerium;
			Template.Cost.ResourceCosts.AddItem(Resources);
		}
	}
}

//Smoke Grenades
static function ChangeSmokeGrenade(X2ItemTemplateManager Manager, name Grenade, int Tier, int Supplies, int Alloys, int Elerium)
{
	local X2ItemTemplate Item;
	local X2GrenadeTemplate Template;
	local ArtifactCost Resources;
	local X2Effect_Persistent Effect;
	local int OldCost;

	Item = Manager.FindItemTemplate(Grenade);
	Template = X2GrenadeTemplate(Item);

	if (default.SINGLE_ACTION_SMOKE == true)
	{
		Template.Abilities.RemoveItem('ThrowGrenade');
		Template.Abilities.AddItem('ThrowSmoke');
	}

	if (default.SHADOWSTEP_SMOKE == true)
	{
		Effect = new class'X2Effect_Persistent';
		Effect.EffectName = 'Shadowstep';
		Effect.BuildPersistentEffect(class'X2Effect_ApplySmokeGrenadeToWorld'.default.Duration + 1, false, false, false, eGameRule_PlayerTurnBegin);
		Effect.SetDisplayInfo(ePerkBuff_Passive, default.SmokeShadowstepEffectDisplayName, default.SmokeShadowstepEffectDisplayDesc, "img:///UILibrary_PerkIcons.UIPerk_shadowstep");
		Effect.DuplicateResponse = eDupe_Refresh;
	}

	if (default.INFINITE_SMOKE == true)
	{
		Template.CanBeBuilt = false;
		Template.bInfiniteItem = true;
		if (Tier == 0)
		{
			Template.StartingItem = true;
		}
	}
	else
	{
		Template.Cost.ResourceCosts.Length = 0;	//Remove old supplies cost
		if (Supplies > 0)
		{
			Resources.ItemTemplateName = 'Supplies';
			Resources.Quantity = Supplies;
			Template.Cost.ResourceCosts.AddItem(Resources);
		}
		if (Alloys > 0)
		{
			Resources.ItemTemplateName = 'AlienAlloy';
			Resources.Quantity = Alloys;
			Template.Cost.ResourceCosts.AddItem(Resources);
		}

		if (Elerium > 0)
		{
			Resources.ItemTemplateName = 'EleriumDust';
			Resources.Quantity = Elerium;
			Template.Cost.ResourceCosts.AddItem(Resources);
		}
	}
}

//Flashbang Grenade
static function ChangeFlashbangGrenade(X2ItemTemplateManager Manager, name Grenade, int Supplies, int Alloys, int Elerium)
{
	local X2ItemTemplate Item;
	local X2GrenadeTemplate Template;
	local ArtifactCost Resources;
	local X2Effect_Persistent Effect;

	Item = Manager.FindItemTemplate(Grenade);
	Template = X2GrenadeTemplate(Item);

	if (default.INFINITE_FLASH == true)
	{
		Template.CanBeBuilt = false;
		Template.bInfiniteItem = true;
		Template.StartingItem = true;
	}
	else
	{
		Template.Cost.ResourceCosts.Length = 0;
		if (Supplies > 0)
		{
			Resources.ItemTemplateName = 'Supplies';
			Resources.Quantity = Supplies;
			Template.Cost.ResourceCosts.AddItem(Resources);
		}
		if (Alloys > 0)
		{
			Resources.ItemTemplateName = 'AlienAlloy';
			Resources.Quantity = Alloys;
			Template.Cost.ResourceCosts.AddItem(Resources);
		}

		if (Elerium > 0)
		{
			Resources.ItemTemplateName = 'EleriumDust';
			Resources.Quantity = Elerium;
			Template.Cost.ResourceCosts.AddItem(Resources);
		}

		Template.UpgradeItem = 'ThunderflashGrenade';
		Template.HideIfResearched = 'AdvancedGrenades';
	}
}

//Gas Grenades
static function ChangeGasGrenade(X2ItemTemplateManager Manager, name Grenade, int Tier, int Supplies, int Alloys, int Elerium)
{
	local X2ItemTemplate Item;
	local X2GrenadeTemplate Template;
	local ArtifactCost Resources;

	Item = Manager.FindItemTemplate(Grenade);
	Template = X2GrenadeTemplate(Item);

	//Techs
	Template.RewardDecks.RemoveItem('ExperimentalGrenadeRewards');
	Template.Requirements.RequiredTechs.AddItem('AutopsyViper');

	//Costs
	Template.CanBeBuilt = true;
	Template.bInfiniteItem = false;
	Template.StartingItem = false;
	if (Tier == 0)
	{
		Template.HideIfResearched = 'AdvancedGrenades';
	}
	else if(Tier == 1)
	{
		Template.Requirements.RequiredTechs.AddItem('AdvancedGrenades');
	}
	if (Supplies > 0)
	{
		Resources.ItemTemplateName = 'Supplies';
		Resources.Quantity = Supplies;
		Template.Cost.ResourceCosts.AddItem(Resources);
	}
	if (Alloys > 0)
	{
		Resources.ItemTemplateName = 'AlienAlloy';
		Resources.Quantity = Alloys;
		Template.Cost.ResourceCosts.AddItem(Resources);
	}
	if (Elerium > 0)
	{
		Resources.ItemTemplateName = 'EleriumDust';
		Resources.Quantity = Elerium;
		Template.Cost.ResourceCosts.AddItem(Resources);
	}
}