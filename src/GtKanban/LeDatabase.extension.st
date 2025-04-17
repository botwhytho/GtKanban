Extension { #name : #LeDatabase }

{ #category : #'*GtKanban' }
LeDatabase >> detachPageButKeepFile: aPage [

	"I detach the page from the give database. The page could remain deleted or be later added to
	another database."

	self assertNotReadOnly.

	(pagesByType at: aPage pageTypeClass)
		removeKey: aPage databaseKey
		ifAbsent: [ "do nothing" ].
	pagesByUuid removeKey: aPage uid ifAbsent: [ "do nothing" ].

	aPage removedFromDatabase: self.
	self updateSortedCollectionsDueToRemoval: aPage.
]

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
