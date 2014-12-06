nosurf_enabled = CreateConVar("nosurf_enabled", "1", {FVCAR_REPLICATED, FCVAR_ARCHIVE}, "Should we reprimand players for trying to propsurf?")
nosurf_admins = CreateConVar("nosurf_admins", "1", {FVCAR_REPLICATED, FCVAR_ARCHIVE}, "Should we also reprimand admins?")
nosurf_speedtolerance = CreateConVar("nosurf_speedtolerance", "128", {FVCAR_REPLICATED, FCVAR_ARCHIVE}, "How fast should they have to be travelling upwards to be killed?")

hook.Add("Think", "NoSurf", function()
	if nosurf_enabled:GetBool() then
		for k,v in pairs(player.GetAll()) do
			if not v:IsAdmin() or v:IsAdmin() and nosurf_admins:GetBool() then
				local speed = v:GetVelocity():Length()
				local weapon = v:GetActiveWeapon()
				local aim = v:GetEyeTrace().Entity
				local trace = util.QuickTrace( v:GetPos() + Vector(0, 0, 64), Vector(0, 0, -128), v)
				
				if not weapon then continue end
				if not weapon.GetClass then continue end
				if not v:Alive() then continue end
				if not IsValid(aim) then continue end
				
				if weapon:GetClass() == "weapon_physgun" then
					if speed >= math.Clamp(nosurf_speedtolerance:GetInt(), 1, 512) then -- just in case someone sets it to 0 or something stupid.
						if v:KeyDown(IN_ATTACK) then
							if aim:IsPlayerHolding() then
								if v:GetMoveType() != MOVETYPE_NOCLIP then
									if IsValid(trace.Entity) and trace.Entity == aim then
										v:SetNWString("deadreason", "Propsurfing is not allowed.")
										v:Kill()
									end
								end
							end
						end
					end
				end
			end
		end
	end
end)
