Class {
	#name : #LeUnknownUnnamedPageType,
	#superclass : #LeUnnamedPageType,
	#traits : 'TLeUnknownPageType',
	#classTraits : 'TLeUnknownPageType classTrait',
	#category : #'GtKanban-Model'
}

{ #category : #initialization }
LeUnknownUnnamedPageType class >> initialize [
	self flag: #TODO.	"Remove once upstream is merged on superclass"
	super initialize.
	self leJsonV4MappingFor: LeJsonV4 uniqueInstance newWriter.
	self leJsonV4MappingFor: LeJsonV4 uniqueInstance newReader.
	LeDatabasesRegistry defaultLogicalDatabase databases
		do: [ :aDatabase | aDatabase pagesByType at: self ifAbsentPut: [ GtStringContentDictionary new ] ]
]

{ #category : #accesing }
LeUnknownUnnamedPageType class >> leJsonV4Name [

	^ 'unknownUnnamedCustomPage'
]

{ #category : #printing }
LeUnknownUnnamedPageType class >> niceClassName [
	^ 'Unknown Unnamed Custom Page'
]

{ #category : #ui }
LeUnknownUnnamedPageType >> asPreviewElement [
	^ self defaultPhlowTool asElement
]

{ #category : #printing }
LeUnknownUnnamedPageType >> printOn: aStream [
	aStream nextPutAll: 'Unknown Unnamed Custom Page'
]
