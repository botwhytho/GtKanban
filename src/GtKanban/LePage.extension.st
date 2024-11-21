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

			columnBlock := [ BlElement new
					border: (BlBorder paint: Color lightGray lighter);
					background: Color yellow muchLighter muchLighter lighter;
					layout: BlFlowLayout new;
					margin: (BlInsets all: 2);
					padding: (BlInsets all: 2);
					constraintsDo: [ :c | 
						c horizontal matchParent.
						c vertical matchParent ] ].

			lists := self children
					select: [ :each | (each parent isKindOf: LePage) and: [ each isTextSnippet ] ].
			listElements := lists collect: [ :list | {list . columnBlock value} ].

			handler := DTMultiPaneReorderingHandler new
					container: board;
					panes: (listElements collect: #second);
					yourself.

			board addChildren: (listElements collect: #second).
			listElements
				do: [ :list | 
					| card |
					list first children size
						timesRepeat: [ card := BlElement new
									size: 80 @ 60;
									border: (BlBorder paint: Color black);
									background: Color random;
									margin: (BlInsets all: 2);
									addEventHandler: handler;
									yourself.
							list second addChild: card ] ].
			board ]
]
