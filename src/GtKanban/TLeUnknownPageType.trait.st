Trait {
	#name : #TLeUnknownPageType,
	#instVars : [
		'pageType',
		'additionalFields',
		'pageTypeRepo'
	],
	#category : #'GtKanban-Traits'
}

{ #category : #jsonV4 }
TLeUnknownPageType classSide >> leFromJsonV4Dictionary: aDictionary [
	"Create a new instance of the receiver from the supplied dictionary.
	Store additional fields in the slot named as such."

	| anUnknownPageType knownMapKeys |
	anUnknownPageType := super leFromJsonV4Dictionary: aDictionary.
	knownMapKeys := self leJsonV4AttributeMapping collect: #value.
	anUnknownPageType
		additionalFields: (aDictionary
				associationsSelect: [ :each | (knownMapKeys includes: each key) not ]).
	aDictionary
		at: #additionalFields
		ifPresent: [ :aValue | anUnknownPageType additionalFields addAll: aValue ].
	^ anUnknownPageType
]

{ #category : #jsonV4 }
TLeUnknownPageType classSide >> leJsonV4AttributeMapping [
	^ super leJsonV4AttributeMapping
		add: #pageTypeRepo -> #pageTypeRepo;
		add: #pageType -> #'__type';
		yourself
]

{ #category : #jsonV4 }
TLeUnknownPageType classSide >> leJsonV4MappingFor: aNeoJSONMapper [
	aNeoJSONMapper for: self do: [ :mapping | self leJsonV4AddMappingsTo: mapping ]
]

{ #category : #accessing }
TLeUnknownPageType >> additionalFields [
	^ additionalFields
]

{ #category : #accessing }
TLeUnknownPageType >> additionalFields: anObject [
	additionalFields := anObject
]

{ #category : #'as yet unclassified' }
TLeUnknownPageType >> asLepiterPagePhlowTool [
	^ GtPhlowCompositeTool new
		addTool: self defaultPhlowTool;
		addTool: (GtPhlowExplicitTool new withLabelAndIconAptitude
				icon: BrGlamorousVectorIcons debug;
				name: 'Unknown (' , self pageType asString , ') Page Type';
				stencil: [ (GtPhlowTool default object: self) asElement ]);
		addTool: (GtPhlowExplicitTool new withLabelAndIconAptitude
				icon: BrGlamorousVectorIcons inspect;
				name: 'Page';
				stencil: [ (GtPhlowTool default object: self page) asElement ])
]

{ #category : #accessing }
TLeUnknownPageType >> pageType [
	^ pageType
]

{ #category : #accessing }
TLeUnknownPageType >> pageType: anObject [
	pageType := anObject
]

{ #category : #accessing }
TLeUnknownPageType >> pageTypeRepo [
	^ pageTypeRepo
]
