Class {
	#name : #LeCirclePageType,
	#superclass : #LePageType,
	#category : #GtKanban
}

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

{ #category : #'as yet unclassified' }
LeCirclePageType >> title [
^ 'Test Circle Page3'
]
