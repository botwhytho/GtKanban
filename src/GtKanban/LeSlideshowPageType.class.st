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
		addSnippet: (LeElementSnippet new
				code: slideCode sourceNode formattedCode allButFirst allButLast;
				uid: LeUID new).
	2
		to: 9
		do: [ :n | 
			aPage
				addSnippet: (LeElementSnippet new
						code: 'BlBasicExamples new circle background: Color random "Slide # ' , n asString
								, '. Move slides around to change slide order"';
				uid: LeUID new) ].
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
		stencil: [ self tool ]
]

{ #category : #accessing }
LeSlideshowPageType >> elementSnippets [
	| result |
	result := OrderedCollection new.
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
LeSlideshowPageType >> tool [
	^ LeSlideshowPageElement new page: self page
]
