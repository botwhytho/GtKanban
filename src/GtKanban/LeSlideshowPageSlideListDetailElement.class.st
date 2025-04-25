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
				snippetElement := anEvent currentTarget children first children first.
				snippetElement
					updateCoderHeightTo: snippetElement parent parent extent y * 0.25;
					updateElementHeightTo: snippetElement parent parent extent y * 0.70 ].
	(self query // #'source-coder--editor') result first requestFocus
]
