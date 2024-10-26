-------- 被赐福的完美无瑕咩咩雕像 --------
GLOBAL.TUNING.COTL_TABERNACLE_3.RAIN_RATE = 0
GLOBAL.TUNING.COTL_TABERNACLE_3.FUEL_MAX = 7200

AddPrefabPostInit("cotl_tabernacle_level3", function(inst)
    inst:DoPeriodicTask(2, function(inst)
        if inst.components.fueled then
            local fuel_count = inst.components.fueled:GetPercent()
            if fuel_count < 1 then
                inst.components.fueled:DoDelta(7200)
            end
        end
    end)
end)
-------- 被赐福的完美无瑕咩咩雕像 --------


-------- 金块燃料 --------
AddPrefabPostInit("goldnugget", function(inst)
    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = 7200
end)
-------- 金块燃料 --------


-------- 更耐用的懒惰护符 --------
AddPrefabPostInit("orangeamulet", function(inst)
    if inst.components.finiteuses then
        inst.components.finiteuses:SetMaxUses(30000)
    end
end)
-------- 更耐用的懒惰护符 --------


-------- 更耐用并自动修复的墙 --------
GLOBAL.TUNING.HAYWALL_HEALTH = 10000
GLOBAL.TUNING.WOODWALL_HEALTH = 10000
GLOBAL.TUNING.STONEWALL_HEALTH = 10000
GLOBAL.TUNING.RUINSWALL_HEALTH = 10000
GLOBAL.TUNING.MOONROCKWALL_HEALTH = 10000

local function wall_regen(inst)
    inst:DoPeriodicTask(2, function(inst)
        if inst and inst.components and inst.components.health then
            local wall_health = inst.components.health:GetPercent()
            if wall_health < 1 then
                inst.components.health:DoDelta(10000)
            end
        end
    end)
end

AddPrefabPostInit("wall_hay", wall_regen)
AddPrefabPostInit("wall_wood", wall_regen)
AddPrefabPostInit("wall_stone", wall_regen)
AddPrefabPostInit("wall_ruins", wall_regen)
AddPrefabPostInit("wall_moonrock", wall_regen)
-------- 更耐用并自动修复的墙 --------


-------- 无耐久的门 --------
AddPrefabPostInit("fence_gate", function(inst)
    inst:RemoveComponent("health")
end)
-------- 无耐久的门 --------


-------- 更高的洞察点上限 --------
data = {15,15,15,20,20,20,25,25,25,30,30,30,35,35,35}
if data then
	table.foreach(data, function(_, i)
        table.insert(GLOBAL.TUNING.SKILL_THRESHOLDS, i)
    end)
end
-------- 更高的洞察点上限 --------


-------- 更强的亮茄魔杖 --------
GLOBAL.TUNING.STAFF_LUNARPLANT_PLANAR_DAMAGE = 50
GLOBAL.TUNING.STAFF_LUNARPLANT_BOUNCES = 0
GLOBAL.TUNING.STAFF_LUNARPLANT_SETBONUS_BOUNCES = 2
AddPrefabPostInit("staff_lunarplant", function(inst)
    if inst.components.weapon then
        inst.components.weapon:SetDamage(30)
        -- inst.components.weapon:SetRange(8, 10)
    end
    if inst.components.finiteuses then
        inst:RemoveComponent("finiteuses")
    end
end)
-------- 更强的亮茄魔杖 --------


-------- 更强的启迪皇冠 --------
GLOBAL.setmetatable(
	env,
	{
		__index = function(t, k)
			return GLOBAL.rawget(GLOBAL, k)
		end
	}
)

TUNING.SANITY_BECOME_ENLIGHTENED_THRESH = 0

local function alterguardian_spawngestalt_fn_mod(inst, owner, data)
    if not inst._is_active then
        return
    end

    if owner ~= nil and (owner.components.health == nil or not owner.components.health:IsDead()) then
        local target = data.target
        if target and target ~= owner and target:IsValid() and (target.components.health == nil or not target.components.health:IsDead() and not target:HasTag("structure") and not target:HasTag("wall")) then
            -- In combat, this is when we're just launching a projectile, so don't spawn a gestalt yet
            if data.weapon ~= nil and data.projectile == nil
                    and (data.weapon.components.projectile ~= nil
                        or data.weapon.components.complexprojectile ~= nil
                        or data.weapon.components.weapon:CanRangedAttack()) then
                return
            end

    --         local x, y, z = target.Transform:GetWorldPosition()
    --         local gestalt = SpawnPrefab("alterguardianhat_projectile")
    --         local r = GetRandomMinMax(3, 5)
    --         local delta_angle = GetRandomMinMax(-90, 90)
    --         local angle = (owner:GetAngleToPoint(x, y, z) + delta_angle) * DEGREES
    --         gestalt.Transform:SetPosition(x + r * math.cos(angle), y, z + r * -math.sin(angle))
    --         gestalt:ForceFacePoint(x, y, z)
    --         gestalt:SetTargetPosition(Vector3(x, y, z))
    --         gestalt.components.follower:SetLeader(owner)

            if owner.components.sanity ~= nil then
                owner.components.sanity:DoDelta(3, true)
            end
        end
    end
end

local function mod_on_equip(inst, owner)
	inst.alterguardian_spawngestalt_fn_mod = function(_owner, _data)
		alterguardian_spawngestalt_fn_mod(inst, _owner, _data)
	end
	inst:ListenForEvent("onattackother", inst.alterguardian_spawngestalt_fn_mod, owner)
end

local function mod_on_unequip(inst, owner)
	inst:RemoveEventCallback("onattackother", inst.alterguardian_spawngestalt_fn_mod, owner)
end

AddPrefabPostInit("alterguardianhat", function(inst)
	inst:AddTag("mod_alterguardianhat")
	if inst and inst.components and inst.components.equippable then
		local old_on_equip = inst.components.equippable.onequipfn
		inst.components.equippable:SetOnEquip(function(_inst, _owner)
            mod_on_equip(_inst, _owner)
            old_on_equip(_inst, _owner)
        end)
		local old_on_unequip = inst.components.equippable.onunequipfn
		inst.components.equippable:SetOnUnequip(function(_inst, _owner)
			old_on_unequip(_inst, _owner)
			mod_on_unequip(_inst, _owner)
		end)
	end
end)
-------- 更强的启迪皇冠 --------