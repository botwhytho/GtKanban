Class {
	#name : #GtKanbanMultiPaneReorderingHandler,
	#superclass : #GtKanbanReorderingHandler,
	#instVars : [
		'panes',
		'container'
	],
	#category : #'GtKanban-Drag & Drop'
}

{ #category : #accessing }
GtKanbanMultiPaneReorderingHandler >> addPane: aPane [
	panes add: aPane
]

{ #category : #accessing }
GtKanbanMultiPaneReorderingHandler >> container: theContainer [
	container := theContainer
]

{ #category : #accessing }
GtKanbanMultiPaneReorderingHandler >> dragEndEvent: anEvent [
	"anEvent consumed: true."
	| draggable |
	draggable := anEvent currentTarget.
	overlay removeChild: draggable.
	parent replaceChild: placeholder with: draggable.
	overlay detach.

	anEvent currentTarget dispatchEvent: BlPullEndEvent new.
	self onDragEndEvent: draggable
]

{ #category : #accessing }
GtKanbanMultiPaneReorderingHandler >> dragEvent: anEvent [
	| dragPosition dragDelta aNewPosition |
	dragPosition := anEvent currentTarget
		globalPointToParent: anEvent position.
	self movePlaceholderIfOverOtherChild: anEvent.
	dragDelta := dragPosition
		- (dragStartPosition ifNil: [ dragStartPosition := dragPosition ]).
	dragDelta := self computePullDelta: dragDelta.
	aNewPosition := (originalPosition
		ifNil: [ originalPosition := anEvent currentTarget position ])
		+ dragDelta.
	allowedOutOfBounds
		ifFalse: [ | aMaxPosition |
			aMaxPosition := anEvent currentTarget hasParent
				ifTrue: [ anEvent currentTarget parent extent - anEvent currentTarget extent ]
				ifFalse: [ 0 @ 0 ].
			aNewPosition := aNewPosition min: aMaxPosition max: 0 @ 0 ].
	anEvent currentTarget relocate: aNewPosition.
	anEvent consumed: true.
	anEvent currentTarget
		dispatchEvent:
			(BlPullEvent new
				initialPosition: originalPosition;
				oldPosition: dragPosition;
				newPosition: aNewPosition;
				delta: dragDelta)
]

{ #category : #accessing }
GtKanbanMultiPaneReorderingHandler >> dragStartEvent: anEvent [
	|draggable |
	self onDragStartEvent: anEvent.
	anEvent consumed: true.
	draggable := anEvent currentTarget.
	parent := panes detect: [ :aPane | aPane containsGlobalPoint: anEvent position ].
	overlay := BlOverlayElement on: container.
	container parent addChild: overlay.

	"drag start position in parent"
	dragStartPosition := draggable globalPointToParent: anEvent position.

	"element position in parent"
	originalPosition := draggable position.
	placeholder := self placeholderFor: draggable.
	parent replaceChild: draggable with: placeholder.
	overlay addChild: draggable.

	anEvent currentTarget dispatchEvent: BlPullStartEvent new
]

{ #category : #accessing }
GtKanbanMultiPaneReorderingHandler >> movePlaceholderIfOverOtherChild: anEvent [
	| mouseOverOther |
	self movePlaceholderToCorrectParent: anEvent.
	mouseOverOther := placeholder.
	parent children
		do: [ :each | 
			(each containsGlobalPoint: anEvent position)
				ifTrue: [ mouseOverOther := each ] ].
	mouseOverOther = placeholder
		ifFalse: [ | index |
			index := parent childIndexOf: mouseOverOther.
			parent removeChild: placeholder.
			parent addChild: placeholder at: index ]
]

{ #category : #accessing }
GtKanbanMultiPaneReorderingHandler >> movePlaceholderToCorrectParent: anEvent [
	| currentPane |
	currentPane := panes
		detect: [ :aPane | aPane containsGlobalPoint: anEvent position ]
		ifNone: [ parent ].
	currentPane = parent
		ifFalse: [ parent removeChild: placeholder.
			parent := currentPane.
			parent addChild: placeholder ]
]

{ #category : #accessing }
GtKanbanMultiPaneReorderingHandler >> onDragEndEvent: anEvent [
	| card draggable history jsonSnippet map newJSON list newListPosition |
	draggable := anEvent.
	draggable constraintsDo: [ :c | c horizontal matchParent ].
	card := draggable userData at: #snippet.
	list := draggable parent userData at: #snippet.
	"Index math is needed here to take into account the new card button which is a child of the list element"
	newListPosition := (draggable parent childIndexOf: draggable) - 1.
	map := {#action -> 'Card Moved'.
			#time -> DateAndTime now printToSeconds.
			#direction -> 'To'.
			#card -> card uidString.
			#list -> list uidString.
			#position -> newListPosition} asDictionary.

	jsonSnippet := list page children
			detect: [ :each | each isKindOf: LeStringSnippet ].
	history := (STONJSON fromString: jsonSnippet contentString) asOrderedCollection.
	history add: map.
	newJSON := STONJSON toStringPretty: history asArray.
	jsonSnippet contentString: newJSON.
	jsonSnippet updateEditTimeAndEmail.
	jsonSnippet announceTextChangedBy: jsonSnippet parent.

	card parent removeSnippet: card.
	list children isEmpty
		ifTrue: [ list addFirstSnippet: card ]
		ifFalse: [ newListPosition > list children size
				ifTrue: [ list addSnippet: card after: list children last ]
				ifFalse: [ list addSnippet: card beforeIndex: newListPosition ] ]
]

{ #category : #accessing }
GtKanbanMultiPaneReorderingHandler >> onDragStartEvent: anEvent [
	| card draggable history map newJSON jsonSnippet list position |
	draggable := anEvent currentTarget.
	card := draggable userData at: #snippet.
	list := draggable parent userData at: #snippet.
	"Index math is needed here to take into account the new card button which is a child of the list element"
	position := (draggable parent childIndexOf: draggable) - 1.
	map := {#action -> 'Card Moved'.
			#time -> DateAndTime now printToSeconds.
			#direction -> 'From'.
			#card -> card uidString.
			#list -> list uidString.
			#position -> position} asDictionary.
	jsonSnippet := list page children
			detect: [ :each | each isKindOf: LeStringSnippet ].
	history := (STONJSON fromString: jsonSnippet contentString) asOrderedCollection.
	history add: map.
	newJSON := STONJSON toStringPretty: history asArray.
	jsonSnippet contentString: newJSON.
	jsonSnippet updateEditTimeAndEmail.
	jsonSnippet announceTextChangedBy: jsonSnippet parent.
	anEvent currentTarget width: anEvent currentTarget width
]

{ #category : #accessing }
GtKanbanMultiPaneReorderingHandler >> panes: thePanes [
	panes := thePanes
]

{ #category : #accessing }
GtKanbanMultiPaneReorderingHandler >> removePane: aPane [
	panes remove: aPane
]
