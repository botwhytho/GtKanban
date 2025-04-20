Class {
	#name : #LeSlideshowPageElement,
	#superclass : #BrVerticalPane,
	#traits : 'TGtAnnouncer',
	#classTraits : 'TGtAnnouncer classTrait',
	#instVars : [
		'columnCount',
		'announcer',
		'page'
	],
	#category : #'GtKanban-UI'
}

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

{ #category : #'initialization\t' }
LeSlideshowPageElement >> initialize [
	super initialize.
	self
		id: #slideshowPageTool;
		matchParent;
		addAptitude: (GtPhlowToolDetailAptitude new
				normal: [ :aStyle | 
					aStyle
						do: [ self
								removeChildren;
								addChild: self slidesGridTool ] ];
				detailed: [ :aStyle | 
					aStyle
						do: [ self
								removeChildren;
								addChild: self slidesDetailTool ] ])
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
	aFrame
		enqueueTask: [ | aLeSnippetContainerElement |
			aLeSnippetContainerElement := aSnippet asPreviewElement.
			aLeSnippetContainerElement children first
				updateCoderHeightTo: parentTool extent y * 0.25;
				updateElementHeightTo: parentTool extent y * 0.65.
			aFrame addChild: aLeSnippetContainerElement ] asBlTask.
	^ aFrame
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
					aFrame
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
								asPreviewElement) ])
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
	self page announcer weak
		when: LeContentCommandExecutedAnnouncement
		do: [ :anAnnouncement | 
			(anAnnouncement command isKindOf: LeContentRemoveChildSnippetCommand)
				ifTrue: [ (aFrame query // LeSnippetContainerElement) result
						detect: [ :each | 
							each children first snippetViewModel snippetModel
								= anAnnouncement command childSnippet ]
						ifFound: [ :found | aGrid removeChild: found parent ] ] ].

	^ aFrame
		addChildren: {aScrollable.
				self changeLayoutButton.
				self playSlideshowButton}
]

{ #category : #ui }
LeSlideshowPageElement >> slidesList [
	self columnCount: self detailedColumnCount.
	^ BrVerticalPane new
		hMatchParent;
		vFitContent;
		constraintsDo: [ :c | c linear weight: 1 ];
		cellSpacing: 10;
		addChildren: (self elementSnippets
				collect: [ :aSnippet | 
					BrFrame new
						matchParent;
						addAptitude: BrShadowAptitude new
								+ (BrGlamorousSlideExteriorAptitude new
										backgroundPaint: Color white;
										borderPaint: Color transparent);
						when: BlDoubleClickEvent
							do: [ :anEvent | 
								| parentTool |
								anEvent consumed: true.
								parentTool := anEvent currentTarget
										allParentsDetect: [ :anElement | anElement id asSymbol = #slidesDetailTool ]
										ifFound: #yourself
										ifNone: [ nil ].
								parentTool
									replaceChild: parentTool children second
									with: (self
											slideDetailElementFor: (anEvent currentTarget query // LeElementSnippetElement) result first
													snippetViewModel snippetModel
											inParentTool: parentTool) ];
						addChild: ((aSnippet
								asPreviewElement)
								in: [ :aLeSnippetContainerElement | 
									aLeSnippetContainerElement children first hideCoder.
									aLeSnippetContainerElement ]) ]);
		asScrollableElement
]

{ #category : #ui }
LeSlideshowPageElement >> summaryColumnCount [
	^ 4
]
