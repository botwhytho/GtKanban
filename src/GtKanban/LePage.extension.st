Extension { #name : #LePage }

{ #category : #'*GtKanban' }
LePage >> asPhlowTool [
	<return: #LePhlowTool>
	^ self type asLepiterPagePhlowTool
]

{ #category : #'*GtKanban' }
LePage >> gtKanbanFor: aView [
	<gtView>
	| listElements |
	^ aView explicit
		title: 'Kanban';
		priority: 100;
		stencil: [ | board columnBlock lists handler |
			board := BrFrame new
					matchParent;
					background: Color lightGray muchLighter;
					padding: (BlInsets all: 2);
					layout: BlLinearLayout horizontal.

			columnBlock := [ :aSnippet | 
				BrVerticalPane new
					matchParent;
					addChildren: {BrHorizontalPane new alignCenter
								constraintsDo: [ :c | 
									c vertical fitContent.
									c horizontal matchParent ];
								background: Color white;
								border: (BlBorder paint: Color lightGray lighter);
								margin: (BlInsets all: 2);
								addChild: (BrEditableLabel new
										aptitude: BrGlamorousEditableLabelAptitude new glamorousRegularFontAndSize;
										padding: (BlInsets all: 2);
										text: aSnippet string asRopedText;
										when: BrEditorAcceptWish
											do: [ :aWish | 
												aWish text asString = aSnippet string
													ifFalse: [ aSnippet string: aWish text asString.
														aSnippet announceContentChanged ] ]).
							BlElement new
								border: (BlBorder paint: Color lightGray lighter);
								background: Color white;
								layout: BlLinearLayout vertical;
								margin: (BlInsets all: 2);
								padding: (BlInsets all: 2);
								constraintsDo: [ :c | 
									c horizontal matchParent.
									c vertical matchParent ]} ].

			lists := self children
					select: [ :each | (each parent isKindOf: LePage) and: [ each isTextSnippet ] ].
			listElements := lists
					collect: [ :list | 
						| element |
						element := columnBlock value: list.
						element children second userData at: #snippet put: list.
						element ].

			handler := GtKanbanReorderingHandler new
					container: board;
					panes: (listElements collect: [ :each | each children second ]);
					yourself.

			board addChildren: listElements.
			listElements
				do: [ :list | 
					| card |
					(list children second userData at: #snippet) children
						do: [ :aSnippet | 
							card := BrHorizontalPane new alignCenter
									constraintsDo: [ :c | 
										c vertical exact: 60.
										c horizontal matchParent ];
									border: (BlBorder paint: Color black);
									background: Color veryLightGray lighter lighter lighter.
							card
								margin: (BlInsets all: 2);
								addChild: (BrEditableLabel new
										aptitude: BrGlamorousEditableLabelAptitude new glamorousRegularFontAndSize;
										padding: (BlInsets all: 2);
										text: aSnippet string asRopedText;
										when: BrEditorAcceptWish
											do: [ :aWish | 
												aWish text asString = aSnippet string
													ifFalse: [ aSnippet string: aWish text asString.
														aSnippet announceContentChanged ] ]);
								addEventHandler: handler.
							card userData at: #snippet put: aSnippet.
							list children second addChild: card ] ].
			board ]
]
