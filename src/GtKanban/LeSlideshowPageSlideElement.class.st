Class {
	#name : #LeSlideshowPageSlideElement,
	#superclass : #BrFrame,
	#instVars : [
		'snippet'
	],
	#category : #'GtKanban-UI'
}

{ #category : #initialization }
LeSlideshowPageSlideElement class >> forSnippet: aLeElementSnippet [
	^ self basicNew
		snippet: aLeElementSnippet;
		initialize
]

{ #category : #initialization }
LeSlideshowPageSlideElement >> initialize [
	super initialize.
	self
		addChild: (self snippet
				elementHeight: 200;
				codeHeight: 200;
				asSlideshowPageElement)
]

{ #category : #ui }
LeSlideshowPageSlideElement >> onSnippetRemoved: aGrid [
	self flag: #TODO.	"Probably better to use LeContentTreeRemoved"
	self snippet page announcer weak
		when: LeContentCommandExecutedAnnouncement
		do: [ :anAnnouncement | 
			((anAnnouncement command isKindOf: LeContentRemoveChildSnippetCommand)
				and: [ anAnnouncement command childSnippet isKindOf: LeElementSnippet ])
				ifTrue: [ (aGrid query // LeSlideshowPageSlideElement) result
						detect: [ :each | each snippet = anAnnouncement command childSnippet ]
						ifFound: [ :found | aGrid removeChild: found parent ] ] ]
]

{ #category : #accessing }
LeSlideshowPageSlideElement >> snippet [
	^ snippet
]

{ #category : #accessing }
LeSlideshowPageSlideElement >> snippet: aLeElementSnippet [
	snippet := aLeElementSnippet
]
