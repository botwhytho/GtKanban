Extension { #name : #LePage }

{ #category : #'*GtKanban' }
LePage >> addHistorySnippet [
	| jsonSnippet |
	(self children select: [ :each | each isKindOf: LeStringSnippet ]) ifEmpty: [
	
	jsonSnippet := LeStringSnippet new
			contentString: '[]';
			bindingName: 'boardHistory';
			format: JSONParser name.
	self addSnippet: jsonSnippet
	]
]

{ #category : #'*GtKanban' }
LePage >> asPhlowTool [
	<return: #LePhlowTool>
	^ self type asLepiterPagePhlowTool
]

{ #category : #'*GtKanban' }
LePage >> gtKanbanBoardHistoryFor: aView [
	<gtView>
	| boardHistory jsonSnippet |
	((self children
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
					ifTrue: [ self database
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

{ #category : #'*GtKanban' }
LePage >> gtKanbanFor: aView [
	<gtView>
	| listElements |
	^ aView explicit
		title: 'Kanban';
		priority: 45;
		stencil: [ | board lists handler |
			self addHistorySnippet.
			board := BrFrame new
					matchParent;
					background: Color lightGray muchLighter;
					padding: (BlInsets all: 2);
					layout: BlLinearLayout horizontal.

			lists := self children
					select: [ :each | (each parent isKindOf: LePage) and: [ each isTextSnippet ] ].
			handler := GtKanbanMultiPaneReorderingHandler new container: board.
			listElements := lists
					collect: [ :list | 
						| element |
						element := self kanbanListElementFromSnippet: list withHandler: handler.
						element children second userData at: #snippet put: list.
						element ].
			handler panes: (listElements collect: [ :each | each children second ]).
			board addChildren: listElements.
			listElements
				do: [ :list | 
					(list children second userData at: #snippet) children
						do: [ :aSnippet | 
							self
								kanbanCardElementFromSnippet: aSnippet
								inList: list
								withHandler: handler ] ].
			board ]
]

{ #category : #'*GtKanban' }
LePage >> kanbanCardElementFromSnippet: aSnippet inList: aList withHandler: aHandler [
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

									jsonSnippet := aSnippet page children
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

						jsonSnippet := aSnippet page children
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

{ #category : #'*GtKanban' }
LePage >> kanbanListElementFromSnippet: aListSnippet withHandler: aHandler [
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

												jsonSnippet := aListSnippet page children
														detect: [ :each | each isKindOf: LeStringSnippet ].
												history := (STONJSON fromString: jsonSnippet contentString)
														asOrderedCollection.
												history add: map.
												newJSON := STONJSON toStringPretty: history asArray.
												jsonSnippet contentString: newJSON.
												jsonSnippet updateEditTimeAndEmail.
												jsonSnippet announceTextChangedBy: jsonSnippet parent.

												aListSnippet updateText: aWish text asString asRopedText ] ].
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
									listElement removeFromParent ]}.
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

								jsonSnippet := aListSnippet page children
										detect: [ :each | each isKindOf: LeStringSnippet ].
								history := (STONJSON fromString: jsonSnippet contentString)
										asOrderedCollection.
								history add: map.
								newJSON := STONJSON toStringPretty: history asArray.
								jsonSnippet contentString: newJSON.
								jsonSnippet updateEditTimeAndEmail.
								jsonSnippet announceTextChangedBy: jsonSnippet parent ])}
]
