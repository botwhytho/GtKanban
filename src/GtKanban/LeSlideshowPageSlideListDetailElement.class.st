Class {
	#name : #LeSlideshowPageSlideListDetailElement,
	#superclass : #LeSlideshowPageSlideElement,
	#category : #'GtKanban-UI'
}

{ #category : #initialization }
LeSlideshowPageSlideListDetailElement >> initialize [
	super initialize.
	self
		when: BlElementExtentChangedEvent
		do: [ :anEvent | 
			| snippetElement |
			anEvent consumed: true.
			anEvent logToNamed: 'Testing'.
			snippetElement := anEvent currentTarget children first.
			snippetElement
				updateCoderHeightTo: snippetElement parent "parent" extent y * 0.25;
				updateElementHeightTo: snippetElement parent "parent" extent y * 0.70 ]
]
