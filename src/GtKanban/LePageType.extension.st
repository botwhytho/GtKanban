Extension { #name : #LePageType }

{ #category : #'*GtKanban' }
LePageType >> asLepiterPagePhlowTool [
	^ self page asLepiterPagePhlowTool
]

{ #category : #'*GtKanban' }
LePageType class >> initialize [
	super initialize.
	self = LePageType
		ifFalse: [ self leJsonV4MappingFor: LeJsonV4 uniqueInstance newWriter.
			LeDatabasesRegistry defaultLogicalDatabase databases
				do: [ :aDatabase | aDatabase pagesByType at: self ifAbsentPut: [ GtStringContentDictionary new ] ] ]
]
