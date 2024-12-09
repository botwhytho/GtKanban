Class {
	#name : #GtKanbanReorderingHandler,
	#superclass : #DTMultiPaneReorderingHandler,
	#category : #GtKanban
}

{ #category : #'as yet unclassified' }
GtKanbanReorderingHandler >> dragEndEvent: anEvent [
	| card draggable history jsonSnippet map newJSON list newListPosition |
	draggable := anEvent currentTarget.
	super dragEndEvent: anEvent.
	draggable constraintsDo: [ :c | c horizontal matchParent ].
	card := draggable userData at: #snippet.
	list := draggable parent userData at: #snippet.
	"Index math is needed here to take into account the new card button which is a child of the list element"
	newListPosition := (draggable parent childIndexOf: draggable) - 1.
	map := {#action -> 'Move'.
			#time -> DateAndTime now asStringYMDHM.
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

{ #category : #'as yet unclassified' }
GtKanbanReorderingHandler >> dragStartEvent: anEvent [
	| card draggable history map newJSON jsonSnippet list position |
	draggable := anEvent currentTarget.
	card := draggable userData at: #snippet.
	list := draggable parent userData at: #snippet.
	"Index math is needed here to take into account the new card button which is a child of the list element"
	position := (draggable parent childIndexOf: draggable) - 1.
	map := { #action -> 'Move'.
	#time -> DateAndTime now asStringYMDHM.
	#direction -> 'From'.
	#card -> card uidString.
	#list -> list uidString.
	#position -> position
	} asDictionary.
	jsonSnippet := list page children detect: [:each| each isKindOf: LeStringSnippet ].
	history := (STONJSON fromString: jsonSnippet contentString) asOrderedCollection.
	history add: map.
	newJSON := (STONJSON toStringPretty: history asArray).
	jsonSnippet contentString: newJSON.
	jsonSnippet updateEditTimeAndEmail.
	jsonSnippet announceTextChangedBy: jsonSnippet parent.
	anEvent currentTarget width: anEvent currentTarget width.
	super dragStartEvent: anEvent
]
