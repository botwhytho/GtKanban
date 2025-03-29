Extension { #name : #GtWorldSpotterSearchStart }

{ #category : #'*GtKanban' }
GtWorldSpotterSearchStart >> gtCreateNewCustomPageFor: aSearch [
	<gtSearch>
	^ aSearch list
		priority: 1;
		items: [ LeNamedPageType allSubclasses sorted: #name ascending ];
		title: 'Create a New Custom Page Named:';
		filter: GtSpotterReturnAllItemsFilter new;
		itemName: #niceClassName;
		previewElement: [ :aStencil | BlElement new ];
		sendTool: [ :aCategoryToSend :aRawCategory :aStep :aSpotterSearch | 
			| database newPage |
			self flag: #TODO.	"Account for existing page with title"
			database := LeDatabasesRegistry defaultPrimaryDatabase.
			newPage := LePage new.
			newPage type: (aCategoryToSend new page: newPage).
			newPage type title: aStep searchQuery.
			database addPage: newPage.
			newPage gtDefaultInspectorTool ];
		withoutItemAction;
		wantsToDisplayOnEmptyQuery: true
]
