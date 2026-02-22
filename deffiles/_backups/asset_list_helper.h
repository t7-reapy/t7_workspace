string GetItemCountItem( string prefix )
{
	return prefix + "Count";
}

int GetCount( asset Asset, string prefix )
{
	return Asset.GetEntryVariable( GetItemCountItem( prefix ) ).GetValue().ToInt();
}

string GetItemForIndex( string prefix, int index )
{
	string item = prefix;
	if ( index < 10 )
	{
		item += "0";
	}
	item += index;
	return item;
}

string GetItemName( string displayPrefix, int index )
{
	return displayPrefix + " " + index;
}

bool IsItemValid( asset Asset, string prefix, int index )
{
	return index >= 1 && index <= GetCount( Asset, prefix );
}

bool ItemHasValue( asset Asset, string prefix, int index )
{
	string item = GetItemForIndex( prefix, index );
	return (Asset.GetEntryVariable( item ).GetValue() != "");
}

void CopyObject( asset Asset, string prefix, int indexA, int indexB )
{
	string itemA = GetItemForIndex( prefix, indexA );
	string itemB = GetItemForIndex( prefix, indexB );

	Asset.GetEntryVariable( itemA ).SetValue( Asset.GetEntryValue( itemB ) );
}

void SwapObjects( asset Asset, string prefix, int indexA, int indexB )
{
	string itemA = GetItemForIndex( prefix, indexA );
	string itemB = GetItemForIndex( prefix, indexB );

	string valueB = Asset.GetEntryValue( itemB );
	Asset.GetEntryVariable( itemB ).SetValue( Asset.GetEntryValue( itemA ) );
	Asset.GetEntryVariable( itemA ).SetValue( valueB );
}

void AddItem( asset Asset, const string& params )
{
	array<string> paramList = params.Split( "," );
	string prefix = paramList[0];
	int n_index = paramList[1].ToInt();
	
	string item = GetItemForIndex( prefix, n_index );
	Asset.GetEntryVariable( item ).SetValue( "" );
	Asset.GetEntryVariable( GetItemCountItem( prefix ) ).SetInt( n_index );
}

void MoveItemUp( asset Asset, const string& params )
{
	array<string> paramList = params.Split( "," );
	string prefix = paramList[0];
	int n_index = paramList[1].ToInt();
	
	if ( n_index > 0 )
	{
		SwapObjects( Asset, prefix, n_index, n_index - 1 );
	}
}

void MoveItemDown( asset Asset, const string& params )
{
	array<string> paramList = params.Split( "," );
	string prefix = paramList[0];
	int n_index = paramList[1].ToInt();
	int maxEntries = paramList[2].ToInt();
	
	if ( n_index <= maxEntries )
	{
		SwapObjects( Asset, prefix, n_index, n_index + 1 );
	}
}

void DeleteItem( asset Asset, const string& params )
{
	array<string> paramList = params.Split( "," );
	string displayPrefix = paramList[0];
	string prefix = paramList[1];
	int n_index = paramList[2].ToInt();
	int maxEntries = paramList[3].ToInt();
	
	string objectName = GetItemName( displayPrefix, n_index );
	
	if ( MessageBox( "Are you sure you want to remove " + objectName + "?", "YESNO" ) == "YES" )
	{
		for ( int i = n_index; i <= maxEntries; i++ )
		{			
			CopyObject( Asset, prefix, i, i + 1 );
			
			if ( !ItemHasValue( Asset, prefix, i ) )
			{
				Asset.GetEntryVariable( GetItemCountItem( prefix ) ).SetInt( i-1 );
				break;
			}
		}
	}
}

void InsertItem( asset Asset, const string& params )
{
	array<string> paramList = params.Split( "," );
	string prefix = paramList[0];
	int n_index = paramList[1].ToInt();
	
	int count = GetCount( Asset, prefix ) + 1;
	Asset.GetEntryVariable( GetItemCountItem( prefix ) ).SetInt( count );

	for ( int i = count; i >= n_index; i-- )
	{
		CopyObject( Asset, prefix, i + 1, i );
	}

	string item = GetItemForIndex( prefix, n_index );
	Asset.GetEntryVariable( item ).SetValue( "" );
}

void GenerateListItem( asset Asset, string assetType, string displayPrefix, string prefix, int index, int maxEntries, string category )
{
	string item = GetItemForIndex( prefix, index );
	string objectName = GetItemName( displayPrefix, index );
	bool firstObject = ( index == 1 );
	bool isHiddenObject = ( index > maxEntries );
	
	bool isValid = IsItemValid( Asset, prefix, index );
	bool isPreviousValid = IsItemValid( Asset, prefix, index - 1 );

	int count = GetCount( Asset, prefix );
	
	if ( category == "" )
	{
		Asset.BeginCategory( objectName );
	}
	else
	{
		Asset.BeginCategory( category + "." + objectName );
	}
	{		
		if ( !isHiddenObject && ( firstObject || isValid || isPreviousValid ) )
		{
			// Add Button Group
			Asset.AddEntry_ButtonGroup( prefix + "buttonGroup" + index ).SetTitle( "Edit" ).SetSave( false );
			
			if ( isValid )
			{
				if( count < maxEntries )
				{
					Asset.GetEntryControl( prefix + "buttonGroup" + index ).AddButton( "Insert Before", "", "void InsertItem( asset Asset, const string& params )", prefix + "," + index );
				}

				if ( !firstObject )	// Move Up
				{
					Asset.GetEntryControl( prefix + "buttonGroup" + index ).AddButton( "Move Up", "", "void MoveItemUp( asset Asset, const string& params )", prefix + "," + index );
				}
				
				if ( IsItemValid( Asset, prefix, index + 1 ) )	// Move Down
				{
					Asset.GetEntryControl( prefix + "buttonGroup" + index ).AddButton( "Move Down", "", "void MoveItemDown( asset Asset, const string& params )", prefix + "," + index + "," + maxEntries );
				}

				// Delete Object
				Asset.GetEntryControl( prefix + "buttonGroup" + index ).AddButton( "Delete", "", "void DeleteItem( asset Asset, const string& params )", displayPrefix + "," + prefix + "," + index + "," + maxEntries );
			}
			else if ( firstObject || isPreviousValid )
			{
				Asset.GetEntryControl( prefix + "buttonGroup" + index ).AddButton( "Add Item", "", "void AddItem( asset Asset, const string& params )", prefix + "," + index );
			}
		}
		
		Asset.AddEntry_AssetCombo( item, assetType ).SetTitle( objectName ).Show( isValid ).SetToolTip( "The " + assetType + " asset." );
	}
}

void GenerateItemList( asset Asset, string assetType, string displayPrefix, string prefix, int maxEntries, string category = "" )
{
	if ( category != "" )
	{
		Asset.BeginCategory( category );
	}
	{
		Asset.AddEntry_Int( GetItemCountItem( prefix ), 0, 0, maxEntries ).SetTitle( displayPrefix + " Count" ).Show( false ).SetToolTip( "Hidden value containing the list count." ).UpdateOnChange(true);
		
		for ( int i = 1; i <= maxEntries; ++i )
		{
			GenerateListItem( Asset, assetType, displayPrefix, prefix, i, maxEntries, category );
		}
	}
}