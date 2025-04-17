Trait {
	#name : #TLeUnknownPageType,
	#instVars : [
		'pageType',
		'additionalFields'
	],
	#category : #'GtKanban-Traits'
}

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
				name: 'Unknown (' , self pageType asString , ')Page Type';
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
