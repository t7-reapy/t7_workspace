#using scripts\codescripts\struct;

#using scripts\shared\callbacks_shared;
#using scripts\shared\math_shared; 
#using scripts\shared\util_shared;
#using scripts\shared\system_shared;
#using scripts\shared\filter_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\mirror.gsh;

#namespace mirror;

REGISTER_SYSTEM("mirror", &init, undefined)

function init()
{
    callback::on_localclient_connect(&_setup_mirror_on_player_connect);    
}

function private _setup_mirror_on_player_connect(localclientnum)
{
    util::waitforclient(localclientnum);
    for (i = 0; i < 4; i++)
    {
        mirror = GetEnt(localclientnum, MIRROR_TARGETNAME_PREFIX + (i + 1), "targetname");
        if (!isdefined(mirror))
        {
            continue;
        }

        mirror SetExtraCam(i, MIRROR_HORIZONTAL_RESOLUTION, MIRROR_VERTICAL_RESOLUTION);

        mirror thread _track_player_and_update_camera(i, localclientnum);
    }
}

function private _track_player_and_update_camera(cam_id, localclientnum)
{
    if (ENABLE_TRUE_MIRROR)
    {
        self thread _track_player_and_update_camera_true_mirror(cam_id, localclientnum);
    }
    else
    {
        self thread _track_player_and_update_camera_approx_mirror(cam_id, localclientnum);
    }
}

function private _track_player_and_update_camera_true_mirror(cam_id, localclientnum)
{
    camera = self;
    camera_original_angle = camera.angles;
    camera_normal_vector = AnglesToForward(camera_original_angle);
    camera_original_origin = camera.origin;   

    while (true)
    {
        WAIT_CLIENT_FRAME;

        player_eye = GetLocalClientEyePos(localclientnum);

        // Signed distance from the player to the mirror plane, along N
        player_to_mirror = camera_original_origin - player_eye;
        signed_distance = VectorDot(player_to_mirror, camera_normal_vector);

        // Player behind the mirror -> skip
        if (signed_distance <= 0)
            continue;

        // Reflect player across the mirror plane
        reflected_player = player_eye + 2 * signed_distance * camera_normal_vector;

        // Place virtual cam at reflected player, look toward the mirror
        camera.origin = reflected_player;
        look_dir = camera_original_origin - reflected_player;
        camera.angles = VectorToAngles(look_dir);

        // Focal length based on actual eye -> mirror distance
        player_distance = Distance(player_eye, camera_original_origin);
        focal_length = _linear_map(player_distance, 0, MAX_DISTANCE, MIN_FOCAL_LENGTH, MAX_FOCAL_LENGTH);
        camera SetExtraCamFocalLength(cam_id, focal_length);
    }
}

function private _track_player_and_update_camera_approx_mirror(cam_id, localclientnum)
{
    camera = self;
    camera_original_angle = camera.angles;
    camera_normal_vector = AnglesToForward(camera_original_angle);
    camera_original_origin = camera.origin;   

    while (true)
    {
        WAIT_CLIENT_FRAME;

        player_eye = GetLocalClientEyePos(localclientnum);

        to_mirror = camera_original_origin - player_eye;
        depth = VectorDot(to_mirror, camera_normal_vector);

        if (depth <= 0)
            continue;

        // Virtual correct viewpoint (we don't actually go there)
        reflected_player = player_eye + 2 * depth * camera_normal_vector;

        // Unit vector from P' toward M - the "correct" optical axis
        axis = camera_original_origin - reflected_player;
        axis_length = Length(axis);
        axis_dir = axis / axis_length;

        // Push the camera behind the mirror ALONG this axis, not along N
        camera.origin = camera_original_origin - PUSH_DISTANCE * axis_dir;
        camera.angles = VectorToAngles(axis_dir);

        player_distance = Distance(player_eye, camera_original_origin);
        focal_length = _linear_map(player_distance, 0, MAX_DISTANCE, MIN_FOCAL_LENGTH, MAX_FOCAL_LENGTH);
        camera SetExtraCamFocalLength(cam_id, focal_length);
    }
}

function private _linear_map(value, in_min, in_max, out_min, out_max)
{
    t = (value - in_min) / (in_max - in_min);
    t = math::clamp(t, 0, 1);
    return out_min + (out_max - out_min) * t;
}
