Class {
	#name : #LeSlideshowPageType,
	#superclass : #LeNamedPageType,
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

{ #category : #ui }
LeSlideshowPageType >> asPreviewElement [
	^ self defaultPhlowTool asElement
]

{ #category : #converting }
LeSlideshowPageType >> defaultPhlowTool [
	^ GtPhlowExplicitTool new withIconAptitude
		name: self page title;
		icon: BrGlamorousVectorIcons play;
		stencil: [ self slidesCreator ]
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
LeSlideshowPageType >> slidesCreator [
	| button container grid scrollable |
	container := BrFrame new
			hMatchParent;
			vFitContent.

	grid := BrHorizontalGrid new
			hMatchParent;
			vFitContent;
			columnCount: 2;
			cellSpacing: 10;
			addChildren: (self elementSnippets
					collect: [ :aSnippet | 
						BrFrame new
							vFitContent;
							hMatchParent;
							addEventHandler: BlReorderingHandler new;
							preventChildrenMouseEvents;
							addAptitude: BrShadowAptitude new
									+ (BrGlamorousButtonExteriorAptitude new
											backgroundPaint: Color white;
											borderPaint: Color transparent);
							in: [ :aFrame | 
								aFrame
									when: BlDoubleClickEvent
										do: [ :anEvent | 
											anEvent consumed: true.
											aFrame allowChildrenMouseEvents ];
									when: BlMouseLeaveEvent
										do: [ :anEvent | 
											anEvent consumed: true.
											anEvent currentTarget loseFocus.
											aFrame preventChildrenMouseEvents ].
								aFrame ];
							addChild: (aSnippet
									elementHeight: 200;
									codeHeight: 200;
									asPreviewElement) ]).

	button := BrButton new
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
					slides: (grid children
							collect: [ :elementSnippets | 
								GtPresenterSlide new
									stencil: [ GtElementLiveSlide new
											element: [ self flag: #TODO.	"Use editor machinery to run code"
												Object
													evaluate: elementSnippets snippetViewModel snippetModel coder currentSourceString ] ]
											asStencil ]).
				slideshowViewModel := GtPresenterSlideShowViewModel new
						slideShow: gtPresenterSlideshow.
				slideshowElement := GtPresenterSlideShowElement new
						slideShowViewModel: slideshowViewModel.
				BlSpace new
					withSceneDriller;
					addChild: slideshowElement;
					show ].

	scrollable := container
			addChild: grid;
			asScrollableElement.

	^ BrFrame new matchParent
		addChildren: {scrollable.
				button}
]
