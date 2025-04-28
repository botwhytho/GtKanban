Class {
	#name : #LeSlideshowPageElement,
	#superclass : #BrHorizontalPane,
	#instVars : [
		'columnCount',
		'page',
		'slidesGridTool',
		'slidesDetailTool',
		'toolDetailAptitude'
	],
	#category : #'GtKanban-UI'
}

{ #category : #initialization }
LeSlideshowPageElement class >> page: aLePage [
	^ self basicNew
		page: aLePage;
		initialize
]

{ #category : #initialization }
LeSlideshowPageElement >> addExplainerToButtons: anElement [
	| buttonsToExplain |
	buttonsToExplain := {#slideList
				-> (anElement query // #'slidesChangeLayoutButton') anyOne }.
	buttonsToExplain
		do: [ :each | 
			each value
				preventChildrenMouseEvents;
				addChild: (BrButton new
						constraintsDo: [ :c | c ignoreByLayout ];
						size: 25 @ 25;
						elevation: (BlRelativeElevation elevation: 10);
						geometry: BlCircle new;
						aptitude: (GtExplainerTargetAptitude new explanationModel: each key);
						relocate: 5 @ each value extent y / 2) ].
	^ anElement
]

{ #category : #initialization }
LeSlideshowPageElement >> addSlideLabel [
	^ BrLabel new
		aptitude: (BrGlamorousLabelAptitude new fontSize: 20);
		text: 'Add Slide';
		padding: (BlInsets top: 50)
]

{ #category : #ui }
LeSlideshowPageElement >> changeLayoutButton [
	^ BrButton new
		id: #slidesChangeLayoutButton;
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
LeSlideshowPageElement >> howToEditor [
	^ (BrEditor new
		aptitude: BrGlamorousRegularEditorAptitude new;
		beReadOnlyWithSelection;
		text: self howToText)
		constraintsDo: [ :c | 
			c vertical fitContent.
			c horizontal matchParent ];
		margin: (BlInsets
				top: 50
				left: 50
				bottom: 0
				right: 50)
]

{ #category : #initialization }
LeSlideshowPageElement >> howToText [
	^ ('Lorem ipsum' asRopedText glamorousExplanationFor: #slideList)
		, 'dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
				asRopedText
]

{ #category : #initialization }
LeSlideshowPageElement >> howToTool [
	| verticalPane |
	verticalPane := BrVerticalPane new matchParent
			alignBottomCenter;
			addChildren: {self addSlideLabel.
					self newAddSlideDropdown.
					self howToEditor.
					self toolForExplainer}.
	verticalPane explainer isExplanationHolder: true.
	self addExplainerToButtons: verticalPane.
	^ verticalPane
]

{ #category : #initialization }
LeSlideshowPageElement >> initializaTools [
	toolDetailAptitude
		ifNotNil: [ self removeAptitude: toolDetailAptitude.
			toolDetailAptitude := nil ].
	self page type elementSnippets size = 0
		ifTrue: [ self
				removeChildren;
				addChild: self howToTool asElement ]
		ifFalse: [ self
				removeChildren;
				addChildren: {slidesDetailTool := self slidesDetailTool.
						slidesGridTool := self slidesGridTool};
				addAptitude: (toolDetailAptitude := GtPhlowToolDetailAptitude new
							normal: [ :aStyle | 
								aStyle
									do: [ slidesDetailTool visibility: BlVisibility gone.
										slidesGridTool visibility: BlVisibility visible ] ];
							detailed: [ :aStyle | 
								aStyle
									do: [ slidesDetailTool visibility: BlVisibility visible.
										slidesGridTool visibility: BlVisibility gone ] ]) ]
]

{ #category : #initialization }
LeSlideshowPageElement >> initialize [
	super initialize.
	self phlow beViewContent.
	self
		id: #slideshowPageTool;
		matchParent.
	self initializaTools.
	self page announcer weak
		when: LeContentTreeRemoved
		do: [ :anAnnouncement | 
			self page type elementSnippets size = 0
				ifTrue: [ self initializaTools ] ]
]

{ #category : #initialization }
LeSlideshowPageElement >> newAddSlideDropdown [
	<return: #BlElement>
	| aButton |
	aButton := self newPlusElement.
	aButton
		addAptitude: (BrGlamorousWithExplicitDropdownAptitude
				handle: [ self newPlusElement
						aptitude: BrIconAptitude;
						background: BrGlamorousColors secondaryHeaderBackgroundColor ]
				content: [ GtSpotterDropdownButtonStencil new
						valuable: LeSlideshowPageSpotterStart new;
						extent: [ 800 @ 600 ];
						objectActOn: [ :anActOnEvent :aMenuItem :theButton | 
							self page addSnippet: aMenuItem asSnippet.
							self initializaTools.
							anActOnEvent beActed ];
						spotterElementFor: aButton ]
				containerDo: [ :aMenuContainer | aMenuContainer background: BrGlamorousColors secondaryHeaderBackgroundColor ])
				doNotHideWidget.
	^ aButton
]

{ #category : #initialization }
LeSlideshowPageElement >> newPlusElement [
	<return: #BlElement>
	^ GtInspectorRoundButtonStencil large asElement
		icon: (BrPlusIconStencil add
				thickness: 1;
				radius: 4;
				asElement);
		margin: (BlInsets top: 10 bottom: 20)
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
		id: #playSlidesButton;
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
			id: #slidesDetail;
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
			id: #slidesList;
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

{ #category : #initialization }
LeSlideshowPageElement >> toolForExplainer [
	| tool samplePage |
	samplePage := LeSlideshowPageType samplePage.
	tool := samplePage type tool.
	tool
		removeAptitude: (tool aptitude children
				detect: [ :each | each isKindOf: GtPhlowToolDetailAptitude ]).
	tool children
		do: [ :each | 
			each
				margin: (BlInsets
						top: 100
						bottom: 100
						left: 25
						right: 25);
				addAptitude: BrShadowAptitude new
						+ (BrGlamorousButtonExteriorAptitude new
								backgroundPaint: Color white;
								borderPaint: Color transparent) ].
	^ tool
]
