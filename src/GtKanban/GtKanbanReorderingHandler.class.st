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
				ifFalse: [ list addSnippet: card beforeIndex: newListPosition + 1 ] ]
]

{ #category : #'as yet unclassified' }
GtKanbanReorderingHandler >> dragStartEvent: anEvent [
	anEvent currentTarget width: anEvent currentTarget width.
	super dragStartEvent: anEvent
]
