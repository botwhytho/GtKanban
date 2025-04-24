Class {
	#name : #LeSlideshowPageSlideListElement,
	#superclass : #LeSlideshowPageSlideElement,
	#category : #'GtKanban-UI'
}

{ #category : #initialization }
LeSlideshowPageSlideListElement >> initialize [
	super initialize.
	self
		matchParent;
		preventChildrenMouseEvents;
		addAptitude: BrShadowAptitude new
				+ (BrGlamorousSlideExteriorAptitude new
						backgroundPaint: Color white;
						borderPaint: Color transparent);
		when: BlClickEvent
			do: [ :anEvent | 
				| parentContainer |
				anEvent consumed: true.
				self allowChildrenMouseEvents.
				parentContainer := anEvent currentTarget
						allParentsDetect: [ :anElement | anElement id asSymbol = #slidesDetailTool ]
						ifFound: [ :found | found children second ]
						ifNone: [ nil ].

				parentContainer children
					ifEmpty: [ parentContainer
							addChild: (LeSlideshowPageSlideListDetailElement forSnippet: self snippet) ]
					ifNotEmpty: [ parentContainer
							replaceChild: parentContainer children first
							with: (LeSlideshowPageSlideListDetailElement forSnippet: self snippet) ] ];
		when: BlMouseLeaveEvent
			do: [ :anEvent | 
				anEvent consumed: true.
				self hasFocus ifTrue: [ self loseFocus ].
				self preventChildrenMouseEvents ].
	(self query // LeElementSnippetElement) result first hideCoder
]
