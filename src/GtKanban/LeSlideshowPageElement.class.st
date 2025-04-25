Class {
	#name : #LeSlideshowPageElement,
	#superclass : #BrHorizontalPane,
	#instVars : [
		'columnCount',
		'page',
		'slidesGridTool',
		'slidesDetailTool'
	],
	#category : #'GtKanban-UI'
}

{ #category : #initialization }
LeSlideshowPageElement class >> page: aLePage [
	^ self basicNew
		page: aLePage;
		initialize
]

{ #category : #ui }
LeSlideshowPageElement >> changeLayoutButton [
	^ BrButton new
		zIndex: 1000;
		aptitude: BrGlamorousButtonWithIconAptitude;
		margin: (BlInsets all: 25);
		constraintsDo: [ :c | 
			c frame horizontal alignLeft.
			c frame vertical alignTop ];
		label: 'Change Detail Level of Slide Grid';
		icon: BrGlamorousVectorIcons hamburger;
		action: [ :aBrButton :aBrButtonModel :anEvent | 
			| grid |
			anEvent consumed: true.
			grid := (aBrButton parent query // #slidesGrid) result anyOne.
			self columnCount = self summaryColumnCount
				ifTrue: [ grid columnCount: self detailedColumnCount.
					self columnCount: self detailedColumnCount.
					(grid query // LeElementSnippetElement) result
						do: [ :aSnippetElement | aSnippetElement showCoder ].
					self dispatchEvent: GtSlidesGridShowMoreDetailEvent new ]
				ifFalse: [ grid columnCount: self summaryColumnCount.
					self columnCount: self summaryColumnCount.
					(grid query // LeElementSnippetElement) result
						do: [ :aSnippetElement | aSnippetElement hideCoder ].
					self dispatchEvent: GtSlidesGridShowLessDetailEvent new ] ]
]

{ #category : #accessing }
LeSlideshowPageElement >> columnCount [
	^ columnCount
]

{ #category : #accessing }
LeSlideshowPageElement >> columnCount: anInteger [
	columnCount := anInteger
]

{ #category : #ui }
LeSlideshowPageElement >> detailedColumnCount [
	^ 2
]

{ #category : #accessing }
LeSlideshowPageElement >> elementSnippets [
	| result |
	result := OrderedCollection new.
	self page
		withAllChildrenDepthFirstDo: [ :aSnippet | (aSnippet isKindOf: LeElementSnippet) ifTrue: [ result add: aSnippet ] ].

	^ result
]

{ #category : #initialization }
LeSlideshowPageElement >> initialize [
	super initialize.
	self
		id: #slideshowPageTool;
		matchParent;
		addChildren: {slidesDetailTool := self slidesDetailTool.
				slidesGridTool := self slidesGridTool};
		addAptitude: (GtPhlowToolDetailAptitude new
				normal: [ :aStyle | 
					aStyle
						do: [ slidesDetailTool visibility: BlVisibility gone.
							slidesGridTool visibility: BlVisibility visible ] ];
				detailed: [ :aStyle | 
					aStyle
						do: [ slidesDetailTool visibility: BlVisibility visible.
							slidesGridTool visibility: BlVisibility gone ] ])
]

{ #category : #ui }
LeSlideshowPageElement >> onSnippetAdded: aGrid [
	self page announcer weak
		when: LeContentTreeAdded
		do: [ :anAnnouncement | 
			(anAnnouncement content isKindOf: LeElementSnippet)
				ifTrue: [ | indexOfNewSnippet pageSnippets |
					pageSnippets := self page type elementSnippets.
					indexOfNewSnippet := pageSnippets indexOf: anAnnouncement content.
					aGrid
						addChild: (aGrid children first class forSnippet: anAnnouncement content)
						at: indexOfNewSnippet ] ]
]

{ #category : #ui }
LeSlideshowPageElement >> onSnippetRemoved: aGrid [
	self page announcer weak
		when: LeContentTreeRemoved
		do: [ :anAnnouncement | 
			(anAnnouncement content isKindOf: LeElementSnippet)
				ifTrue: [ aGrid children
						detect: [ :each | [ each snippet = anAnnouncement content ] on: MessageNotUnderstood do: [ false ] ]
						ifFound: [ :found | 
							(found isKindOf: LeSlideshowPageSlideListDetailElement)
								ifTrue: [ aGrid replaceChild: found with: self placeholderElement ]
								ifFalse: [ aGrid removeChild: found ] ] ] ]
]

{ #category : #accessing }
LeSlideshowPageElement >> page [
	^ page
]

{ #category : #accessing }
LeSlideshowPageElement >> page: aLePge [
	page := aLePge
]

{ #category : #ui }
LeSlideshowPageElement >> placeholderElement [
	^ BlTextElement
		text: ('Select a slide to work on' asRopedText foreground: Color lightGray)
]

{ #category : #ui }
LeSlideshowPageElement >> playSlideshowButton [
	^ BrButton new
		zIndex: 1000;
		aptitude: BrGlamorousButtonWithIconAptitude;
		margin: (BlInsets all: 25);
		constraintsDo: [ :c | 
			c frame horizontal alignRight.
			c frame vertical alignTop ];
		label: 'Play slideshow in new window';
		icon: BrGlamorousVectorIcons play;
		action: [ :aBrButton :aBrButtonModel :anEvent | 
			| gtPresenterSlideshow slideshowElement slideshowViewModel |
			anEvent consumed: true.
			gtPresenterSlideshow := GtPresenterSlideShow new.
			gtPresenterSlideshow slides
				slides: (self elementSnippets
						collect: [ :elementSnippet | 
							GtPresenterSlide new
								stencil: [ GtElementLiveSlide new
										element: [ elementSnippet coder asCoderViewModel doIt value ] ]
										asStencil ]).
			slideshowViewModel := GtPresenterSlideShowViewModel new
					slideShow: gtPresenterSlideshow.
			slideshowElement := GtPresenterSlideShowElement new
					slideShowViewModel: slideshowViewModel.
			BlSpace new
				withSceneDriller;
				addChild: slideshowElement;
				show ]
]

{ #category : #ui }
LeSlideshowPageElement >> slidesDetailTool [
	| pane slideDetailContainer |
	pane := BrHorizontalPane new
			id: #slidesDetailTool;
			matchParent.
	slideDetailContainer := BrVerticalPane new
			padding: (BlInsets all: 10);
			matchParent;
			alignCenter;
			constraintsDo: [ :c | c linear weight: 4 ];
			addChild: self placeholderElement.
	self onSnippetRemoved: slideDetailContainer.

	^ pane
		addChildren: {self slidesList.
				slideDetailContainer}
]

{ #category : #ui }
LeSlideshowPageElement >> slidesGrid [
	self columnCount: self detailedColumnCount.
	^ BrHorizontalGrid new
		id: #slidesGrid;
		hMatchParent;
		vFitContent;
		columnCount: self columnCount;
		cellSpacing: 10;
		addChildren: (self elementSnippets
				collect: [ :aSnippet | LeSlideshowPageSlideGridElement forSnippet: aSnippet ])
]

{ #category : #ui }
LeSlideshowPageElement >> slidesGridTool [
	| aFrame aGrid aScrollable |
	aFrame := BrFrame new
			id: #slidesGridTool;
			matchParent.
	aGrid := self slidesGrid.
	aScrollable := BrFrame new
			hMatchParent;
			vFitContent;
			addChild: aGrid;
			asScrollableElement.
	aFrame
		addChildren: {aScrollable.
				self changeLayoutButton.
				self playSlideshowButton}.
	self onSnippetAdded: aGrid.
	self onSnippetRemoved: aGrid.

	^ aFrame
]

{ #category : #ui }
LeSlideshowPageElement >> slidesList [
	| aVerticalPane |
	aVerticalPane := BrVerticalPane new
			hMatchParent;
			vFitContent;
			padding: (BlInsets all: 10);
			constraintsDo: [ :c | c linear weight: 1 ];
			cellSpacing: 10;
			addAptitude: BrShadowAptitude new
					+ (BrGlamorousSlideExteriorAptitude new
							backgroundPaint: Color white;
							borderPaint: Color transparent);
			addChildren: (self elementSnippets
					collect: [ :aSnippet | LeSlideshowPageSlideListElement forSnippet: aSnippet ]).
	self onSnippetAdded: aVerticalPane.
	self onSnippetRemoved: aVerticalPane.
	self page announcer weak
		when: LeContentTreeChanged
		do: [ :anEvent | 
			anEvent content = self page
				ifTrue: [ | slideElements |
					slideElements := aVerticalPane children
							groupedBy: [ :each | each snippet uid ].
					aVerticalPane removeChildren.
					self elementSnippets
						do: [ :each | aVerticalPane addChild: (slideElements at: each uid) first ] ] ].
	^ aVerticalPane asScrollableElement
]

{ #category : #ui }
LeSlideshowPageElement >> summaryColumnCount [
	^ 4
]
