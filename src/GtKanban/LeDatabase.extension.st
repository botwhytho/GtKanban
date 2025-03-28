Extension { #name : #LeDatabase }

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
