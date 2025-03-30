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

{ #category : #'as yet unclassified' }
LeKanbanBoardPageType >> addHistorySnippet [
	| jsonSnippet |
	self page children ifEmpty: [ self page addSnippet: LeTextSnippet new ].
	(self page children select: [ :each | each isKindOf: LeStringSnippet ])
		ifEmpty: [ jsonSnippet := LeStringSnippet new
					contentString: '[]';
					bindingName: 'boardHistory';
					format: JSONParser name.
			self page addSnippet: jsonSnippet ]
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
LeKanbanBoardPageType >> createLists: aBoard [
	| lists handler listElements |
	aBoard removeChildren.
	lists := self page children
			select: [ :each | (each parent isKindOf: LePage) and: [ each isTextSnippet ] ].
	handler := GtKanbanMultiPaneReorderingHandler new container: aBoard.
	listElements := lists
			collect: [ :list | 
				| element |
				element := self kanbanListElementFromSnippet: list withHandler: handler.
				element children second userData at: #snippet put: list.
				element ].
	handler panes: (listElements collect: [ :each | each children second ]).
	aBoard addChildren: listElements.
	listElements
		do: [ :list | 
			(list children second userData at: #snippet) children
				do: [ :aSnippet | 
					self
						kanbanCardElementFromSnippet: aSnippet
						inList: list
						withHandler: handler ] ]
]

{ #category : #views }
LeKanbanBoardPageType >> gtKanbanBoardHistoryFor: aView [
	<gtView>
	| boardHistory jsonSnippet |
	self flag: #TODO. "Update view when actions added or on added to scene graph"
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

	self flag: #TODO.	"This doesn't need to be a view eventually if not going to appear on inspector. May want to keep it though"
	^ aView explicit
		title: 'Kanban';
		priority: 45;
		stencil: [ | board |
			self addHistorySnippet.
			board := BrFrame new
					matchParent;
					background: Color lightGray muchLighter;
					padding: (BlInsets all: 2);
					layout: BlLinearLayout horizontal;
					when: BlElementAddedToSceneGraphEvent
						do: [ :anEvent | 
							anEvent consumed: true.
							self onAddedToSceneGraphEvent: anEvent ].
			self createLists: board.
			board ]
]

{ #category : #'as yet unclassified' }
LeKanbanBoardPageType >> kanbanCardElementFromSnippet: aSnippet inList: aList withHandler: aHandler [
	| card |
	card := BrHorizontalPane new
			alignCenter;
			clipChildren: false;
			constraintsDo: [ :c | 
				c vertical exact: 60.
				c horizontal matchParent ];
			border: (BlBorder paint: Color black);
			background: Color white.
	card
		margin: (BlInsets all: 2);
		addChildren: {BrEditableLabel new
					aptitude: BrGlamorousEditableLabelAptitude new glamorousRegularFontAndSize;
					padding: (BlInsets all: 2);
					text: aSnippet string asRopedText;
					when: BrEditorAcceptWish
						do: [ :aWish | 
							aWish text asString = aSnippet string
								ifFalse: [ | history jsonSnippet map newJSON |
									map := {#action -> 'Card Modified'.
											#time -> DateAndTime now printToSeconds.
											#card -> aSnippet uidString.
											#list -> aSnippet parent uidString.
											#oldValue -> aSnippet string.
											#newValue -> aWish text asString} asDictionary.

									jsonSnippet := self page children
											detect: [ :each | each isKindOf: LeStringSnippet ].
									history := (STONJSON fromString: jsonSnippet contentString)
											asOrderedCollection.
									history add: map.
									newJSON := STONJSON toStringPretty: history asArray.
									jsonSnippet contentString: newJSON.
									jsonSnippet updateEditTimeAndEmail.
									jsonSnippet announceTextChangedBy: jsonSnippet parent.

									aSnippet updateText: aWish text asString asRopedText ] ].
				GtInspectorRoundButtonStencil small asElement
					icon: (BrPlusIconStencil close radius: 3) asElement;
					zIndex: 1000;
					margin: (BlInsets all: 10);
					constraintsDo: [ :c | 
						c ignoreByLayout.
						c ignored horizontal alignCenterAt: 1.0.
						c ignored vertical alignCenterAt: 0.0 ];
					label: 'Delete card';
					action: [ :aButton :aBrButtonModel :aBlClickEvent | 
						| history jsonSnippet map newJSON |
						map := {#action -> 'Card Deleted'.
								#time -> DateAndTime now printToSeconds.
								#card -> aSnippet uidString.
								#cardHeading -> aSnippet string.
								#list -> aSnippet parent uidString} asDictionary.

						jsonSnippet := self page children
								detect: [ :each | each isKindOf: LeStringSnippet ].
						history := (STONJSON fromString: jsonSnippet contentString)
								asOrderedCollection.
						history add: map.
						newJSON := STONJSON toStringPretty: history asArray.
						jsonSnippet contentString: newJSON.
						jsonSnippet updateEditTimeAndEmail.
						jsonSnippet announceTextChangedBy: jsonSnippet parent.

						aSnippet removeSelf.
						card removeFromParent ]};
		addEventHandler: aHandler.
	card userData at: #snippet put: aSnippet.
	aList children second addChild: card
]

{ #category : #'as yet unclassified' }
LeKanbanBoardPageType >> kanbanListElementFromSnippet: aListSnippet withHandler: aHandler [
	| listElement |
	listElement := BrVerticalPane new
			hMatchParent;
			vFitContent.	";
						asScrollableElement"
	^ listElement
		addChildren: {BrHorizontalPane new alignCenter
					clipChildren: false;
					constraintsDo: [ :c | 
						c vertical fitContent.
						c horizontal matchParent ];
					background: Color white;
					border: (BlBorder paint: Color lightGray lighter);
					margin: (BlInsets all: 2);
					addChildren: {BrEditableLabel new
								aptitude: BrGlamorousEditableLabelAptitude new glamorousRegularFontAndSize;
								margin: (BlInsets all: 5);
								text: aListSnippet string asRopedText;
								when: BrEditorAcceptWish
									do: [ :aWish | 
										aWish text asString = aListSnippet string
											ifFalse: [ | history jsonSnippet map newJSON |
												map := {#action -> 'List Modified'.
														#time -> DateAndTime now printToSeconds.
														#card -> aListSnippet uidString.
														#list -> aListSnippet uidString.
														#oldValue -> aListSnippet string.
														#newValue -> aWish text asString} asDictionary.

												jsonSnippet := self page children
														detect: [ :each | each isKindOf: LeStringSnippet ].
												history := (STONJSON fromString: jsonSnippet contentString)
														asOrderedCollection.
												history add: map.
												newJSON := STONJSON toStringPretty: history asArray.
												jsonSnippet contentString: newJSON.
												jsonSnippet updateEditTimeAndEmail.
												jsonSnippet announceTextChangedBy: jsonSnippet parent.

												aListSnippet updateText: aWish text asString asRopedText.
												aListSnippet nextSibling isTextSnippet
													ifFalse: [ aListSnippet addSnippetAfterSelf: LeTextSnippet new.
														self createLists: listElement parent ] ] ].
							GtInspectorRoundButtonStencil small asElement
								icon: (BrPlusIconStencil close radius: 3) asElement;
								zIndex: 1000;
								margin: (BlInsets all: 10);
								constraintsDo: [ :c | 
									c ignoreByLayout.
									c ignored horizontal alignCenterAt: 1.0.
									c ignored vertical alignCenterAt: 0.0 ];
								label: 'Delete list';
								action: [ :aButton :aBrButtonModel :aBlClickEvent | 
									aListSnippet removeSelf.
									listElement removeFromParent ];
								in: [ :aCloseButton | 
									aListSnippet string ifEmpty: [ aCloseButton visibility: BlVisibility hidden ].
									aCloseButton ]}.
				BlElement new
					id: #kanbanList;
					clipChildren: false;
					border: (BlBorder paint: Color lightGray lighter);
					background: Color white;
					layout: BlLinearLayout vertical;
					margin: (BlInsets all: 2);
					padding: (BlInsets
							top: 0
							right: 2
							bottom: 20
							left: 2);
					constraintsDo: [ :c | 
						c horizontal matchParent.
						c vertical fitContent ];
					addChild: (GtInspectorRoundButtonStencil small asElement
							icon: (BrPlusIconStencil add radius: 3) asElement;
							zIndex: 1000;
							margin: (BlInsets all: 10);
							constraintsDo: [ :c | 
								c ignoreByLayout.
								c ignored horizontal alignCenterAt: 0.5.
								c ignored vertical alignCenterAt: 1 ];
							label: 'Add Card';
							action: [ :aButton :aBrButtonModel :aBlClickEvent | 
								| history jsonSnippet map newCardSnippet newJSON |
								newCardSnippet := LeTextSnippet string: 'New Task'.
								aListSnippet children isEmpty
									ifTrue: [ aListSnippet addFirstSnippet: newCardSnippet ]
									ifFalse: [ aListSnippet addSnippet: newCardSnippet after: aListSnippet children last ].
								self
									kanbanCardElementFromSnippet: newCardSnippet
									inList: listElement
									withHandler: aHandler.
								map := {#action -> 'Card Added'.
										#time -> DateAndTime now printToSeconds.
										#card -> newCardSnippet uidString.
										#list -> aListSnippet uidString} asDictionary.

								jsonSnippet := self page children
										detect: [ :each | each isKindOf: LeStringSnippet ].
								history := (STONJSON fromString: jsonSnippet contentString)
										asOrderedCollection.
								history add: map.
								newJSON := STONJSON toStringPretty: history asArray.
								jsonSnippet contentString: newJSON.
								jsonSnippet updateEditTimeAndEmail.
								jsonSnippet announceTextChangedBy: jsonSnippet parent ];
							in: [ :anElement | 
								aListSnippet string ifEmpty: [ anElement visibility: BlVisibility hidden ].
								anElement ])}
]

{ #category : #'event handling' }
LeKanbanBoardPageType >> onAddedToSceneGraphEvent: anEvent [
	self createLists: anEvent currentTarget
]

{ #category : #printing }
LeKanbanBoardPageType >> printOn: aStream [

	aStream 
		nextPutAll: 'Kanban Board Page: ';
		print: title
]
