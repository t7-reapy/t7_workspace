#using scripts\shared\math_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared; 
#using scripts\shared\callbacks_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\weapon_mod.gsh;

REGISTER_SYSTEM( "weapon_mod", &init, undefined )

#namespace weapon_mod;

function init()
{
	if(!IsSplitScreen())
	{
		callback::on_localplayer_spawned( &on_player_spawned );
	
		util::waitforclient( 0 );
	
		setDvar( "cg_gun_x", 0 );
		setDvar( "cg_gun_y", 0 );
		setDvar( "cg_gun_z", 0 );
	}
}

function on_player_spawned(localClientNum)
{
	// base pose
	self.vm_base = (0, 0, 0);

	// sway spring
	self.vm_sway_pos = (0, 0, 0);
	self.vm_sway_vel = (0, 0, 0);
	self.vm_sway_target_raw = (0, 0, 0);
	self.vm_sway_target = (0, 0, 0);

	// movement spring
	self.vm_walk_pos = (0, 0, 0);
	self.vm_walk_vel = (0, 0, 0);

	// recoil spring
	self.vm_recoil_pos = (0, 0, 0);
	self.vm_recoil_vel = (0, 0, 0);

	// gun bob
	self.vm_bob_pos   = (0, 0, 0);
	self.vm_bob_phase = 0;

	self.vm_adsSettling = false;
	self.vm_adsPostSettleEndTime = 0;

	self._nextSwayTime = 0;
	self._wasADS = false;

	self.vm_bob_grounded = 1.0; // start fully grounded

	// ADS blend (0 = hip, 1 = ADS)
	self.vm_adsBlend = (IsADS(localClientNum) ? 1.0 : 0.0);

	self thread viewmodel_fire_monitor(localClientNum);
	self thread viewmodel_update_loop(localClientNum);
}

function viewmodel_update_loop(localClientNum)
{
	level endon("end_game");
	level endon("intermission");
	self endon("disconnect");

	lastTime = getTime();

	while (true)
	{
		
		// DeltaTime
		now = getTime();
		dt = (now - lastTime) * 0.001;
		lastTime = now;

		if ( dt <= 0 ) dt = 0.001;
		if ( dt > MAXDT ) dt = MAXDT;

		if ( !self isPlayer() )
			return;

		
		// ADS STATE
		isAds = IsADS(localClientNum);

		adsTarget = (isAds ? 1.0 : 0.0);

		// time-based exponential blend
		blendStep = math::clamp(ADS_BLEND_SPEED * dt, 0.0, 1.0);
		self.vm_adsBlend += (adsTarget - self.vm_adsBlend) * blendStep;

		adsAlpha = self.vm_adsBlend;

		// BASE POSE
		self.vm_base = smooth_vec(self.vm_base, (0,0,0), BASERATE);

		// MOVEMENT DATA
		vel = self GetVelocity();

		angs = GetCamAnglesByLocalClientNum(localClientNum);
		yaw = angs[1];

		fwd   = yaw_to_forward(yaw);
		right = yaw_to_right(yaw);

		fwdSpeed   = vec_dot(vel, fwd);
		rightSpeed = vec_dot(vel, right);

		// Detect swimming
		inWater = IsSwimming(localClientNum);
		
		// Detect real airtime (ignore small slope Z movement)
		zVel = vel[2];
		inAir = (abs(zVel) > 120); // <-- key fix (tune this)
		
		// Final grounded state
		grounded = (!inAir && !inWater ? 1.0 : 0.0);
		
		// smooth (dt-based)
		groundLerp = math::clamp(10.0 * dt, 0.0, 1.0);
		self.vm_bob_grounded += (grounded - self.vm_bob_grounded) * groundLerp;

	    // MOVEMENT GUN BOB
	    horizontalVel = (vel[0], vel[1], 0);
		moveSpeed = sqrt(vec_dot(horizontalVel, horizontalVel));
	    move01 = math::clamp(moveSpeed / HIP_SPEED_REF, 0.0, 1.0);

	    bobFreq = lerp(HIP_BOB_FREQ, ADS_BOB_FREQ, adsAlpha);
	    self.vm_bob_phase += dt * bobFreq * 6.28318;

	    bobX = lerp(HIP_BOB_X, ADS_BOB_X, adsAlpha);
	    bobY = lerp(HIP_BOB_Y, ADS_BOB_Y, adsAlpha);
	    bobZ = lerp(HIP_BOB_Z, ADS_BOB_Z, adsAlpha);

	    bobScale = lerp(HIP_BOB_SCALE, ADS_BOB_SCALE, adsAlpha);


	    bob = (
    	cos(self.vm_bob_phase) * bobX * move01 * bobScale,
    	sin(self.vm_bob_phase * 0.5) * bobY * move01 * bobScale,
    	abs(sin(self.vm_bob_phase)) * bobZ * move01 * bobScale
	);
		self.vm_bob_pos = vec_scale(bob, self.vm_bob_grounded);

		// MOVEMENT OFFSET
		fwd01_hip   = math::clamp(fwdSpeed   / HIP_SPEED_REF,-1,1);
		right01_hip = math::clamp(rightSpeed / HIP_SPEED_REF,-1,1);

		fwd01_ads   = math::clamp(fwdSpeed   / ADS_SPEED_REF,-1,1);
		right01_ads = math::clamp(rightSpeed / ADS_SPEED_REF,-1,1);

		// HIP
		hip_strafeAmt = HIP_STRAFEMAX * right01_hip;
		hip_downAmt = HIP_FORWARDDOWNMAX * maxf(0.0, fwd01_hip);
		hip_backAmt = HIP_BACKMAX * maxf(0.0, -fwd01_hip);
		hip_backDownAmt = HIP_BACKDOWNMAX * maxf(0.0, -fwd01_hip);

		hipMoveTarget = ( hip_backAmt, hip_strafeAmt, hip_downAmt + hip_backDownAmt );

		// ADS
		ads_strafeAmt = ADS_STRAFEMAX * right01_ads;
		ads_forwardBackAmt = ADS_FORWARDBACKMAX * maxf(0.0, fwd01_ads);
		ads_backAmt = ADS_BACKMAX * maxf(0.0, -fwd01_ads);
		ads_downAmt = ADS_DOWNMAX * maxf(0.0, fwd01_ads);
		ads_backDownAmt = ADS_BACKDOWNMAX * maxf(0.0, -fwd01_ads);

		adsMoveTarget = (
			ads_backAmt + ads_forwardBackAmt,
			ads_strafeAmt,
			ads_downAmt + ads_backDownAmt
		);

		moveTarget = lerp_vec(hipMoveTarget, adsMoveTarget, adsAlpha);

		move_stiffness = lerp(HIP_MOVE_STIFFNESS, ADS_MOVE_STIFFNESS, adsAlpha);
		move_damping   = lerp(HIP_MOVE_DAMPING,   ADS_MOVE_DAMPING,   adsAlpha);

		moveOffset = vec_sub(moveTarget, self.vm_walk_pos);
		moveAccel  = vec_sub(
			vec_scale(moveOffset, move_stiffness),
			vec_scale(self.vm_walk_vel, move_damping)
		);

		self.vm_walk_vel = vec_add(self.vm_walk_vel, vec_scale(moveAccel, dt));
		self.vm_walk_pos = vec_add(self.vm_walk_pos, vec_scale(self.vm_walk_vel, dt));

		// ADS SETTLING
		if ( isAds && !self._wasADS )
		{
			self.vm_adsSettling = true;
			self.vm_adsPostSettleEndTime = getTime() + 200;
		}

		self._wasADS = isAds;

		// SWAY
		if ( !self.vm_adsSettling )
		{
			sway_range_x = lerp(HIP_SWAY_RANGE_X, ADS_SWAY_RANGE_X, adsAlpha);
			sway_range_y = lerp(HIP_SWAY_RANGE_Y, ADS_SWAY_RANGE_Y, adsAlpha);
			sway_range_z = lerp(HIP_SWAY_RANGE_Z, ADS_SWAY_RANGE_Z, adsAlpha);

			sway_stiffness = lerp(HIP_SWAY_STIFFNESS, ADS_SWAY_STIFFNESS, adsAlpha);
			sway_damping   = lerp(HIP_SWAY_DAMPING,   ADS_SWAY_DAMPING,   adsAlpha);
			sway_follow    = lerp(HIP_SWAY_FOLLOW,    ADS_SWAY_FOLLOW,    adsAlpha);

			if ( now > self._nextSwayTime )
			{
				self.vm_sway_target_raw = (
					randomfloatrange(-sway_range_x, sway_range_x),
					randomfloatrange(-sway_range_y, sway_range_y),
					randomfloatrange(-sway_range_z, sway_range_z)
				);

				swayTimeMin = lerp(HIP_SWAY_TIME_MIN, ADS_SWAY_TIME_MIN, adsAlpha);
				swayTimeMax = lerp(HIP_SWAY_TIME_MAX, ADS_SWAY_TIME_MAX, adsAlpha);
				self._nextSwayTime = now + int(randomfloatrange(swayTimeMin, swayTimeMax));
			}

			self.vm_sway_target = smooth_vec(self.vm_sway_target, self.vm_sway_target_raw, sway_follow);

			offset = vec_sub(self.vm_sway_target, self.vm_sway_pos);
			accel  = vec_sub(
				vec_scale(offset, sway_stiffness),
				vec_scale(self.vm_sway_vel, sway_damping)
			);

			self.vm_sway_vel = vec_add(self.vm_sway_vel, vec_scale(accel, dt));
			self.vm_sway_pos = vec_add(self.vm_sway_pos, vec_scale(self.vm_sway_vel, dt));
		}
		else if ( getTime() >= self.vm_adsPostSettleEndTime )
		{
			self.vm_adsSettling = false;
		}

		// RECOIL SPRING
		recoil_offset = vec_sub((0,0,0), self.vm_recoil_pos);
		recoil_accel  = vec_sub(
			vec_scale(recoil_offset, RECOIL_STIFFNESS),
			vec_scale(self.vm_recoil_vel, RECOIL_DAMPING)
		);

		self.vm_recoil_vel = vec_add(self.vm_recoil_vel, vec_scale(recoil_accel, dt));
		self.vm_recoil_pos = vec_add(self.vm_recoil_pos, vec_scale(self.vm_recoil_vel, dt));

		// FINAL COMPOSITE
		final = self.vm_base + self.vm_sway_pos + self.vm_walk_pos + self.vm_bob_pos + self.vm_recoil_pos;

		setDvar("cg_gun_x", final[0]);
		setDvar("cg_gun_y", final[1]);
		setDvar("cg_gun_z", final[2]);

		wait(0.016);
	}
}

function add_viewmodel_recoil(adsAlpha)
{
	recoil_up   = lerp(HIP_RECOIL_UP,   ADS_RECOIL_UP,   adsAlpha);
	recoil_back = lerp(HIP_RECOIL_BACK, ADS_RECOIL_BACK, adsAlpha);
	recoil_side = lerp(HIP_RECOIL_SIDE, ADS_RECOIL_SIDE, adsAlpha);

	recoil_side *= (randomint(2) == 0 ? -1 : 1);

	self.vm_recoil_pos = vec_add(
		self.vm_recoil_pos,
		(recoil_back, recoil_side, recoil_up)
	);
}

function viewmodel_fire_monitor(localClientNum)
{
	level endon("end_game");
	level endon("intermission");
	self endon("disconnect");

	while (1)
	{
		self waittill("weapon_fired");
		self add_viewmodel_recoil(self.vm_adsBlend);
	}
}

// VECTOR MATH HELPERS
function smooth_vec(current, target, rate)
{
	return (
		current[0] + (target[0] - current[0]) * rate,
		current[1] + (target[1] - current[1]) * rate,
		current[2] + (target[2] - current[2]) * rate
	);
}

function lerp(a, b, t) { return a + (b - a) * t; }

function lerp_vec(a, b, t)
{
	return (
		lerp(a[0], b[0], t),
		lerp(a[1], b[1], t),
		lerp(a[2], b[2], t)
	);
}

function vec_add(a, b)   { return (a[0]+b[0], a[1]+b[1], a[2]+b[2]); }
function vec_sub(a, b)   { return (a[0]-b[0], a[1]-b[1], a[2]-b[2]); }
function vec_scale(v, s){ return (v[0]*s, v[1]*s, v[2]*s); }
function vec_dot(a,b)   { return a[0]*b[0] + a[1]*b[1] + a[2]*b[2]; }

function maxf(a,b) { if (a > b) return a; return b; }

function yaw_to_forward(yaw) { return (cos(yaw), sin(yaw), 0); }
function yaw_to_right(yaw)   { return (-sin(yaw), cos(yaw), 0); }