// This is an Unreal Script

class X2Item_RTREquipment extends X2Item config(RTRGrenades);

//Configs
var config int THUNDERFLASHGRENADE_ISOUNDRANGE;
var config int THUNDERFLASHGRENADE_IENVIRONMENTDAMAGE;
var config int THUNDERFLASHGRENADE_TRADINGPOSTVALUE;
var config int THUNDERFLASHGRENADE_IPOINTS;
var config int THUNDERFLASHGRENADE_ICLIPSIZE;
var config int THUNDERFLASHGRENADE_RANGE;
var config int THUNDERFLASHGRENADE_RADIUS;

var config WeaponDamageValue SHAPEDCHARGE_BASEDAMAGE;
var config int SHAPEDCHARGE_ISOUNDRANGE;
var config int SHAPEDCHARGE_IENVIRONMENTDAMAGE;
var config int SHAPEDCHARGE_TRADINGPOSTVALUE;
var config int SHAPEDCHARGE_IPOINTS;
var config int SHAPEDCHARGE_ICLIPSIZE;
var config int SHAPEDCHARGE_RANGE;
var config int SHAPEDCHARGE_RADIUS;

var config WeaponDamageValue SHAPEDCHARGE_M2_BASEDAMAGE;
var config int SHAPEDCHARGE_M2_ISOUNDRANGE;
var config int SHAPEDCHARGE_M2_IENVIRONMENTDAMAGE;
var config int SHAPEDCHARGE_M2_TRADINGPOSTVALUE;
var config int SHAPEDCHARGE_M2_IPOINTS;
var config int SHAPEDCHARGE_M2_ICLIPSIZE;
var config int SHAPEDCHARGE_M2_RANGE;
var config int SHAPEDCHARGE_M2_RADIUS;

var config int SHAPEDCHARGE_SUPPLIES;
var config int SHAPEDCHARGE_ALLOYS;
var config int SHAPEDCHARGE_ELERIUM;

var config bool INFINITE_SHAPED_CHARGE;

//Constructor
static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateThunderflashGrenade(class'GrenadeHook'.default.FLASH_SUPPLIES, class'GrenadeHook'.default.FLASH_ALLOYS, class'GrenadeHook'.default.FLASH_ELERIUM));
	Templates.AddItem(CreateShapedCharge('ShapedChargeGrenade', 0, "img:///Grenade_Pack.Inv_Shaped_Charge", default.SHAPEDCHARGE_RANGE, default.SHAPEDCHARGE_RADIUS, default.SHAPEDCHARGE_BASEDAMAGE, default.SHAPEDCHARGE_ISOUNDRANGE, default.SHAPEDCHARGE_IENVIRONMENTDAMAGE, default.SHAPEDCHARGE_TRADINGPOSTVALUE, default.SHAPEDCHARGE_ICLIPSIZE));
	Templates.AddItem(CreateShapedCharge('ShapedChargeGrenadeMK2', 1, "img:///Grenade_Pack.Inv_Shaped_ChargeMK2", default.SHAPEDCHARGE_M2_RANGE, default.SHAPEDCHARGE_M2_RADIUS, default.SHAPEDCHARGE_M2_BASEDAMAGE, default.SHAPEDCHARGE_M2_ISOUNDRANGE, default.SHAPEDCHARGE_M2_IENVIRONMENTDAMAGE, default.SHAPEDCHARGE_M2_TRADINGPOSTVALUE, default.SHAPEDCHARGE_M2_ICLIPSIZE));

	return Templates;
}

//Thunderflash
static function X2DataTemplate CreateThunderflashGrenade(int Supplies, int Alloys, int Elerium)
{
	local X2GrenadeTemplate Template;
	local X2Effect_ApplyWeaponDamage WeaponDamageEffect;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2GrenadeTemplate', Template, 'ThunderflashGrenade');

	Template.strImage = "img:///Grenade_Pack.Inv_Thunderflash_Grenade";
	Template.EquipSound = "StrategyUI_Grenade_Equip";
	Template.AddAbilityIconOverride('ThrowGrenade', "img:///UILibrary_PerkIcons.UIPerk_grenade_flash");
	Template.AddAbilityIconOverride('LaunchGrenade', "img:///UILibrary_PerkIcons.UIPerk_grenade_flash");
	Template.iRange = default.THUNDERFLASHGRENADE_RANGE;
	Template.iRadius = default.THUNDERFLASHGRENADE_RADIUS;
	
	Template.bFriendlyFire = true;
	Template.bFriendlyFireWarning = true;
	Template.Abilities.AddItem('ThrowGrenade');

	Template.ThrownGrenadeEffects.AddItem(class'X2StatusEffects'.static.CreateDisorientedStatusEffect());

	//We need to have an ApplyWeaponDamage for visualization, even if the grenade does 0 damage (makes the unit flinch, shows overwatch removal)
	WeaponDamageEffect = new class'X2Effect_ApplyWeaponDamage';
	WeaponDamageEffect.bExplosiveDamage = true;
	Template.ThrownGrenadeEffects.AddItem(WeaponDamageEffect);

	Template.LaunchedGrenadeEffects = Template.ThrownGrenadeEffects;
	
	Template.GameArchetype = "WP_Grenade_THUNDERFLASH.WP_Grenade_Flashbang";

	Template.CanBeBuilt = true;

	Template.iSoundRange = default.THUNDERFLASHGRENADE_ISOUNDRANGE;
	Template.iEnvironmentDamage = default.THUNDERFLASHGRENADE_IENVIRONMENTDAMAGE;
	Template.TradingPostValue = default.THUNDERFLASHGRENADE_TRADINGPOSTVALUE;
	Template.PointsToComplete = default.THUNDERFLASHGRENADE_IPOINTS;
	Template.iClipSize = default.THUNDERFLASHGRENADE_ICLIPSIZE;
	Template.Tier = 1;
	if (class'GrenadeHook'.default.INFINITE_FLASH == false)
	{
		Template.CanBeBuilt = true;
		
		// Cost
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
	else
	{
		Template.CanBeBuilt = false;
		Template.bInfiniteItem = true;
	}

	Template.Requirements.RequiredTechs.AddItem('AdvancedGrenades');

	// Soldier Bark
	Template.OnThrowBarkSoundCue = 'ThrowFlashbang';

	Template.SetUIStatMarkup(class'XLocalizedData'.default.RangeLabel, , default.THUNDERFLASHGRENADE_RANGE);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.RadiusLabel, , default.THUNDERFLASHGRENADE_RADIUS);

	return Template;
}

//Shaped Charges
static function X2DataTemplate CreateShapedCharge(name GrenadeName, int iTier, string GrenadeImage, int Range, int Radius, WeaponDamageValue Damage, int SoundRange, int EnvironmentalDamage, int TradingValue, int Clip)
{
	local X2GrenadeTemplate Template;
	local X2Effect_ApplyWeaponDamage WeaponDamageEffect;
	local X2Effect_Knockback KnockbackEffect;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2GrenadeTemplate', Template, GrenadeName);

	Template.strImage = GrenadeImage;
	Template.EquipSound = "StrategyUI_Grenade_Equip";
	Template.iRange = Range;
	Template.iRadius = Radius;

	Template.BaseDamage = Damage;
	Template.iSoundRange = SoundRange;
	Template.iEnvironmentDamage = EnvironmentalDamage;
	Template.TradingPostValue =TradingValue;
	Template.iClipSize = Clip;
	Template.DamageTypeTemplateName = 'Explosion';
	Template.Tier = iTier;

	Template.Abilities.AddItem('ThrowGrenade');
	Template.Abilities.AddItem('GrenadeFuse');
	
	Template.GameArchetype = "WP_Grenade_Frag.WP_Grenade_Frag";

	Template.iPhysicsImpulse = 10;

	Template.StartingItem = true;
	Template.CanBeBuilt = false;

	WeaponDamageEffect = new class'X2Effect_ApplyWeaponDamage';
	WeaponDamageEffect.bExplosiveDamage = true;
	Template.ThrownGrenadeEffects.AddItem(WeaponDamageEffect);
	Template.LaunchedGrenadeEffects.AddItem(WeaponDamageEffect);

	Template.OnThrowBarkSoundCue = 'ThrowGrenade';

	KnockbackEffect = new class'X2Effect_Knockback';
	KnockbackEffect.bUseTargetLocation = true; //This looks better for the animations used even though the source location should be used for grenades.
	KnockbackEffect.KnockbackDistance = 2;
	Template.ThrownGrenadeEffects.AddItem(KnockbackEffect);
	Template.LaunchedGrenadeEffects.AddItem(KnockbackEffect);

	Template.SetUIStatMarkup(class'XLocalizedData'.default.RangeLabel, , Range);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.RadiusLabel, , Radius);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.ShredLabel, , Damage.Shred);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.PierceLabel, , Damage.Pierce);


	// Tech Stuff
	/*
	Template.Requirements.RequiredTechs.AddItem('HybridMaterials');
	*/
	if (iTier == 0)
	{
		Template.UpgradeItem = 'ShapedChargeGrenadeMK2';
		Template.HideIfResearched = 'AdvancedGrenades';
	}
	else if (iTier == 1)
	{
		Template.Requirements.RequiredTechs.AddItem('AdvancedGrenades');
	}

	if (default.INFINITE_SHAPED_CHARGE == false)
	{
		Template.StartingItem = false;
		Template.CanBeBuilt = true;

		// Cost
		if (default.SHAPEDCHARGE_SUPPLIES > 0)
		{
			Resources.ItemTemplateName = 'Supplies';
			Resources.Quantity = default.SHAPEDCHARGE_SUPPLIES;
			Template.Cost.ResourceCosts.AddItem(Resources);
		}
		if (default.SHAPEDCHARGE_ALLOYS > 0)
		{
			Resources.ItemTemplateName = 'AlienAlloy';
			Resources.Quantity = default.SHAPEDCHARGE_ALLOYS;
			Template.Cost.ResourceCosts.AddItem(Resources);
		}
		if (default.SHAPEDCHARGE_ELERIUM > 0)
		{
			Resources.ItemTemplateName = 'EleriumDust';
			Resources.Quantity = default.SHAPEDCHARGE_ELERIUM;
			Template.Cost.ResourceCosts.AddItem(Resources);
		}
	}
	else
	{
		if (iTier == 0)
		{
			Template.StartingItem = true;
		}
		Template.bInfiniteItem = true;
		Template.CanBeBuilt = false;
	}
	return Template;
}
