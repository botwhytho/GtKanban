Extension { #name : #LePageType }

{ #category : #'*GtKanban' }
LePageType >> asLepiterPagePhlowTool [
	^ (self class defaultSystemPageTypes includes: self class)
		ifTrue: [ self page asLepiterPagePhlowTool ]
		ifFalse: [ GtPhlowCompositeTool new
				addTool: self defaultPhlowTool;
				addTool: (GtPhlowExplicitTool new withLabelAndIconAptitude
						icon: BrGlamorousVectorIcons inspect;
						name: 'Page Type';
						stencil: [ (GtPhlowTool default object: self) asElement ]);
				addTool: (GtPhlowExplicitTool new withLabelAndIconAptitude
						icon: BrGlamorousVectorIcons inspect;
						name: 'Page';
						stencil: [ (GtPhlowTool default object: self page) asElement ]) ]
]

{ #category : #'*GtKanban' }
LePageType >> asPreviewElement [
	^ LePageToolContentTreeElement new
		withTitleOnly;
		pageViewModel: self page asContentUIModel;
		matchParent
]

{ #category : #'*GtKanban' }
LePageType >> defaultPhlowTool [
	^ LePagePhlowTool new
		shouldFocusFirstSnippet: true;
		page: self
]

{ #category : #'*GtKanban' }
LePageType class >> defaultSystemPageTypes [
	^ {LeDailyNotePageType.
		LeNamedPageType.
		LePharoClassCommentPageType.
		LePharoClassPageType.
		LeProxyClassPageType.
		LeUnnamedPageType.
		LeUnknownNamedPageType.
		LeUnknownUnnamedPageType}
]

{ #category : #'*GtKanban' }
LePageType class >> initialize [
	super initialize.
	self = LePageType
		ifFalse: [ self leJsonV4MappingFor: LeJsonV4 uniqueInstance newWriter.
			self leJsonV4MappingFor: LeJsonV4 uniqueInstance newReader.
			LeDatabasesRegistry defaultLogicalDatabase databases
				do: [ :aDatabase | aDatabase pagesByType at: self ifAbsentPut: [ GtStringContentDictionary new ] ] ]
]
