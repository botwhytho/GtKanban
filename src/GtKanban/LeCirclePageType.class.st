Class {
	#name : #LeCirclePageType,
	#superclass : #LeNamedPageType,
	#category : #GtKanban
}

{ #category : #initialization }
LeCirclePageType class >> initialize [
	self flag: #TODO.	"Remove noce upstream is merged on superclass"
	super initialize.
	self leJsonV4MappingFor: LeJsonV4 uniqueInstance newWriter.
	self leJsonV4MappingFor: LeJsonV4 uniqueInstance newReader.
	LeDatabasesRegistry defaultLogicalDatabase databases
		do: [ :aDatabase | aDatabase pagesByType at: self ifAbsentPut: [ GtStringContentDictionary new ] ]
]

{ #category : #accesing }
LeCirclePageType class >> leJsonV3Name [

	^ 'circlePage'
]

{ #category : #accesing }
LeCirclePageType class >> leJsonV4Name [

	^ 'circlePage'
]

{ #category : #printing }
LeCirclePageType class >> niceClassName [
	^ 'Circle Page'
]

{ #category : #converting }
LeCirclePageType >> asLepiterPagePhlowTool [
	^ GtPhlowCompositeTool new
		name: self page title;
		addTool: (GtPhlowExplicitTool new withIconAptitude
				icon: BrGlamorousVectorIcons gt;
				stencil: [ BrHorizontalPane new
						alignCenter;
						matchParent;
						margin: (BlInsets all: 20);
						geometry: BlCircleGeometry new;
						background: Color red;
						border: (BlBorder paint: (Color blue alpha: 0.5) width: 6);
						addChild: (BrLabel new
								aptitude: BrGlamorousLabelAptitude;
								text: self title);
						when: BlClickEvent
							do: [ :anEvent | anEvent currentTarget phlow spawnObject: 42 ] ]);
		addTool: (GtPhlowTool default object: self);
		addTool: (GtPhlowTool default object: self page)
]

{ #category : #printing }
LeCirclePageType >> printOn: aStream [

	aStream 
		nextPutAll: 'Cirlce Page: ';
		print: title
]
