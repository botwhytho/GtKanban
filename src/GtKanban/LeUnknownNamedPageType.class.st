Class {
	#name : #LeUnknownNamedPageType,
	#superclass : #LeNamedPageType,
	#instVars : [
		'pageType'
	],
	#category : #'GtKanban-Model'
}

{ #category : #initialization }
LeUnknownNamedPageType class >> initialize [
	self flag: #TODO.	"Remove once upstream is merged on superclass"
	super initialize.
	self leJsonV4MappingFor: LeJsonV4 uniqueInstance newWriter.
	self leJsonV4MappingFor: LeJsonV4 uniqueInstance newReader.
	LeDatabasesRegistry defaultLogicalDatabase databases
		do: [ :aDatabase | aDatabase pagesByType at: self ifAbsentPut: [ GtStringContentDictionary new ] ]
]

{ #category : #accesing }
LeUnknownNamedPageType class >> leJsonV3Name [

	^ 'unknownNamedCustomPage'
]

{ #category : #accesing }
LeUnknownNamedPageType class >> leJsonV4Name [

	^ 'unknownNamedCustomPage'
]

{ #category : #printing }
LeUnknownNamedPageType class >> niceClassName [
	^ 'Unknown Named Custom Page'
]

{ #category : #ui }
LeUnknownNamedPageType >> asPreviewElement [
	^ self defaultPhlowTool asElement
]

{ #category : #accessing }
LeUnknownNamedPageType >> pageType [
	^ pageType
]

{ #category : #accessing }
LeUnknownNamedPageType >> pageType: anObject [
	pageType := anObject
]

{ #category : #printing }
LeUnknownNamedPageType >> printOn: aStream [

	aStream 
		nextPutAll: 'Unknown Named Custom Page: ';
		print: title
]
