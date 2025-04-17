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
TLeUnknownPageType classSide >> leJsonV4AttributeMapping [
	^ super leJsonV4AttributeMapping
		add: #pageTypeRepo -> #pageTypeRepo;
		add: #pageType -> #'__type';
		yourself
]

{ #category : #jsonV4 }
TLeUnknownPageType classSide >> leJsonV4MappingFor: aNeoJSONMapper [
	aNeoJSONMapper
		for: self
		do: [ :mapping | 
			mapping
				mapProperty: #additionalFields
				getter: #yourself
				setter: [ :object :value | 
					value
						, (mapping
								associationsSelect: [ :each | 
									((self leJsonV4AttributeMapping collect: #value) , #additionalFields
										includes: each key) not ]) ].

			self leJsonV4AddMappingsTo: mapping ]
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
