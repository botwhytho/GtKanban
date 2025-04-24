Class {
	#name : #LeSlideshowNewSlideItemSpecification,
	#superclass : #Object,
	#traits : 'TLeContextMenuItemSpecification',
	#classTraits : 'TLeContextMenuItemSpecification classTrait',
	#instVars : [
		'title',
		'definingMethod',
		'preview'
	],
	#classInstVars : [
		'slideTemplates'
	],
	#category : #'GtKanban-Spotter'
}

{ #category : #initialization }
LeSlideshowNewSlideItemSpecification class >> demoSlides [
	^ DemoSlideshow new slidePriorities collect: [ :each | DemoSlideshow >> each ]
]

{ #category : #instantiation }
LeSlideshowNewSlideItemSpecification class >> emptySlideAndTemplates [
	^ self new asArray , self slideTemplates
]

{ #category : #initialization }
LeSlideshowNewSlideItemSpecification class >> slideTemplates [
	^ slideTemplates
		ifNil: [ slideTemplates := self demoSlides
					collect: [ :each | 
						LeSlideshowNewSlideItemSpecification new
							definingMethod: each;
							title: each methodClass name , ' >> ' , '#' , each selector;
							preview: (BrValuableStencil
									from: [ BrVerticalPane new matchParent
											addChildren: {BlTextElement
														text: ((each pragmaAt: #text:)
																ifNil: [ '' ]
																ifNotNil: [ :aPragma | aPragma arguments first ]) asRopedText.
													each asScalableSlide create} ]) ] ]
]

{ #category : #'api - converting' }
LeSlideshowNewSlideItemSpecification >> asSnippet [
	<return: #LeSnippet>
	^ LeElementSnippet new
		uid: LeUID new;
		code: (self rewriteMethod: self definingMethod)
]

{ #category : #'api - accessing' }
LeSlideshowNewSlideItemSpecification >> definingMethod [
	^ definingMethod
]

{ #category : #'api - accessing' }
LeSlideshowNewSlideItemSpecification >> definingMethod: anObject [
	definingMethod := anObject
]

{ #category : #'gt - extensions' }
LeSlideshowNewSlideItemSpecification >> gtDefiningMethodFor: aView [
	<gtView>
	self definingMethod ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Source';
		priority: 2;
		object: [ self definingMethod ];
		view: #gtSourceFor:
]

{ #category : #'gt - extensions' }
LeSlideshowNewSlideItemSpecification >> gtLiveFor: aView [
	<gtView>
	self definingMethod ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Live';
		priority: 1;
		object: [ self asSnippet ];
		view: #gtLiveFor:
]

{ #category : #initialization }
LeSlideshowNewSlideItemSpecification >> initialize [
	super initialize.
	title := 'Empty Slide'
]

{ #category : #accessing }
LeSlideshowNewSlideItemSpecification >> preview [
	^ preview
		ifNil: [ LeElementSnippet new asPreviewElement preventChildrenMouseEvents	"gtPreviewElement asScalableElement" ]
		ifNotNil: [ preview asElement preventChildrenMouseEvents	"gtPreviewElement asScalableElement" ]
]

{ #category : #accessing }
LeSlideshowNewSlideItemSpecification >> preview: aBrStencil [
	preview := aBrStencil
]

{ #category : #printing }
LeSlideshowNewSlideItemSpecification >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPut: $(;
		nextPutAll: self title asString;
		nextPut: $)
]

{ #category : #converting }
LeSlideshowNewSlideItemSpecification >> rewriteMethod: aMethod [
	^ aMethod
		ifNil: [ '' ]
		ifNotNil: [ | anAst slideText |
			anAst := aMethod ast veryDeepCopy.
			anAst body
				addNodeFirst: (RBParser
						parseExpression: '| aSlide| aSlide := GtProtoLiveSlide new.
	aDemo := DemoSlideshow new.').
			slideText := anAst
					pragmaNamed: #text:
					ifPresent: [ :aPragma | aPragma arguments first value ]
					ifAbsent: [ nil ].
			slideText
				ifNotNil: [ anAst body
						addNodeFirst: (RBParser
								parseExpression: '"' , anAst method methodClass name , ' >> ' , '#' , anAst method selector
										, ' | ' , slideText , '"') ].
			anAst removePragmaNamed: #text:.
			anAst removePragmaNamed: #gtSlide.
			anAst allChildren
				select: [ :aNode | (aNode isKindOf: RBVariableNode) and: [ aNode isSelfVariable ] ]
				thenDo: [ :aNode | anAst replaceNode: aNode withNode: (RBParser parseExpression: 'aDemo') ].
			(((anAst newSource lines allButFirst
				reject: [ :each | (each includesSubstring: 'setPriority;') or: [ each includesSubstring: '	.	"' ] ])
				joinUsing: String cr) copyReplaceAll: 'self' with: 'aDemo')
				copyReplaceAll: '^'
				with: '' ]
]

{ #category : #'as yet unclassified' }
LeSlideshowNewSlideItemSpecification >> title [
	^ title
]

{ #category : #'api - accessing' }
LeSlideshowNewSlideItemSpecification >> title: anObject [
	title := anObject
]
