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
		page: self page
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
LePageType class >> gtSamplePageFor: anAction [
	<gtClassAction>
	(self respondsTo: #samplePage) ifFalse: [ anAction noAction ].

	^ anAction button
		priority: 0;
		tooltip: 'Browse Sample Page';
		icon: BrGlamorousVectorIcons eg;
		action: [ :aButton | aButton phlow spawnObject: (self perform: #samplePage) ]
]

{ #category : #'*GtKanban' }
LePageType >> initialize [
super initialize.
self pageTypeRepo
]

{ #category : #'*GtKanban' }
LePageType class >> initialize [
	super initialize.
	self flag: #HACK.	"Can't have 'extension' slots on a class, so need to programatically create here until I move code to correct packages"
	self = LePageType
		ifTrue: [ [ self slotNamed: #pageTypeRepo ]
				on: SlotNotFound
				do: [ self addSlot: #pageTypeRepo ] ]
		ifFalse: [ self leJsonV4MappingFor: LeJsonV4 uniqueInstance newWriter.
			self leJsonV4MappingFor: LeJsonV4 uniqueInstance newReader.
			LeDatabasesRegistry defaultLogicalDatabase databases
				do: [ :aDatabase | aDatabase pagesByType at: self ifAbsentPut: [ GtStringContentDictionary new ] ] ]
]

{ #category : #'*GtKanban' }
LePageType >> pageTypeRepo [
	"Return a URL where one can get more details about downloading the code needed to support this page type"

	(self class defaultSystemPageTypes includes: self class)
		ifFalse: [ self shouldBeImplemented ]
]

{ #category : #'*GtKanban' }
LePageType >> pageTypeRepo: anObject [
	pageTypeRepo := anObject
]
