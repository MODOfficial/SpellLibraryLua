ability_warpath = class({})

function ability_warpath:GetIntrinsicModifierName() return 'modifier_ability_warpath_buff' end

LinkLuaModifier('modifier_ability_warpath_buff', 'heroes/bristleback/warpath', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_ability_warpath_buff_particle', 'heroes/bristleback/warpath', LUA_MODIFIER_MOTION_NONE)
-- Original: https://github.com/EarthSalamander42/dota_imba/blob/77d0b1f04e322812d16b0fce6e0089c24c4a38e2/game/dota_addons/dota_imba_reborn/scripts/vscripts/components/abilities/heroes/hero_bristleback.lua#L548-L628
modifier_ability_warpath_buff = class({
    IsHidden                = function(self) return self:GetStackCount() < 1 end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return false end,
    AllowIllusionDuplicate  = function(self) return true end,
    IsPermanent             = function(self) return true end,
    GetEffectName           = function(self) if self:GetStackCount() >= 1 then return 'particles/units/heroes/hero_bristleback/bristleback_warpath_dust.vpcf' end end,
    DeclareFunctions        = function(self)
        return {
            MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
            MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
            MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
            MODIFIER_PROPERTY_MODEL_SCALE,
        }
    end,
})

function modifier_ability_warpath_buff:OnCreated()
	self.ability	= self:GetAbility()
	self.caster		= self:GetCaster()
    self.parent		= self:GetParent()
    

	-- AbilitySpecials
	self.damage_per_stack		= self.ability:GetSpecialValueFor("damage_per_stack")
	self.move_speed_per_stack	= self.ability:GetSpecialValueFor("move_speed_per_stack")
	self.stack_duration			= self.ability:GetSpecialValueFor("stack_duration")
	self.max_stacks				= self.ability:GetSpecialValueFor("max_stacks")
	    
end

function modifier_ability_warpath_buff:GetModifierModelScale()
	return self:GetStackCount() * 5
end

function modifier_ability_warpath_buff:GetModifierPreAttack_BonusDamage(keys)
    return (self.damage_per_stack or 0) * self:GetStackCount()
end

function modifier_ability_warpath_buff:GetModifierMoveSpeedBonus_Percentage(keys)
	return (self.move_speed_per_stack or 0) * self:GetStackCount()
end


function modifier_ability_warpath_buff:OnAbilityFullyCast(keys)
	if keys.ability and keys.unit == self.parent and not self.parent:PassivesDisabled() and not keys.ability:IsItem() and keys.ability:GetName() ~= "ability_capture" then
        self:SetStackCount(math.min(self:GetStackCount() + 1, self.max_stacks))
        self:SetDuration(self.stack_duration, true)
		if self:GetStackCount() < self.max_stacks then
            self:GetParent():AddNewModifier(self:GetParent(), hAbility, 'modifier_ability_warpath_buff_particle', {duration = self.stack_duration})
		end

	end
end

modifier_ability_warpath_buff_particle = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return false end,
    AllowIllusionDuplicate  = function(self) return true end, 
    GetAttributes           = function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
})

function modifier_ability_warpath_buff_particle:OnCreated()
    if IsClient() then return end 

    self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_bristleback/bristleback_warpath.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(self.particle, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.particle, 4, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetParent():GetAbsOrigin(), true)
    
end 

function modifier_ability_warpath_buff_particle:OnDestroy()
    if not self.particle then return end 

    ParticleManager:DestroyParticle(self.particle, true)
    ParticleManager:ReleaseParticleIndex(self.particle)
end 
