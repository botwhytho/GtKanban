Class {
	#name : #LeSlideshowPageSlideListDetailElement,
	#superclass : #LeSlideshowPageSlideElement,
	#category : #'GtKanban-UI'
}

{ #category : #initialization }
LeSlideshowPageSlideListDetailElement >> initialize [
	super initialize.
	self
		matchParent;
		constraintsDo: [ :c | c linear weight: 4 ];
		when: BlElementExtentChangedEvent
			do: [ :anEvent | 
				| snippetElement |
				anEvent consumed: true.
				anEvent logToNamed: 'Testing'.
				snippetElement := anEvent currentTarget children first.
				snippetElement
					updateCoderHeightTo: snippetElement parent extent y * 0.25;
					updateElementHeightTo: snippetElement parent extent y * 0.70	"parent"	"parent" ].
	self snippet page announcer weak
		when: LeContentCommandExecutedAnnouncement
		do: [ :anAnnouncement | 
			((anAnnouncement command isKindOf: LeContentRemoveChildSnippetCommand)
				and: [ (anAnnouncement command childSnippet isKindOf: LeElementSnippet)
						and: [ anAnnouncement command childSnippet = self snippet ] ])
				ifTrue: [ self removeFromParent ] ].
	(self query // #'source-coder--editor') result first
							requestFocus
]
