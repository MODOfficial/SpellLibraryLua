function GameMode:ActivateFilters()
    GameRules:GetGameModeEntity():SetDamageFilter(Dynamic_Wrap(GameMode, 'DamageFilter'), self)
    GameRules:GetGameModeEntity():SetBountyRunePickupFilter(Dynamic_Wrap(GameMode, 'RuneFilter'), self)
end

function GameMode:RuneFilter(data)
    PrintTable(data)
    local ent = PlayerResource:GetSelectedHeroEntity(data.player_id_const)
    if ent then 
        data.gold_bounty = data.gold_bounty * math.max(GetMultipleBountyBonus(ent),1)
    end 
    return true
end

function GameMode:DamageFilter(filterDamage)
	local attacker = filterDamage.entindex_attacker_const and EntIndexToHScript(filterDamage.entindex_attacker_const) 
	if not attacker then
		print('[DamageFilter] Unit damage not attacker!',EntIndexToHScript(filterDamage.entindex_victim_const):GetUnitName()) 
		return true 
	end 
	local ability,abilityName
	local victim = EntIndexToHScript(filterDamage.entindex_victim_const)
	local typeDamage = filterDamage.damagetype_const
	if filterDamage.entindex_inflictor_const then
		ability = EntIndexToHScript(filterDamage.entindex_inflictor_const )
		if ability and ability.GetAbilityName and ability:GetAbilityName() then
			abilityName = ability:GetAbilityName()
		end
    end
    
    local data = {
        victim = victim,
        attacker = attacker,
        typeDamage = typeDamage,
        ability = ability,
        abilityName = abilityName,
        damage = filterDamage.damage,
    }

    local applyFilter = GameMode:OnApplyDamage(data)
    if applyFilter then 
        filterDamage.damage = GameMode:OnTakeDamageFilter(applyFilter)
        return not not filterDamage.damage
    end 
    return false  

end

function GameMode:OnApplyDamage(data)
 
    return data
end

function GameMode:OnTakeDamageFilter(data)

    if data.victim:HasModifier('modifier_abaddon_borrowed_time_lua_active') then 
        data.victim:Heal(data.damage, data.victim)
        ProjectileManager:CreateTrackingProjectile({
            Target = data.attacker,
            Source = data.victim,
            EffectName = "particles/units/heroes/hero_abaddon/abaddon_borrowed_time_heal.vpcf",
            iMoveSpeed = 600,
            vSourceLoc= data.victim:GetAbsOrigin(),
            bDodgeable = false,
        })
        return false
    end

    local aphotic_shield = data.victim:FindModifierByName('modifier_abaddon_aphotic_shield_lua')

    if aphotic_shield and aphotic_shield.absorbAmount < aphotic_shield.absorb then 
        local absorbAmount = aphotic_shield.absorbAmount
        aphotic_shield.absorbAmount = math.min(aphotic_shield.absorbAmount + data.damage,aphotic_shield.absorb)
        if aphotic_shield.absorb == aphotic_shield.absorbAmount then 
            aphotic_shield:Destroy()
        end
        data.damage = data.damage - (aphotic_shield.absorbAmount - absorbAmount)
    end

    local borrowed_time = data.victim:FindAbilityByName('ability_borrowed_time')
    if borrowed_time and borrowed_time:IsCooldownReady() then 
        local hp_threshold = borrowed_time:GetSpecialValueFor('hp_threshold')
        if data.victim:GetHealth() - data.damage <= hp_threshold then
            data.victim:CastAbilityNoTarget(borrowed_time, 0)
            return false
        end 
    end

    -- local modifier_primal_split_unit = data.victim:FindModifierByName('modifier_primal_split_unit')
    -- if modifier_primal_split_unit and data.damage >= data.victim:GetHealth() then 
    --     modifier_primal_split_unit:OnDeathPrimalSplit()
    -- end

    return data.damage
end


