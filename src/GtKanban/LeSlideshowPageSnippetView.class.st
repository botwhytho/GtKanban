Class {
	#name : #LeSlideshowPageSnippetView,
	#superclass : #LeSnippetView,
	#category : #'GtKanban-! Views'
}

{ #category : #'api - instantiation' }
LeSlideshowPageSnippetView >> newSnippetElementLook [
	^ LeSlideshowPageSnippetExpandableAptitude new
]
