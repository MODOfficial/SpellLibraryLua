
LinkLuaModifier('modifier_abaddon_borrowed_time_lua_active', 'abilities/abaddon/borrowed_time', LUA_MODIFIER_MOTION_NONE)
ability_borrowed_time = class({})

function ability_borrowed_time:OnSpellStart()
    self:GetCaster():AddNewModifier(self:GetCaster(), self, 'modifier_abaddon_borrowed_time_lua_active', {
        duration = self:GetSpecialValueFor('duration')
    })
    self:GetCaster():EmitSound('Hero_Abaddon.BorrowedTime')
end
--
-- Absorb damage logic in filters.lua [L45 - L56]
--
modifier_abaddon_borrowed_time_lua_active = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
    GetStatusEffectName     = function(self) return 'particles/status_fx/status_effect_abaddon_borrowed_time.vpcf' end,
    GetEffectName           = function(self) return 'particles/units/heroes/hero_abaddon/abaddon_borrowed_time.vpcf' end,
    GetEffectAttachType     = function(self) return PATTACH_ABSORIGIN_FOLLOW end,
    StatusEffectPriority    = function(self) return MODIFIER_PRIORITY_HIGH end,

    OnCreated               = function(self)
        self.caster = self:GetCaster()
        self.parent = self:GetParent()
        -- self.radius = self:GetAbility():GetSpecialValueFor('redirect_range_scepter')
        self.caster:Purge(false, true, true, true, false)
        -- if self.caster:HasScepter() and self.caster:HasAbility('ability_mist_coil') then 
        --     self.ability_mist_coil = self.caster:FindAbilityByName('ability_mist_coil')
        --     self.TargetType = self.ability_mist_coil:GetAbilityTargetType()
        --     self.TargetFlags = self.ability_mist_coil:GetAbilityTargetFlags()
        --     -- self:StartIntervalThink(0.1)
        -- end
    end,

    OnIntervalThink          = function(self)
        if IsClient() then return end

        local units = FindUnitsInRadius(self.caster:GetTeam(), 
        self.parent:GetOrigin(), 
        nil, 
        self.radius,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY, 
        self.TargetType, 
        self.TargetFlags,
        FIND_ANY_ORDER, 
        false)

        for k,v in pairs(units) do 
            if v ~= self.caster then 
                self.caster:SetCursorCastTarget(v)
                self.ability_mist_coil:OnSpellStart()
            end
        end
        
    end,
})

