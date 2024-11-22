Class {
	#name : #GtKanbanReorderingHandler,
	#superclass : #DTMultiPaneReorderingHandler,
	#category : #GtKanban
}

{ #category : #'as yet unclassified' }
GtKanbanReorderingHandler >> dragEndEvent: anEvent [
	| draggable |
	draggable := anEvent currentTarget.
	super dragEndEvent: anEvent.
	draggable constraintsDo: [ :c | c horizontal matchParent ].
	draggable inform: (draggable parent childIndexOf: draggable) asString.
	draggable inform: (draggable parent userData at: #snippet) string
	"TODO move snippet in backing Lepiter page."
]

{ #category : #'as yet unclassified' }
GtKanbanReorderingHandler >> dragStartEvent: anEvent [
	anEvent currentTarget width: anEvent currentTarget width.
	super dragStartEvent: anEvent
]
