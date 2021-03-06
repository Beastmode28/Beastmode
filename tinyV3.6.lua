local Tiny = {}

Tiny.optionKey = Menu.AddKeyOption({"Hero Specific","Tiny"},"Combo Key",Enum.ButtonCode.KEY_F)
Tiny.optionEnable = Menu.AddOption({"Hero Specific","Tiny"},"Enabled","Enable Or Disable Tiny Combo Script")

Tiny.optionComOrder = Menu.AddKeyOption({"Hero Specific","Tiny","CustomOrder"},"Custom combo order key",Enum.ButtonCode.KEY_G)

Tiny.orders = {}

for i = 1, 8 do
        local temp = ""
        if i < 10 then temp = "0" end
        Tiny.orders[i] = Menu.AddOption({"Hero Specific","Tiny","CustomOrder"},
             "Cast Spell " .. temp .. i .. " :", "List:\r\n1 - Blink\r\n2 - Veil\r\n3 - Bloodthorn\r\n4 - Etherealblade\r\n5 - Avalanche\r\n6 - Toss" ..
             "\r\n7 - Dagon"
             , 1, 8)
end

local MenuItems = {}
MenuItems[1] =  "Off"
MenuItems[2] =  "Blink"
MenuItems[3] =  "Veil"
MenuItems[4] =  "Bloodthorn"
MenuItems[5] =  "Etherealblade"
MenuItems[6] =  "Avalanche"
MenuItems[7] =  "Toss"
MenuItems[8] =  "Dagon"

for k, v in pairs(MenuItems) do
       for i = 1, 8 do
               Menu.SetValueName(Tiny.orders[i], k, v)
       end
end

Tiny.optionDagon = Menu.AddOption({"Hero Specific","Tiny"},"Auto Dagon","Enable or Disable Using Dagon After Combo")
Tiny.optionBlink = Menu.AddOption({"Hero Specific","Tiny"},"Blink","Use Blink to nearest enemy where cursor is pointed at time of cast")
Tiny.optionVeil = Menu.AddOption({"Hero Specific","Tiny"},"Veil","Radius blast that increses magic damage by 25%")
Tiny.optionBloodthorn = Menu.AddOption({"Hero Specific","Tiny"},"Bloodthorn","Uses thorn in combo to increase damage taken")
Tiny.optionEtherealblade = Menu.AddOption({"Hero Specific","Tiny"},"Etherealblade","damages enemy 2x your primary att. +75 mag. damage + slow")
Tiny.calculator = Menu.AddOption({"Hero Specific","Tiny"},"Damage Calculator","")


Tiny.font = Renderer.LoadFont("Tahoma", 20, Enum.FontWeight.EXTRABOLD)


time = 0
lastcasttime = 0
ordernow = 0
delay = 0

function Tiny.OnUpdate()
    if not Menu.IsEnabled(Tiny.optionEnable) then return true end
    if Menu.IsKeyDown(Tiny.optionKey) or Menu.IsKeyDown(Tiny.optionComOrder) then
            Tiny.Skycombo()
    end
end

function Tiny.OnDraw()
    if not Menu.IsEnabled(Tiny.calculator) then return true end
    
    local myHero = Heroes.GetLocal()
    if NPC.GetUnitName(myHero) ~= "npc_dota_hero_tiny" then return end
        local totaldmg = 0
        local xfactor = 1;
    
        local etherealblade = NPC.GetItem(myHero, "item_ethereal_blade", true)
        if etherealblade and Menu.IsEnabled(Tiny.optionEtherealblade) then xfactor = xfactor + 0.4 totaldmg = totaldmg + 75 + (Hero.GetIntellectTotal(myHero) * 2) end

        local veil = NPC.GetItem(myHero, "item_veil_of_discord", true)
        if veil and Menu.IsEnabled(Tiny.optionVeil) then xfactor = xfactor + 0.25 end

    local bloodthorn = NPC.GetItem(myHero, "item_bloodthorn", true)
        if bloodthorn and Menu.IsEnabled(Tiny.optionBloodthorn) then xfactor = xfactor + 0.30 end

        for i = 0, 5 do
		local dagon = NPC.GetItem(myHero, "item_dagon_" .. i, true)
		if i == 0 then dagon = NPC.GetItem(myHero, "item_dagon", true) end
        if dagon and Menu.IsEnabled(Tiny.optionDagon) then
			totaldmg = totaldmg + ( Ability.GetLevelSpecialValueFor(dagon, "damage") * xfactor)
		end
    end

        local avalanche = NPC.GetAbilityByIndex(myHero, 0)
        local toss = NPC.GetAbilityByIndex(myHero, 1)
        local grow = NPC.GetAbilityByIndex(myHero,3)
        local aghs = NPC.GetItem(myHero, "item_ultimate_scepter", true)

        if Ability.GetLevel(avalanche) > 0 then totaldmg = totaldmg + (Ability.GetLevelSpecialValueFor(avalanche, "avalanche_damage") * xfactor) end
	if Ability.GetLevel(toss) > 0 then totaldmg = totaldmg + (Ability.GetLevelSpecialValueFor(toss, "toss_damage") * xfactor) end
        if Ability.GetLevel(grow) == 1 then totaldmg = totaldmg + (Ability.GetLevelSpecialValueFor(toss, "toss_damage") * 0.35 * xfactor) end
        if Ability.GetLevel(grow) == 2 then totaldmg = totaldmg + (Ability.GetLevelSpecialValueFor(toss, "toss_damage") * 0.50 * xfactor) end
        if Ability.GetLevel(grow) == 3 then totaldmg = totaldmg + (Ability.GetLevelSpecialValueFor(toss, "toss_damage") * 0.65 * xfactor) end
        if aghs and Ability.GetLevel(grow) == 1 then totaldmg = totaldmg + (Ability.GetLevelSpecialValueFor(toss, "toss_damage") * 0.50 * xfactor) end
        if aghs and Ability.GetLevel(grow) == 2 then totaldmg = totaldmg + (Ability.GetLevelSpecialValueFor(toss, "toss_damage") * 0.65 * xfactor) end
        if aghs and Ability.GetLevel(grow) == 3 then totaldmg = totaldmg + (Ability.GetLevelSpecialValueFor(toss, "toss_damage") * 0.80 * xfactor) end


        Renderer.SetDrawColor(0, 0, 0, 255)
        Renderer.DrawFilledRect(0, 180, 160, 40)
    
        Renderer.SetDrawColor(255, 255, 255, 255)
        Renderer.DrawText(Tiny.font, 10, 190, "T.D.~: " .. math.floor(totaldmg * 0.75), 1)
end

function Tiny.Skycombo()

    local myHero = Heroes.GetLocal()
    if NPC.GetUnitName(myHero) ~= "npc_dota_hero_tiny" then return end
    local hero = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
    if not hero then return end

    if (os.clock() - time) < delay then return end
    if (os.clock() - lastcasttime) > 3 then order = 0 end

    local heroPos = NPC.GetAbsOrigin(hero)
    local avalanche = NPC.GetAbilityByIndex(myHero, 0)
    local toss = NPC.GetAbilityByIndex(myHero, 1)


    local blink = NPC.GetItem(myHero, "item_blink", true)
    local veil = NPC.GetItem(myHero, "item_veil_of_discord", true)  
    local bloodthorn = NPC.GetItem(myHero, "item_bloodthorn", true) 
    local etherealblade = NPC.GetItem(myHero, "item_ethereal_blade", true)


    local myMana = NPC.GetMana(myHero)
    local mousePos = Input.GetWorldCursorPos()
        local customCastNow = 1
        -- For order
        if Menu.IsKeyDown(Tiny.optionComOrder) then
            ordernow = ordernow +1
            if ordernow == 9 then ordernow = 1 end
            customCastNow = Menu.GetValue(Tiny.orders[ordernow])
        end
        lastcasttime = os.clock()

    -- 2. Blink
    if blink and Menu.IsEnabled(Tiny.optionBlink) and Ability.IsCastable(blink, myMana) and (not Menu.IsKeyDown(Tiny.optionComOrder) or customCastNow== 2) then Ability.CastPosition(blink, heroPos) MakeDelay(0.1) return end  
    
    -- 3. Veil
    if veil and Menu.IsEnabled(Tiny.optionVeil) and Ability.IsCastable(veil,myMana) and (not Menu.IsKeyDown(Tiny.optionComOrder) or customCastNow == 3) then Ability.CastPosition(veil, heroPos) return end
    
    -- 4. Bloodthorn
    if bloodthorn and Menu.IsEnabled(Tiny.optionBloodthorn) and Ability.IsCastable(bloodthorn,myMana) and (not Menu.IsKeyDown(Tiny.optionComOrder) or customCastNow == 4) then Ability.CastTarget(bloodthorn, hero) return end

    -- 5. Etherealblade
    if etherealblade and Menu.IsEnabled(Tiny.optionEtherealblade) and Ability.IsCastable(etherealblade,myMana) and (not Menu.IsKeyDown(Tiny.optionComOrder) or customCastNow == 5) then Ability.CastTarget(etherealblade, hero) return end
    
    --6. Avalanche
    if Menu.IsEnabled(Tiny.optionEnable) and avalanche and Ability.IsCastable(avalanche, myMana) and (not Menu.IsKeyDown(Tiny.optionComOrder) or customCastNow == 6) then Ability.CastPosition(avalanche, heroPos) return end

    --7. Toss
    if Menu.IsEnabled(Tiny.optionEnable) and toss and Ability.IsCastable(toss, myMana) and (not Menu.IsKeyDown(Tiny.optionComOrder) or customCastNow == 7) then Ability.CastTarget(toss, hero) return end
    
    -- 8. Dagon
    for i = 0, 5 do
    local dagon = NPC.GetItem(myHero, "item_dagon_".. i, true)
        if i==0 then dagon = NPC.GetItem(myHero, "item_dagon", true) end
    if dagon and hero and Ability.IsCastable(dagon, myMana) and Menu.IsEnabled(Tiny.optionDagon) and (not Menu.IsKeyDown(Tiny.optionComOrder) or customCastNow == 8) then Ability.CastTarget(dagon, hero) return end
    end

end

function MakeDelay(sec)
        delay = sec
        time = os.clock()
end

return Tiny
