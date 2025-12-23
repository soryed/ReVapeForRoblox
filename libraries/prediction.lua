--[[
	Prediction Library
	Source: https://devforum.roblox.com/t/predict-projectile-ballistics-including-gravity-and-motion/1842434
]]

-- rewritten by soryed!

local module = {}
local eps = 1e-9


local function isZero(d)
	return (d > -eps and d < eps)
end

local function cuberoot(x)
	return (x > 0) and math.pow(x, 1/3) or -math.pow(math.abs(x), 1/3)
end


local function solveQuadric(c0, c1, c2)
	local p = c1 / (2 * c0)
	local q = c2 / c0
	local D = p*p - q

	if isZero(D) then
		return -p
	elseif D < 0 then
		return
	else
		local s = math.sqrt(D)
		return s - p, -s - p
	end
end

local function solveCubic(c0, c1, c2, c3)
	local A = c1 / c0
	local B = c2 / c0
	local C = c3 / c0

	local sqA = A*A
	local p = (1/3)*(-(1/3)*sqA + B)
	local q = 0.5*((2/27)*A*sqA - (1/3)*A*B + C)

	local cbp = p*p*p
	local D = q*q + cbp

	local s0, s1, s2, num

	if isZero(D) then
		if isZero(q) then
			s0, num = 0, 1
		else
			local u = cuberoot(-q)
			s0, s1, num = 2*u, -u, 2
		end
	elseif D < 0 then
		local phi = (1/3)*math.acos(-q / math.sqrt(-cbp))
		local t = 2*math.sqrt(-p)
		s0 = t*math.cos(phi)
		s1 = -t*math.cos(phi + math.pi/3)
		s2 = -t*math.cos(phi - math.pi/3)
		num = 3
	else
		local sd = math.sqrt(D)
		local u = cuberoot(sd - q)
		local v = -cuberoot(sd + q)
		s0, num = u + v, 1
	end

	local sub = (1/3)*A
	if num and num > 0 then s0 -= sub end
	if num and num > 1 then s1 -= sub end
	if num and num > 2 then s2 -= sub end

	return s0, s1, s2
end

function module.solveQuartic(c0, c1, c2, c3, c4)
	local A = c1 / c0
	local B = c2 / c0
	local C = c3 / c0
	local D = c4 / c0

	local sqA = A*A
	local p = -0.375*sqA + B
	local q = 0.125*sqA*A - 0.5*A*B + C
	local r = -(3/256)*sqA*sqA + 0.0625*sqA*B - 0.25*A*C + D

	local s0, s1, s2, s3, num
	local coeffs = {}

	if isZero(r) then
		coeffs = {1, 0, p, q}
		s0, s1, s2 = solveCubic(coeffs[1], coeffs[2], coeffs[3], coeffs[4])
	else
		coeffs[1] = 1
		coeffs[2] = -0.5*p
		coeffs[3] = -r
		coeffs[4] = 0.5*r*p - 0.125*q*q

		local z = solveCubic(coeffs[1], coeffs[2], coeffs[3], coeffs[4])
		if not z then return end

		local u = z*z - r
		local v = 2*z - p

		if u < 0 or v < 0 then return end
		u = isZero(u) and 0 or math.sqrt(u)
		v = isZero(v) and 0 or math.sqrt(v)

		local function quad(a, b)
			return solveQuadric(1, b, a)
		end

		s0, s1 = quad(z - u, q < 0 and -v or v)
		s2, s3 = quad(z + u, q < 0 and v or -v)
	end

	local sub = 0.25*A
	if s0 then s0 -= sub end
	if s1 then s1 -= sub end
	if s2 then s2 -= sub end
	if s3 then s3 -= sub end

	return {s3, s2, s1, s0}
end



local function getPingSeconds()
	local ping = math.round(game.Players.LocalPlayer:GetNetworkPing() * 1000)
	if ping <= 0 then
		ping = 10
	end
	return ping
end

function module.predictStrafingMovement(targetPlayer, targetPart, projSpeed, gravity, origin)
	if not targetPlayer or not targetPlayer.Character or not targetPart then
		return targetPart and targetPart.Position or Vector3.zero
	end

	local pos = targetPart.Position
	local vel = targetPart.Velocity
	local dist = (pos - origin).Magnitude

	local time = (dist / projSpeed)
	if dist > 80 then time *= 0.95
	elseif dist > 50 then time *= 0.98
	elseif dist < 20 then time *= 1.08 end

	local hVel = Vector3.new(vel.X, 0, vel.Z)
	local hPred = hVel * time * (dist > 70 and 0.7 or dist > 40 and 0.75 or 0.88)

	local vPred
	if vel.Y < -15 then
		vPred = vel.Y * time * 0.32
	elseif vel.Y > 10 then
		vPred = vel.Y * time * 0.28
	elseif math.abs(vel.Y) < 3 then
		vPred = -2 * time
	else
		vPred = vel.Y * time * 0.25
	end

	return pos + hPred + Vector3.new(0, vPred, 0)
end


local function predictWithPing(targetPlayer, targetPart, projSpeed, gravity, origin)
	local ping = getPingSeconds()
	local base = predictStrafingMovement(targetPlayer, targetPart, projSpeed, gravity, origin)
	local lead = targetPart.Velocity * ping

	lead = Vector3.new(
		lead.X,
		math.clamp(lead.Y, -6, 6),
		lead.Z
	)

	return base + lead
end

function module.SolveTrajectory(origin, projectileSpeed, gravity, targetPos, targetVelocity, playerGravity, playerHeight, playerJump, params, targetPlayer, targetPart)

	if targetPlayer and targetPart then
		targetPos = predictWithPing(targetPlayer, targetPart, projectileSpeed, gravity, origin)
		targetVelocity = targetPart.Velocity
	end

	local disp = targetPos - origin
	local p, q, r = targetVelocity.X, targetVelocity.Y, targetVelocity.Z
	local h, j, k = disp.X, disp.Y, disp.Z
	local l = -0.5 * gravity

	local solutions = module.solveQuartic(
		l*l,
		-2*q*l,
		q*q - 2*j*l - projectileSpeed^2 + p*p + r*r,
		2*j*q + 2*h*p + 2*k*r,
		j*j + h*h + k*k
	)

	if solutions then
		for _, t in ipairs(solutions) do
			if t and t > 0 then
				local vx = (h + p*t)/t
				local vy = (j + q*t - l*t*t)/t
				local vz = (k + r*t)/t
				return origin + Vector3.new(vx, vy, vz)
			end
		end
	elseif gravity == 0 then
		local t = disp.Magnitude / projectileSpeed
		return origin + (disp + targetVelocity * t)
	end
end

return module
