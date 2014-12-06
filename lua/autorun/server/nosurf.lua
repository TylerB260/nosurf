nosurf_enabled = CreateConVar("nosurf_enabled", "1", {FVCAR_REPLICATED, FCVAR_ARCHIVE}, "Should we reprimand players for trying to propsurf?")
nosurf_admins = CreateConVar("nosurf_admins", "1", {FVCAR_REPLICATED, FCVAR_ARCHIVE}, "Should we also reprimand admins?")
nosurf_speedtolerance = CreateConVar("nosurf_speedtolerance", "512", {FVCAR_REPLICATED, FCVAR_ARCHIVE}, "How fast should they have to be travelling upwards to be killed?")

hook.Add("PhysgunPickup", "NoSurf", function(ply, ent) ply.NoSurfEnt = ent end)
hook.Add("PhysgunDrop", "NoSurf", function(ply) ply.NoSurfEnt = nil end)

hook.Add("Think", "NoSurf", function()
	if nosurf_enabled:GetBool() then
		for k,v in pairs(player.GetAll()) do
			if not v:IsAdmin() or v:IsAdmin() and nosurf_admins:GetBool() then
				local speed = v:GetVelocity():Length()
				local speed2 = IsValid(v.NoSurfEnt) and v.NoSurfEnt:GetVelocity():Length() or 0
				
				local weapon = v:GetActiveWeapon()
				local aim = v.NoSurfEnt
				
				if not weapon then continue end
				if not weapon.GetClass then continue end
				if not v:Alive() then continue end
				if not IsValid(aim) then continue end
				
				local bottom = math.max(v:GetRunSpeed(), v:GetWalkSpeed()) + 32
				
				if weapon:GetClass() == "weapon_physgun" then -- just in case someone sets it to 0 or something stupid.
					if v:KeyDown(IN_ATTACK) and aim:IsPlayerHolding() and v:GetMoveType() != MOVETYPE_NOCLIP and not v:IsOnGround() then
						if speed >= math.Clamp(nosurf_speedtolerance:GetInt(), bottom, 2048) then
							if speed2 >= math.Clamp(nosurf_speedtolerance:GetInt(), bottom, 2048) then
								local trace = util.TraceHull({
									start = v:GetPos() + Vector(0, 0, 128),
									endpos = v:GetPos() + Vector(0, 0, -128),
									filter = function(ent) return ent != v end,
									mins = Vector( -128, -128, -128 ),
									maxs = Vector( 128, 128, 128 ),
									mask = MASK_SOLID
								})	
								
								if IsValid(trace.Entity) and trace.Entity == aim then
									local stop = hook.Call("PropSurfed", GM or  GAMEMODE, v, aim)
									
									-- for developers: return true in the above hook and it'll stop the killing.
									--game.ConsoleCommand("say "..(stop and "stopped" or "not stopped").."\n")
									if not stop then 
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
