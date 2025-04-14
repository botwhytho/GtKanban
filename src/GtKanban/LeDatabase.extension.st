Extension { #name : #LeDatabase }

{ #category : #'*GtKanban' }
LeDatabase >> initialize [
	super initialize.
	readOnly := false.
	pagesByType := IdentityDictionary new.
	pagesByUuid := Dictionary new.
	"Populate all the page types"
	LePageType allSubclassesDo: [ :pageType |
		pagesByType
			at: pageType pageTypeClass
			ifAbsentPut: [ GtStringContentDictionary new ] ].
	blocksByUID := Dictionary new.
	self ensureExplicitLinksStorage.
	self weak
		when: LePageTitleChanged 
		send: #onPageTitleChanged: 
		to: self.
]

{ #category : #'*GtKanban' }
LeDatabase >> pagesByName [
	| namedPageClasses |
	namedPageClasses := (pagesByType associations
			select: [ :each | each key = LeNamedPageType or: [ each key inheritsFrom: LeNamedPageType ] ])
			sorted: [ :each | each value size ] descending.
	^ namedPageClasses allButFirst
		inject: namedPageClasses first value
		into: [ :acc :each | acc , each value ]
]

{ #category : #'*GtKanban' }
LeDatabase >> pagesByType [
	^ pagesByType
]
