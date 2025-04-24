Class {
	#name : #LeSlideshowPageElement,
	#superclass : #BrHorizontalPane,
	#traits : 'TGtAnnouncer',
	#classTraits : 'TGtAnnouncer classTrait',
	#instVars : [
		'columnCount',
		'announcer',
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

{ #category : #announcer }
LeSlideshowPageElement >> announcer [
	^ announcer ifNil: [ announcer := Announcer new ]
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
					self announce: GtSlidesGridShowMoreDetailEvent new ]
				ifFalse: [ grid columnCount: self summaryColumnCount.
					self columnCount: self summaryColumnCount.
					(grid query // LeElementSnippetElement) result
						do: [ :aSnippetElement | aSnippetElement hideCoder ].
					self announce: GtSlidesGridShowLessDetailEvent new ] ]
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
				ifTrue: [ | snippetsInUI previousSnippet |
					snippetsInUI := (aGrid query // LeSnippetContainerElement) result.
					previousSnippet := self
							previousSnippetBeforeNewSnippet: snippetsInUI
							inPage: self elementSnippets.
					self flag: #TODO.	"How to define the correct element creation logic depending on the view we are in. Maybe create classes and have logic there?"
					aGrid
						addChild: (self slideGridElementForSnippet: anAnnouncement content)
						after: previousSnippet ] ]
]

{ #category : #ui }
LeSlideshowPageElement >> onSnippetRemoved: aGrid [
	self flag: #TODO. "Probably better to use LeContentTreeRemoved"
	self page announcer weak
		when: LeContentCommandExecutedAnnouncement
		do: [ :anAnnouncement | 
			((anAnnouncement command isKindOf: LeContentRemoveChildSnippetCommand)
				and: [ anAnnouncement command childSnippet isKindOf: LeElementSnippet ])
				ifTrue: [ (aGrid query // LeSnippetContainerElement) result
						detect: [ :each | 
							each children first snippetViewModel snippetModel
								= anAnnouncement command childSnippet ]
						ifFound: [ :found | aGrid removeChild: found parent ] ] ]
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
LeSlideshowPageElement >> previousSnippetBeforeNewSnippet: snippetElementsInUI inPage: pageSnippets [
	| snippetsInUIStream snippetsInUI pageSnippetsStream previousSnippet currentSnippet newSnippet |
	snippetsInUI := snippetElementsInUI
			collect: [ :each | each -> each children first snippetViewModel snippetModel ].
	snippetsInUIStream := snippetsInUI readStream.
	pageSnippetsStream := pageSnippets readStream.
	previousSnippet := nil.
	currentSnippet := nil.
	newSnippet := nil.
	[ previousSnippet := currentSnippet.
	currentSnippet := snippetsInUIStream next.
	previousSnippet ifNil: [ previousSnippet := currentSnippet ].
	newSnippet := pageSnippetsStream next.
	currentSnippet value = newSnippet and: [ snippetsInUIStream atEnd not ] ]
		whileTrue.
	self flag: #TODO.	"REALLY clean up this code. Probably use wrapper classes for the snippet elements to keep them clean."
	^ currentSnippet = newSnippet
		ifTrue: [ currentSnippet key parent ]
		ifFalse: [ previousSnippet "currentSnippet" key parent ]
]

{ #category : #ui }
LeSlideshowPageElement >> slideDetailElementFor: aSnippet inParentTool: parentTool [
	| aFrame |
	aFrame := BrFrame new
			padding: (BlInsets all: 10);
			matchParent;
			constraintsDo: [ :c | c linear weight: 4 ];
			addAptitude: BrShadowAptitude new
					+ (BrGlamorousSlideExteriorAptitude new
							backgroundPaint: Color white;
							borderPaint: Color transparent).
	self onSnippetRemoved: aFrame.
	aFrame
		enqueueTask: [ | aLeSnippetContainerElement |
			aLeSnippetContainerElement := aSnippet asSlideshowPageElement.
			aLeSnippetContainerElement children first
				updateCoderHeightTo: parentTool extent y * 0.25;
				updateElementHeightTo: parentTool extent y * 0.65.
			aFrame
				addChild: (BrFrame new
						matchParent;
						addChild: aLeSnippetContainerElement) ] asBlTask.
	^ aFrame
]

{ #category : #ui }
LeSlideshowPageElement >> slideGridElementForSnippet: aSnippet [
	| aFrame reorderingHandler |
	reorderingHandler := GtSlideReorderingHandler new page: self page.
	aFrame := BrFrame new.
	self weak
		when: GtSlidesGridShowMoreDetailEvent
			do: [ :anAnnouncement | 
				aFrame
					allowChildrenMouseEvents;
					removeEventHandler: reorderingHandler ];
		when: GtSlidesGridShowLessDetailEvent
			do: [ :anAnnouncement | 
				aFrame
					preventChildrenMouseEvents;
					addEventHandler: reorderingHandler ].
	^ aFrame
		vFitContent;
		hMatchParent;
		addAptitude: BrShadowAptitude new
				+ (BrGlamorousSlideExteriorAptitude new
						backgroundPaint: Color white;
						borderPaint: Color transparent);
		when: BlMouseLeaveEvent
			do: [ :anEvent | 
				anEvent consumed: true.
				aFrame hasFocus ifTrue: [ aFrame loseFocus ] ];
		addChild: (aSnippet
				elementHeight: 200;
				codeHeight: 200;
				asSlideshowPageElement)
]

{ #category : #ui }
LeSlideshowPageElement >> slideListElementForSnippet: aSnippet [
	| aFrame |
	aFrame := BrFrame new.
	^ aFrame
		matchParent;
		preventChildrenMouseEvents;
		addAptitude: BrShadowAptitude new
				+ (BrGlamorousSlideExteriorAptitude new
						backgroundPaint: Color white;
						borderPaint: Color transparent);
		when: BlClickEvent
			do: [ :anEvent | 
				| clickedSnipet expandedSnippet parentTool |
				anEvent consumed: true.
				aFrame allowChildrenMouseEvents.
				parentTool := anEvent currentTarget
						allParentsDetect: [ :anElement | anElement id asSymbol = #slidesDetailTool ]
						ifFound: #yourself
						ifNone: [ nil ].
				clickedSnipet := (anEvent currentTarget query // LeElementSnippetElement)
						result first snippetViewModel snippetModel.
				expandedSnippet := (parentTool children second query
						// LeElementSnippetElement) result first snippetViewModel snippetModel.
				"clickedSnipet = expandedSnippet
					ifFalse: [" parentTool
							replaceChild: parentTool children second
							with: (self slideDetailElementFor: clickedSnipet inParentTool: parentTool).
							parentTool enqueueTask: [ (parentTool children second query
						// #'source-coder--editor') result first requestFocus] asBlTask. "]" ];
		when: BlMouseLeaveEvent
			do: [ :anEvent | 
				anEvent consumed: true.
				aFrame hasFocus ifTrue: [ aFrame loseFocus ].
				aFrame preventChildrenMouseEvents ];
		addChild: (aSnippet asSlideshowPageElement
				in: [ :aLeSnippetContainerElement | 
					aLeSnippetContainerElement children first hideCoder.
					aLeSnippetContainerElement ])
]

{ #category : #ui }
LeSlideshowPageElement >> slidesDetailTool [
	| pane |
	pane := BrHorizontalPane new
			id: #slidesDetailTool;
			matchParent.
	^ pane
		addChildren: {self slidesList.
				self slideDetailElementFor: self elementSnippets first inParentTool: pane}
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
				collect: [ :aSnippet | 
					"aSnippet
						codeHeight: 200;
						elementHeight: 200.
					self slideGridElementForSnippet: aSnippet"
					LeSlideshowPageSlideGridElement forSnippet: aSnippet
					 ])
]

{ #category : #ui }
LeSlideshowPageElement >> slidesGridTool [
	| aFrame aGrid aScrollable |
	aFrame := BrFrame new matchParent.
	aGrid := self slidesGrid.
	aScrollable := BrFrame new
			hMatchParent;
			vFitContent;
			addChild: aGrid;
			asScrollableElement.
	self onSnippetAdded: aGrid.
	self onSnippetRemoved: aGrid.

	^ aFrame
		addChildren: {aScrollable.
				self changeLayoutButton.
				self playSlideshowButton}
]

{ #category : #ui }
LeSlideshowPageElement >> slidesList [
	| aVerticalPane |
	self columnCount: self detailedColumnCount.
	aVerticalPane := BrVerticalPane new
			hMatchParent;
			vFitContent;
			constraintsDo: [ :c | c linear weight: 1 ];
			cellSpacing: 10.
	self onSnippetRemoved: aVerticalPane.
	self page announcer weak
		when: LeContentTreeChanged
		do: [ :anEvent | 
			anEvent logToNamed: 'Slides'.
			anEvent content = self page
				ifTrue: [ | slideElements |
					slideElements := aVerticalPane children
							groupedBy: [ :each | 
								(each query // LeElementSnippetElement) result first snippetViewModel
									snippetModel uid ].
					aVerticalPane removeChildren.
					self elementSnippets
						do: [ :each | aVerticalPane addChild: (slideElements at: each uid) first ] ] ].
	^ aVerticalPane
		addChildren: (self elementSnippets
				collect: [ :aSnippet | LeSlideshowPageSlideListElement forSnippet: aSnippet ]);
		asScrollableElement
]

{ #category : #ui }
LeSlideshowPageElement >> summaryColumnCount [
	^ 4
]
