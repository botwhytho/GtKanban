Extension { #name : #GtWorldSpotterSearchStart }

{ #category : #'*GtKanban' }
GtWorldSpotterSearchStart >> gtCreateNewCustomPageFor: aSearch [
	<gtSearch>
	^ aSearch list
		priority: 24;
		items: [ (LeNamedPageType withAllSubclasses
				remove: LeUnknownNamedPageType;
				yourself) sorted: #name ascending ];
		title: 'Create a New Custom Page Named:';
		flag: #TODO; "Below class is defined in another package, would need to re-create/move to upstream PR"
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

{ #category : #'*GtKanban' }
GtWorldSpotterSearchStart >> gtSearchPagesByTitleFor: aSearch [
	<gtSearch>
	self hasKnowledgeBase ifFalse: [ ^ aSearch empty ].
	self hasChildren ifFalse: [ ^ aSearch empty ].

	^ aSearch explicit
		title: 'Named pages';
		priority: 22;
		search: [ :aContext | self knowledgeBase asyncPagesForWord: aContext searchQuery ];
		previewElement: [:each| each type defaultPhlowTool asElement ];
		itemName: #title;
		wantsToDisplayOnEmptyQuery: false
]

{ #category : #'*GtKanban' }
GtWorldSpotterSearchStart >> gtSpotterContainingSubPartsFor: aSearch [
	<gtSearch>
	self hasKnowledgeBase
		ifFalse: [ ^ aSearch empty ].
	self hasChildren
		ifFalse: [ ^ aSearch empty ].
	
	^ aSearch explicit
		priority: 23;
		title: 'Page contents';
		search: [ :aContext |
			[
			| filter results |
			results := OrderedCollection new.
			filter := LeSubstringFilter new
				caseSensitive: false;
				query: aContext searchQuery.
			self knowledgeBase pagesWithNameDo: [ :eachPage |
				(filter isMatchedItem: eachPage)
					ifTrue: [ results add: eachPage ] ].
			self knowledgeBase unnamedPagesDo: [ :eachPage |
				(filter isMatchedItem: eachPage)
					ifTrue: [ results add: eachPage ] ].
			results asAsyncStream
			] asAsyncFuture asAsyncStream flatten
		];
		previewElement: [:each| each type defaultPhlowTool asElement ];
		itemName: #spotterItemName
]
