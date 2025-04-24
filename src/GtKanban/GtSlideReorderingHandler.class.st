Class {
	#name : #GtSlideReorderingHandler,
	#superclass : #BlReorderingHandler,
	#instVars : [
		'page'
	],
	#category : #'GtKanban-Drag & Drop'
}

{ #category : #initialization }
GtSlideReorderingHandler >> initialize [
	super initialize.
	dragEndEventAction := [ :aBlDragEndEvent | 
		| newSlideOrder |
		self flag: #TODO.	"Simplify to use LeSlideshowPageSlideElement"
		newSlideOrder := (aBlDragEndEvent currentTarget parent query
				// LeElementSnippetElement) result
				collect: [ :each | each snippetViewModel snippetModel ].
		newSlideOrder = self page type elementSnippets
			ifFalse: [ newSlideOrder do: [ :aSnippet | self page children removeSnippet: aSnippet ].
				newSlideOrder do: [ :aSnippet | self page basicAddSnippet: aSnippet ].
				self page announceTreeChanged: self page ] ]
]

{ #category : #accessing }
GtSlideReorderingHandler >> page [
	^ page
]

{ #category : #accessing }
GtSlideReorderingHandler >> page: aLePage [
	page := aLePage
]
