Class {
	#name : #LeCirclePageType,
	#superclass : #LeNamedPageType,
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
	"Need to create an `icon` slot on `GtPhlowValuableTool` if it doesn't exist."
]

{ #category : #accessing }
LeCirclePageType class >> leJsonV3AttributeMapping [
	^ super leJsonV3AttributeMapping
		add: #title -> #title;
		yourself
]

{ #category : #accesing }
LeCirclePageType class >> leJsonV3Name [

	^ 'circlePage'
]

{ #category : #accessing }
LeCirclePageType class >> leJsonV4AttributeMapping [
	^ super leJsonV4AttributeMapping
		add: #title -> #title;
		yourself
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
