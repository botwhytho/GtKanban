Class {
	#name : #LeKanbanBoardPageType,
	#superclass : #LeNamedPageType,
	#category : #GtKanban
}

{ #category : #initialization }
LeKanbanBoardPageType class >> initialize [
	self flag: #TODO.	"Remove noce upstream is merged on superclass"
	super initialize.
	self leJsonV4MappingFor: LeJsonV4 uniqueInstance newWriter.
	LeDatabasesRegistry defaultLogicalDatabase databases
		do: [ :aDatabase | aDatabase pagesByType at: self ifAbsentPut: [ GtStringContentDictionary new ] ]
]

{ #category : #accesing }
LeKanbanBoardPageType class >> leJsonV3Name [

	^ 'kanbanBoardPage'
]

{ #category : #accesing }
LeKanbanBoardPageType class >> leJsonV4Name [

	^ 'kanbanBoardPage'
]

{ #category : #printing }
LeKanbanBoardPageType class >> niceClassName [
	^ 'Kanban Board Page'
]

{ #category : #converting }
LeKanbanBoardPageType >> asLepiterPagePhlowTool [
	^ GtPhlowCompositeTool new
		name: self page title;
		addTool: (GtPhlowExplicitTool new withLabelAptitude
				name: 'Kanban';
				stencil: [ BrFrame new
						matchParent;
						margin: (BlInsets all: 20);
						addChild: (self gtKanbanFor: GtPhlowView empty) asElement ]);
		addTool: (GtPhlowExplicitTool new withLabelAptitude
				name: 'Views';
				stencil: [ (GtPhlowTool default object: self) asElement ]);
		addTool: (GtPhlowTool default object: self page)
]

{ #category : #views }
LeKanbanBoardPageType >> gtKanbanBoardHistoryFor: aView [
	<gtView>
	| boardHistory jsonSnippet |
	((self page children
		detect: [ :each | each isKindOf: LeStringSnippet ]
		ifFound: [ :found | 
			jsonSnippet := found.
			true ]
		ifNone: [ false ]) and: [ jsonSnippet bindingName = 'boardHistory' ])
		ifFalse: [ ^ aView empty ].
	boardHistory := (((STONJSON fromString: jsonSnippet contentString)
			groupedBy: [ :each | each at: 'card' ])
			collect: [ :each | each sorted: [ :inner | DateAndTime fromString: (inner at: 'time') ] ascending ])
			associations.
	^ aView columnedTree
		title: 'Kanban Board History';
		priority: 46;
		items: boardHistory;
		children: [ :each | each value isArray ifTrue: [ each value ] ifFalse: [ #() ] ];
		column: 'Actions'
			text: [ :each | 
				each isAssociation
					ifTrue: [ self page database
							blockWithUID: (LeUID new uidString: each key)
							ifPresent: [ :present | 
								present string
									in: [ :aString | 
										(present parent isKindOf: LePage)
											ifTrue: [ aString , ' (list)' ]
											ifFalse: [ aString ] ] ]
							ifAbsent: [ each value
									detect: [ :inner | (inner at: 'action') = 'Card Deleted' ]
									ifFound: [ :found | found at: 'cardHeading' ]
									ifNone: [ 'Card Deleted' ] ] ]
					ifFalse: [ each at: 'action' ] ];
		column: 'Time'
			text: [ :each | each isAssociation ifTrue: [ '' ] ifFalse: [ each at: 'time' ] ];
		expandAll
]

{ #category : #views }
LeKanbanBoardPageType >> gtKanbanFor: aView [
	"<gtView>"

	| listElements |
	self flag: #TODO.	"This doesn't need to be a view eventually if not going to appear on inspector. May want to keep it though"
	^ aView explicit
		title: 'Kanban';
		priority: 45;
		stencil: [ | board lists handler |
			self page addHistorySnippet.
			board := BrFrame new
					matchParent;
					background: Color lightGray muchLighter;
					padding: (BlInsets all: 2);
					layout: BlLinearLayout horizontal.

			lists := self page children
					select: [ :each | (each parent isKindOf: LePage) and: [ each isTextSnippet ] ].
			handler := GtKanbanMultiPaneReorderingHandler new container: board.
			listElements := lists
					collect: [ :list | 
						| element |
						element := self page
								kanbanListElementFromSnippet: list
								withHandler: handler.
						element children second userData at: #snippet put: list.
						element ].
			handler panes: (listElements collect: [ :each | each children second ]).
			board addChildren: listElements.
			listElements
				do: [ :list | 
					(list children second userData at: #snippet) children
						do: [ :aSnippet | 
							self page
								kanbanCardElementFromSnippet: aSnippet
								inList: list
								withHandler: handler ] ].
			board ]
]

{ #category : #printing }
LeKanbanBoardPageType >> printOn: aStream [

	aStream 
		nextPutAll: 'Kanban Board Page: ';
		print: title
]
