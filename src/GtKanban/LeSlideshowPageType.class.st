Class {
	#name : #LeSlideshowPageType,
	#superclass : #LeNamedPageType,
	#traits : 'TGtAnnouncer',
	#classTraits : 'TGtAnnouncer classTrait',
	#instVars : [
		'columnCount',
		'announcer'
	],
	#category : #'GtKanban-Model'
}

{ #category : #initialization }
LeSlideshowPageType class >> initialize [
	self flag: #TODO.	"Remove once upstream is merged on superclass"
	super initialize.
	self leJsonV4MappingFor: LeJsonV4 uniqueInstance newWriter.
	self leJsonV4MappingFor: LeJsonV4 uniqueInstance newReader.
	LeDatabasesRegistry defaultLogicalDatabase databases
		do: [ :aDatabase | aDatabase pagesByType at: self ifAbsentPut: [ GtStringContentDictionary new ] ]
]

{ #category : #jsonV4 }
LeSlideshowPageType class >> leJsonV4AttributeMapping [

	^ super leJsonV4AttributeMapping
		yourself
]

{ #category : #accesing }
LeSlideshowPageType class >> leJsonV4Name [

	^ 'slideshowPage'
]

{ #category : #printing }
LeSlideshowPageType class >> niceClassName [
	^ 'Slideshow Page'
]

{ #category : #examples }
LeSlideshowPageType class >> samplePage [
	| aPage slideCode |
	aPage := LePage new.
	aPage
		type: (LeSlideshowPageType new
				title: 'A Sample Slideshow';
				page: aPage).

	slideCode := [ GtProtoLiveSlide new textAndElement
			elementWeight: 0.5;
			newTextWithFormat: ('Header' asRopedText
					glamorousRegularFont;
					bold;
					fontSize: 32;
					bold) , String cr asRopedText
					, ('description' asRopedText
							glamorousRegularFont;
							fontSize: 20);
			element: [ GtLudoGame new asElement asScalableElement ] ].

	aPage
		addSnippet: (LeElementSnippet
				code: slideCode sourceNode formattedCode allButFirst allButLast).
	2
		to: 9
		do: [ :n | 
			aPage
				addSnippet: (LeElementSnippet
						code: 'BlBasicExamples new circle background: Color random "Slide # ' , n asString
								, '. Move slides around to change slide order"') ].
	^ aPage
]

{ #category : #announcer }
LeSlideshowPageType >> announcer [
	^ announcer ifNil: [ announcer := Announcer new ]
]

{ #category : #ui }
LeSlideshowPageType >> asPreviewElement [
	^ self defaultPhlowTool asElement
]

{ #category : #ui }
LeSlideshowPageType >> changeLayoutButton [
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
LeSlideshowPageType >> columnCount [
	^ columnCount
]

{ #category : #accessing }
LeSlideshowPageType >> columnCount: anInteger [
	columnCount := anInteger
]

{ #category : #converting }
LeSlideshowPageType >> defaultPhlowTool [
	^ GtPhlowExplicitTool new withIconAptitude
		name: self page title;
		icon: BrGlamorousVectorIcons play;
		stencil: [ self slidesTool ]
]

{ #category : #ui }
LeSlideshowPageType >> detailedColumnCount [
	^ 2
]

{ #category : #accessing }
LeSlideshowPageType >> elementSnippets [
	| result |
	result := OrderedCollection new.
	self page children ifEmpty: [ self page addSnippet: LeElementSnippet ].
	self page
		withAllChildrenDepthFirstDo: [ :aSnippet | (aSnippet isKindOf: LeElementSnippet) ifTrue: [ result add: aSnippet ] ].

	^ result
]

{ #category : #accessing }
LeSlideshowPageType >> pageTypeRepo [
	^ pageTypeRepo ifNil: [ pageTypeRepo := 'https://github.com/feenkcom/lepiter' ]
]

{ #category : #ui }
LeSlideshowPageType >> playSlideshowButton [
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

{ #category : #printing }
LeSlideshowPageType >> printOn: aStream [

	aStream 
		nextPutAll: 'Slideshow Page: ';
		print: title
]

{ #category : #examples }
LeSlideshowPageType >> samplePage [
	<gtExample>
	^ self class samplePage
]

{ #category : #ui }
LeSlideshowPageType >> slideDetailElementFor: aSnippet inParentTool: parentTool [
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
				updateCoderHeightTo: parentTool extent y * 0.20;
				updateElementHeightTo: parentTool extent y * 0.70.
			aFrame addChild: aLeSnippetContainerElement ] asBlTask.
	^ aFrame
]

{ #category : #ui }
LeSlideshowPageType >> slidesDetail [
	^ self elementSnippets first
		in: [ :aSnippet | 
			BrFrame new
				padding: (BlInsets all: 10);
				matchParent;
				addAptitude: BrShadowAptitude new
						+ (BrGlamorousSlideExteriorAptitude new
								backgroundPaint: Color white;
								borderPaint: Color transparent);
				addChild: (aSnippet
						codeHeight: 200;
						asPreviewElement) ]
]

{ #category : #ui }
LeSlideshowPageType >> slidesDetailTool [
	| pane |
	pane := BrHorizontalPane new
			id: #slidesDetailTool;
			matchParent.
	^ pane
		addChildren: {self slidesList.
				self slideDetailElementFor: self elementSnippets first inParentTool: pane}
]

{ #category : #ui }
LeSlideshowPageType >> slidesGrid [
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
LeSlideshowPageType >> slidesGridTool [
	| grid scrollable |
	
	grid := self slidesGrid.
	scrollable := BrFrame new
			hMatchParent;
			vFitContent;
			addChild: grid;
			asScrollableElement.
	^ BrFrame new matchParent
		addChildren: {scrollable.
				self changeLayoutButton.
				self playSlideshowButton}
]

{ #category : #ui }
LeSlideshowPageType >> slidesList [
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
LeSlideshowPageType >> slidesTool [
	| aFrame |
	aFrame := BrFrame new
			id: #slidesTool;
			matchParent.
	aFrame
		addAptitude: (GtPhlowToolDetailAptitude new
				normal: [ :aStyle | 
					aStyle
						do: [ aFrame
								removeChildren;
								addChild: self slidesGridTool ] ];
				detailed: [ :aStyle | 
					aStyle
						do: [ aFrame
								removeChildren;
								addChild: self slidesDetailTool ] ]).
	^ aFrame
]

{ #category : #ui }
LeSlideshowPageType >> summaryColumnCount [
	^ 4
]
