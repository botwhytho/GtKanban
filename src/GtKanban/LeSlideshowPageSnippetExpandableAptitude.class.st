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
			handle: [ 
				self newPlusElement
					aptitude: BrIconAptitude;
					background: BrGlamorousColors secondaryHeaderBackgroundColor ]
			content: [
				GtSpotterDropdownButtonStencil new
					valuable: (LeContextMenuSpotterStart new 
						database: widget database);
					extent: [ 800 @ 600 ];
					spotterModelDo: [ :aSpotter |
						"aSpotter hidePreview."
						aSpotter announcer weak
							when: GtSpotterExitAnnouncement
							send: #onSpotterExitAnnouncement:
							to: self ];
					objectActOn: [ :anActOnEvent :aMenuItem :theButton |
						"{anActOnEvent .aMenuItem .theButton} logToNamed: 'Slides'."
						"self snippetBelowRequested:" 
						self widget snippetViewModel snippetModel addSnippetAfterSelf: (aMenuItem asSnippet uid: LeUID new).
						anActOnEvent beActed ];
					spotterElementFor: aButton ]
			containerDo: [ :aMenuContainer | 
				aMenuContainer background: BrGlamorousColors secondaryHeaderBackgroundColor ]) doNotHideWidget.
	^ aButton
]
