Class {
	#name : #LeSlideshowPageSnippetExpandableAptitude,
	#superclass : #LeSnippetExpandableAptitude,
	#category : #'GtKanban-Looks'
}

{ #category : #'instace creation' }
LeSlideshowPageSnippetExpandableAptitude >> newAddSnippetDropdown [
	<return: #BlElement>
	| aButton |
	aButton := self newPlusElement.
	aButton
		addAptitude: (BrGlamorousWithExplicitDropdownAptitude
				handle: [ self newPlusElement
						aptitude: BrIconAptitude;
						background: BrGlamorousColors secondaryHeaderBackgroundColor ]
				content: [ GtSpotterDropdownButtonStencil new
						valuable: LeSlideshowPageSpotterStart new;
						extent: [ 800 @ 600 ];
						spotterModelDo: [ :aSpotter | 
							aSpotter announcer weak
								when: GtSpotterExitAnnouncement
								send: #onSpotterExitAnnouncement:
								to: self ];
						objectActOn: [ :anActOnEvent :aMenuItem :theButton | 
							| elementSnippet |
							elementSnippet := LeElementSnippet new
									uid: LeUID new;
									code: (self rewriteMethod: aMenuItem key).
							self widget snippetViewModel snippetModel
								addSnippetAfterSelf: elementSnippet.
							anActOnEvent beActed ];
						spotterElementFor: aButton ]
				containerDo: [ :aMenuContainer | aMenuContainer background: BrGlamorousColors secondaryHeaderBackgroundColor ])
				doNotHideWidget.
	^ aButton
]

{ #category : #converting }
LeSlideshowPageSnippetExpandableAptitude >> rewriteMethod: aMethod [
	| anAst slideText |
	anAst := aMethod ast veryDeepCopy.
	anAst body
		addNodeFirst: (RBParser
				parseExpression: '| aSlide| aSlide := GtProtoLiveSlide new.
	aDemo := DemoSlideshow new.').
	slideText := anAst
			pragmaNamed: #text:
			ifPresent: [ :aPragma | aPragma arguments first value ]
			ifAbsent: [ nil ].
	slideText
		ifNotNil: [ anAst body
				addNodeFirst: (RBParser
						parseExpression: '"' , anAst method methodClass name , ' >> ' , '#' , anAst method selector
								, ' | ' , slideText , '"') ].
	anAst removePragmaNamed: #text:.
	anAst removePragmaNamed: #gtSlide.
	anAst allChildren
		select: [ :aNode | (aNode isKindOf: RBVariableNode) and: [ aNode isSelfVariable ] ]
		thenDo: [ :aNode | anAst replaceNode: aNode withNode: (RBParser parseExpression: 'aDemo') ].
	^ (((anAst newSource lines allButFirst
		reject: [ :each | (each includesSubstring: 'setPriority;') or: [ each includesSubstring: '	.	"' ] ])
		joinUsing: String cr) copyReplaceAll: 'self' with: 'aDemo')
		copyReplaceAll: '^'
		with: ''
]
