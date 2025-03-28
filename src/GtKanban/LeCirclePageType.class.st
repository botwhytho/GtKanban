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
LeCirclePageType >> asLepiterPagePhlowTool [
	^ GtPhlowCompositeTool new
		addTool: (GtPhlowExplicitTool new withIconAptitude
				icon: BrGlamorousVectorIcons rustLogo;
				stencil: [ BrHorizontalPane new
						alignCenter;
						matchParent;
						geometry: BlCircleGeometry new;
						background: Color red;
						border: (BlBorder paint: (Color blue alpha: 0.5) width: 6);
						addChild: (BrLabel new
								aptitude: BrGlamorousLabelAptitude;
								text: self title);
						when: BlClickEvent
							do: [ :anEvent | anEvent currentTarget phlow spawnObject: 42 ] ]);
		addTool: (GtPhlowTool default object: self page)
]

{ #category : #'as yet unclassified' }
LeCirclePageType >> customPhlowTool [
	^ GtPhlowExplicitTool new withIconAptitude
		icon: BrGlamorousVectorIcons rustLogo;
		stencil: [ BrHorizontalPane new
				alignCenter;
				matchParent;
				geometry: BlCircleGeometry new;
				background: Color red;
				border: (BlBorder paint: (Color blue alpha: 0.5) width: 6);
				addChild: (BrLabel new
						aptitude: BrGlamorousLabelAptitude;
						text: self title);
				when: BlClickEvent
					do: [ :anEvent | anEvent currentTarget phlow spawnObject: 42 ] ]
]
