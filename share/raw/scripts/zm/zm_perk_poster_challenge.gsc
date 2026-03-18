//*****************************************************************************
// Fearlessninja98's Perk Poster Challenge
//*****************************************************************************

function autoexec main()
{
	level.shootableEE = 0;
	thread handlePoster("speed_cola");
	thread handlePoster("quick_revive");
	thread handlePoster("juggernog");
	thread handlePoster("double_tap");
}

function handlePoster(perk)
{
	trig = GetEntArray(perk + "_poster_trigger", "targetname");
    model = GetEntArray(perk + "_poster", "targetname");
    x = RandomInt(trig.size);

    for (i = 0; i < trig.size; i++)
    {
        if (i != x)
        {
            trig[i] Delete();
			model[i] Delete();
        }
    }

	trig[x] waittill("trigger", player);
	level.shootableEE++;
	
	if(level.shootableEE == 4)
	{
		level.perk_purchase_limit++;
	}

	model[x] Delete();
	trig[x] Delete();
}