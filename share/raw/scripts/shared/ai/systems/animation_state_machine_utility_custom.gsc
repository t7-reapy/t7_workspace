#using scripts\shared\ai\archetype_utility;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\ai\systems\animation_state_machine.gsh;

#namespace AnimationStateNetworkUtilityCustom;

function RequestState( entity, stateName )
{
	/#
		Assert( isDefined( entity ) );
	#/
	entity ASMRequestSubstate( stateName );
}

function SearchAnimationMap( entity, aliasname )
{
	if ( isDefined( entity ) && isDefined( aliasname ) )
	{
		animationName = entity AnimMappingSearch( istring( aliasname ) );
		if ( isDefined( animationName ) )
			return FindAnimByName( "generic", animationName );
		
	}
}