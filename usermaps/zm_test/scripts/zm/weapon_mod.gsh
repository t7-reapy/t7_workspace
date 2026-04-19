// VIEWMODEL / WEAPON MOVEMENT CONFIG
// Axes: X = forward/back | Y = left/right | Z = up/down
// Units are cg_gun_* offsets

// Clamp delta-time to avoid huge jumps during hitches
#define MAXDT 0.05   // seconds (50ms)

// IDLE SWAY (HIPFIRE)
// Random drifting motion while standing still

// Sway range = size of the random sway "box"
#define HIP_SWAY_RANGE_X 0.0   // forward/back sway
#define HIP_SWAY_RANGE_Y 0.15  // left/right sway
#define HIP_SWAY_RANGE_Z 0.15  // up/down sway

// Spring tuning:
// - stiffness: how hard the gun pulls toward the target
// - damping:   how much motion is resisted (less bounce)
#define HIP_SWAY_STIFFNESS 10.0
#define HIP_SWAY_DAMPING   1.25

// How fast the sway target itself changes
// Lower = smoother, floatier | Higher = twitchier
#define HIP_SWAY_FOLLOW 0.15   // 0..1

// Time between new random sway targets (milliseconds)
#define HIP_SWAY_TIME_MIN 75
#define HIP_SWAY_TIME_MAX 100


// IDLE SWAY (ADS)
// Same system as hipfire, usually smaller + steadier

#define ADS_SWAY_RANGE_X 0.0
#define ADS_SWAY_RANGE_Y 0.05
#define ADS_SWAY_RANGE_Z 0.05

#define ADS_SWAY_STIFFNESS 15.0
#define ADS_SWAY_DAMPING   1.05

#define ADS_SWAY_FOLLOW 0.5

#define ADS_SWAY_TIME_MIN 25
#define ADS_SWAY_TIME_MAX 50


// MOVEMENT OFFSET (HIPFIRE)
// Weapon movement caused by player velocity

// Spring response for movement offsets
#define HIP_MOVE_STIFFNESS 25.0
#define HIP_MOVE_DAMPING   4.0

// Speed used to normalize player velocity
// Lower = effect reaches max sooner
#define HIP_SPEED_REF 190.0

// Movement amplitudes
#define HIP_STRAFEMAX        1.25   // Y: strafe left/right
#define HIP_FORWARDDOWNMAX -1.15   // Z: forward movement pushes gun down
#define HIP_BACKMAX        -1.25   // X: backward movement pulls gun back
#define HIP_BACKDOWNMAX    -0.9    // Z: backward movement also dips gun


// MOVEMENT OFFSET (ADS)
// Reduced + tighter version of hip movement

#define ADS_MOVE_STIFFNESS 115.0   //hip to ads transition speed when walking
#define ADS_MOVE_DAMPING   22.0
#define ADS_SPEED_REF      120.0

#define ADS_STRAFEMAX       0.01
#define ADS_FORWARDBACKMAX -0.65
#define ADS_BACKMAX        -0.05
#define ADS_DOWNMAX        -0.15
#define ADS_BACKDOWNMAX    -0.05


// VIEWMODEL RECOIL (SPRING RETURN)
// How fast recoil returns after a shot

#define RECOIL_STIFFNESS 85.0 // higher = snaps back faster
#define RECOIL_DAMPING   40.0 // higher = less bounce


// Per-shot recoil impulses
#define HIP_RECOIL_UP     0.15
#define HIP_RECOIL_BACK  -0.05
#define HIP_RECOIL_SIDE   0.15

#define ADS_RECOIL_UP     0.05
#define ADS_RECOIL_BACK   0.5
#define ADS_RECOIL_SIDE   0.08


// MOVEMENT GUN BOB
// Oscillating motion while walking/running

// Bob frequency (speed)
#define HIP_BOB_FREQ 65.5
#define ADS_BOB_FREQ 55.0

// Bob amplitudes
#define HIP_BOB_X 0.05
#define HIP_BOB_Y 0.95
#define HIP_BOB_Z 0.65

#define ADS_BOB_X 0.05
#define ADS_BOB_Y 0.35
#define ADS_BOB_Z 0.35

// Overall bob strength
#define HIP_BOB_SCALE 0.85
#define ADS_BOB_SCALE 0.35

// TRANSITIONS

// Higher = snappier | Lower = smoother, heavier
// ADS blend speed (units: per-second)
#define ADS_BLEND_SPEED 6.5

// Base pose smoothing rate
#define BASERATE 0.08