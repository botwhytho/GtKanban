"
This is an example of a custom page type. It doesn't really do anything, but it is used in tests and helps users understand what methods need to be overriden/created, etc. when creating their own custom page types.

The best approach for creating a new custom page type is to copy {{gtClass:LeExampleCustomPageType}} (this class) in your own package, including all it's methods, then start modifying the below methods accordingly.

- {{gtMethod:LeExampleCustomPageType class>>#initialize}} : In your custom page type class's `initialize` method, you need to 'register' that class on all the databases in the system. This will automatically get done in the `super initialize` call but you **DO** need to define an initialize class method and make the super call, this will **NOT** happen automatically. When you are testing locally, before code is loaded through Metacello or other means, you will need to evaluate this method manually for your class to be able to be recognized by Lepiter databases and serializers/deserializers.

- {{gtMethod:LeExampleCustomPageType>>#printOn:}} controls how your class is displayed, should override or you might think a page has been defined with the incorrect page type as it will display the superclass 'Named Page:' string

- {{gtMethod:LeExampleCustomPageType class>>#niceClassName}}: this is a 'nice' human readable name of your page type, something like 'Something Page'. This will come up in the global spotter to be able to create a new page of your custom type.

- {{gtMethod:LeExampleCustomPageType class>>#leJsonV4Name}}: needs a unique name for lepiter JSON serialization

- {{gtMethod:LeExampleCustomPageType>>#printOn:}} controls how your class is displayed, should override or you might think a page has been defined with the incorrect page type as it will display the superclass 'Named Page:' string.

- {{gtMethod:LeExampleCustomPageType>>samplePage}} should be overriden and have an example page to potentially help users understand how to use the custom page type.

- Finally,  {{gtMethod:LeExampleCustomPageType>>defaultPhlowTool}}:  can be overriden to display the custom page type in a different graphical format. Custom page types will have a 'composite' tool with the default tool as the first/main tool. Two different inspectors will also show up, one for the page type class, and one for the Lepiter page itself. One can add custom views on the page type that will not appear on arbitrary Lepiter pages, only pages of the specific page type.

- If one wants to completely override the phlow/composite tools displayed and not include the page type and page inspectors, or do any other more advanced custom logic, one can instead override {{gtMethod:LePageType>>asLepiterPagePhlowTool}} on their own class for added flexibility.
"
Class {
	#name : #LeExampleCustomPageType,
	#superclass : #LeNamedPageType,
	#instVars : [
		'theAnswer'
	],
	#category : #'GtKanban-Model'
}

{ #category : #initialization }
LeExampleCustomPageType class >> initialize [
	super initialize.
]

{ #category : #'as yet unclassified' }
LeExampleCustomPageType class >> leJsonV4AttributeMapping [

	^ super leJsonV4AttributeMapping
		add: #theAnswer -> #theAnswer;
		yourself
]

{ #category : #accesing }
LeExampleCustomPageType class >> leJsonV4Name [

	^ 'exampleCustomPage'
]

{ #category : #printing }
LeExampleCustomPageType class >> niceClassName [
	^ 'Example Custom Page'
]

{ #category : #example }
LeExampleCustomPageType class >> samplePage [
	| page |
	page := LePage new.
	page
		type: (LeExampleCustomPageType new
				title: 'Testing';
				page: page;
				theAnswer: 42).
	^ page
]

{ #category : #'ui\t' }
LeExampleCustomPageType >> asPreviewElement [
	^ self defaultPhlowTool asElement
]

{ #category : #converting }
LeExampleCustomPageType >> defaultPhlowTool [
	^ GtPhlowExplicitTool new withIconAptitude
		name: self page title;
		icon: BrGlamorousVectorIcons gt;
		stencil: [ BrFrame new matchParent
				addChild: (BrGlamorousVectorIcons perform: #largeGt) create asScalableElement;
				when: BlDoubleClickEvent
					do: [ :anEvent | anEvent currentTarget phlow spawnObject: 42 ] ]
]

{ #category : #accessing }
LeExampleCustomPageType >> pageTypeRepo [
	^ pageTypeRepo ifNil: [ pageTypeRepo := 'https://github.com/feenkcom/lepiter' ]
]

{ #category : #printing }
LeExampleCustomPageType >> printOn: aStream [

	aStream 
		nextPutAll: 'Example Custom Page: ';
		print: title
]

{ #category : #example }
LeExampleCustomPageType >> samplePage [
	<gtExample>
	| aPage |
	aPage := LePage new.
	aPage
		type: (LeExampleCustomPageType new
				title: 'Testing';
				page: aPage).
	^ aPage
]

{ #category : #accessing }
LeExampleCustomPageType >> theAnswer [
	^ theAnswer
]

{ #category : #accessing }
LeExampleCustomPageType >> theAnswer: anObject [
	theAnswer := anObject
]
