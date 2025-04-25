Class {
	#name : #LeSlideshowPageSlideElement,
	#superclass : #BrFrame,
	#instVars : [
		'snippet',
		'versionNumber'
	],
	#category : #'GtKanban-UI'
}

{ #category : #initialization }
LeSlideshowPageSlideElement class >> forSnippet: aLeElementSnippet [
	^ self basicNew
		snippet: aLeElementSnippet;
		initialize
]

{ #category : #accessing }
LeSlideshowPageSlideElement >> bumpVersionNumber [
	self versionNumber: self versionNumber + 1
]

{ #category : #initialization }
LeSlideshowPageSlideElement >> initialize [
	super initialize.
	self addChild: self snippetAsElement.
	self flag: #NOTE.	"Potential infinite loop below, how to prevent?"
	self snippet weak
		when: LeUIPageChildEvaluationAnnouncement
		do: [ :anEvent | 
			anEvent evaluatedBlockElement = self
				ifFalse: [ (self query // LeElementSnippetElement) result first generateDisplayElement ] ].
	self
		when: LeSnippetEvaluated
		do: [ :anEvent | 
			| myselfAndSiblingElements |
			anEvent consumed: true.

			myselfAndSiblingElements := self snippet announcer subscriptions
					subscriptions asArray
					select: [ :each | 
						(each subscriber isKindOf: LeSlideshowPageSlideElement)
							and: [ (each subscriber
									allParentsDetect: [ :anElement | anElement isKindOf: LeSlideshowPageElement ]
									ifFound: #yourself
									ifNone: [ nil ])
									= (self
											allParentsDetect: [ :anElement | anElement isKindOf: LeSlideshowPageElement ]
											ifFound: #yourself
											ifNone: [ nil ]) ] ]
					thenCollect: #subscriber.
			self versionNumber = (myselfAndSiblingElements max: #versionNumber)
				ifTrue: [ self bumpVersionNumber.
					self snippet notifier tree
						announce: (LeUIPageChildEvaluationAnnouncement new
								evaluatedBlock: anEvent snippet;
								evaluatedBlockElement: anEvent element;
								topParentElement: self;
								evaluationResult: anEvent evaluationResult) ]
				ifFalse: [ self bumpVersionNumber ] ]
]

{ #category : #accessing }
LeSlideshowPageSlideElement >> parentTool [
	^ self
		allParentsDetect: [ :each | each isKindOf: LeSlideshowPageElement ]
		ifFound: #yourself
		ifNone: [ nil ]
]

{ #category : #accessing }
LeSlideshowPageSlideElement >> snippet [
	^ snippet
]

{ #category : #accessing }
LeSlideshowPageSlideElement >> snippet: aLeElementSnippet [
	snippet := aLeElementSnippet
]

{ #category : #initialization }
LeSlideshowPageSlideElement >> snippetAsElement [
	^ self snippet
		elementHeight: 200;
		codeHeight: 200;
		asSlideshowPageElement
]

{ #category : #accessing }
LeSlideshowPageSlideElement >> versionNumber [
	^ versionNumber ifNil: [ versionNumber := 1 ]
]

{ #category : #accessing }
LeSlideshowPageSlideElement >> versionNumber: anObject [
	versionNumber := anObject
]
