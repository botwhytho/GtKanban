Class {
	#name : #BlSlideReorderingHandler,
	#superclass : #BlReorderingHandler,
	#instVars : [
		'page'
	],
	#category : #'GtKanban-Drag & Drop'
}

{ #category : #'as yet unclassified' }
BlSlideReorderingHandler >> initialize [
	super initialize.
	dragEndEventAction := [ :aBlDragEndEvent | 
		| newSlideOrder |
		newSlideOrder := (aBlDragEndEvent currentTarget parent query
				// LeElementSnippetElement) result
				collect: [ :each | each snippetViewModel snippetModel ].
		newSlideOrder = self page type elementSnippets
			ifFalse: [ newSlideOrder do: [ :aSnippet | self page children removeSnippet: aSnippet ].
				newSlideOrder do: [ :aSnippet | self page basicAddSnippet: aSnippet ].
				self page announceTreeChanged: self page ] ]
]

{ #category : #accessing }
BlSlideReorderingHandler >> page [
	^ page
]

{ #category : #accessing }
BlSlideReorderingHandler >> page: aLePage [
	page := aLePage
]
