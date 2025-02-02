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
	^ GtPhlowExplicitTool new
		withIconAptitude
		"name: 'Circle';"
		icon: BrGlamorousVectorIcons rustLogo;
		stencil: [ BrFrame new
				matchParent;
				addChild: BlBasicExamples new circle ]
]
