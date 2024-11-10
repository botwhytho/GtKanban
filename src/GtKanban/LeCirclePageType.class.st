Class {
	#name : #LeCirclePageType,
	#superclass : #LePageType,
	#category : #GtKanban
}

{ #category : #initialization }
LeCirclePageType class >> initialize [
	super initialize.
	self leJsonV4MappingFor: LeJsonV4 uniqueInstance newWriter.
	LeDatabasesRegistry defaultLogicalDatabase databases
		do: [ :aDatabase | 
			(aDatabase instVarNamed: #pagesByType)
				at: LeCirclePageType
				ifAbsentPut: [ GtStringContentDictionary new ] ]
]

{ #category : #accesing }
LeCirclePageType class >> leJsonV3Name [

	^ 'circlePage'
]

{ #category : #accesing }
LeCirclePageType class >> leJsonV4Name [

	^ 'circlePage'
]

{ #category : #'as yet unclassified' }
LeCirclePageType >> customPhlowTool [
	^ GtPhlowValuableTool new
		"name: 'Circle';"
		icon: BrGlamorousVectorIcons rustLogo;
		valuable: [ BrFrame new
				matchParent;
				addChild: BlBasicExamples new circle ]
]

{ #category : #'as yet unclassified' }
LeCirclePageType >> databaseKey [
	"Answer the attribute used to index a page of the receiver's type in the database."

	^ self title
]

{ #category : #accesing }
LeCirclePageType >> remoteLinkId [
	"Answer the string to be used to identify the page in a remote link annotation ({{gtPage:...}})"
	<return: #String>

	^ self title
]

{ #category : #'api - testing' }
LeCirclePageType >> saveEmptyPages [
	"Flag whether to save empty pages or not.
	Empty named pages are saved."

	^ true
]

{ #category : #accesing }
LeCirclePageType >> shouldAppearInIndexOrDailyNotes [
	^ true
]

{ #category : #'as yet unclassified' }
LeCirclePageType >> title [
^ 'Test Circle Page3'
]
