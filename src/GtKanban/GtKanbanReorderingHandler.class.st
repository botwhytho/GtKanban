Class {
	#name : #GtKanbanReorderingHandler,
	#superclass : #DTMultiPaneReorderingHandler,
	#category : #GtKanban
}

{ #category : #'as yet unclassified' }
GtKanbanReorderingHandler >> dragEndEvent: anEvent [
	| card draggable list newListPosition |
	draggable := anEvent currentTarget.
	super dragEndEvent: anEvent.
	draggable constraintsDo: [ :c | c horizontal matchParent ].
	card := draggable userData at: #snippet.
	list := draggable parent userData at: #snippet.
	newListPosition := draggable parent childIndexOf: draggable.

	card parent removeSnippet: card.
	list children isEmpty
		ifTrue: [ list addFirstSnippet: card ]
		ifFalse: [ newListPosition > list children size
				ifTrue: [ list addSnippet: card after: list children last ]
				ifFalse: [ list addSnippet: card beforeIndex: newListPosition ] ].
	"draggable inform: 'Card moved to list ' , (draggable parent userData at: #snippet) string
		, ' in position ' , (draggable parent childIndexOf: draggable) asString."
]

{ #category : #'as yet unclassified' }
GtKanbanReorderingHandler >> dragStartEvent: anEvent [
	| draggable |
	draggable := anEvent currentTarget.
	anEvent currentTarget width: anEvent currentTarget width.
	"draggable inform: 'Card moved from list ' , (draggable parent userData at: #snippet) string
		, ' in position ' , (draggable parent childIndexOf: draggable) asString."
	super dragStartEvent: anEvent
]
