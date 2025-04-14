"
This is an example of a custom page type. It doesn't really do anything, but it is used in tests and helps users understand what methods need to be overriden/created, etc. when creating their own custom page types.

The best approach for creating a new custom page type is to copy {{gtClass:LeExampleCustomPageType}} (this class) in your own package, including all it's methods, then start modifying the below methods accordingly.

- {{gtMethod:LeExampleCustomPageType class>>#initialize}} : In your custom page type class's `initialize` method, you need to 'register' that class on all the databases in the system

- {{gtMethod:LeExampleCustomPageType>>#printOn:}} controls how your class is displayed, should override or you might think a page has been defined with the incorrect page type as it will display the superclass 'Named Page:' string

- {{gtMethod:LeExampleCustomPageType class>>#leJsonV3Name}}: needs a unique name for lepiter JSON serialization

- {{gtMethod:LeExampleCustomPageType class>>#niceClassName}}: this is a 'nice' human readable name of your page type, something like 'Something Page'. This will come up in the global spotter to be able to create a new page of your custom type.

- {{gtMethod:LeExampleCustomPageType class>>#leJsonV3Name}}: needs a unique name for lepiter JSON serialization

- {{gtMethod:LeExampleCustomPageType class>>#leJsonV4Name}}: needs a unique name for lepiter JSON serialization

- {{gtMethod:LeExampleCustomPageType>>#printOn:}} controls how your class is displayed, should override or you might think a page has been defined with the incorrect page type as it will display the superclass 'Named Page:' string
"
Class {
	#name : #LeExampleCustomPageType,
	#superclass : #LeNamedPageType,
	#category : #GtKanban
}

{ #category : #initialization }
LeExampleCustomPageType class >> initialize [
	self flag: #TODO.	"Remove once upstream is merged on superclass"
	super initialize.
	self leJsonV4MappingFor: LeJsonV4 uniqueInstance newWriter.
	self leJsonV4MappingFor: LeJsonV4 uniqueInstance newReader.
	LeDatabasesRegistry defaultLogicalDatabase databases
		do: [ :aDatabase | aDatabase pagesByType at: self ifAbsentPut: [ GtStringContentDictionary new ] ]
]

{ #category : #accesing }
LeExampleCustomPageType class >> leJsonV3Name [

	^ 'exampleCustomPage'
]

{ #category : #accesing }
LeExampleCustomPageType class >> leJsonV4Name [

	^ 'exampleCustomPage'
]

{ #category : #printing }
LeExampleCustomPageType class >> niceClassName [
	^ 'Example Custom Page'
]

{ #category : #converting }
LeExampleCustomPageType >> asLepiterPagePhlowTool [
	^ GtPhlowCompositeTool new
		name: self page title;
		addTool: (GtPhlowExplicitTool new withIconAptitude
				icon: BrGlamorousVectorIcons gt;
				stencil: [ BrFrame new matchParent addChild: ((BrGlamorousVectorIcons perform: #largeGt) create
						asScalableElement);
						when: BlClickEvent
							do: [ :anEvent | anEvent currentTarget phlow spawnObject: 42 ] ]);
		addTool: (GtPhlowTool default object: self);
		addTool: (GtPhlowTool default object: self page)
]

{ #category : #printing }
LeExampleCustomPageType >> printOn: aStream [

	aStream 
		nextPutAll: 'Example Custom Page: ';
		print: title
]
