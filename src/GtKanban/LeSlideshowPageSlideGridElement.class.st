Class {
	#name : #LeSlideshowPageSlideGridElement,
	#superclass : #LeSlideshowPageSlideElement,
	#instVars : [
		'reorderingHandler',
		'parentTool'
	],
	#category : #'GtKanban-UI'
}

{ #category : #initialization }
LeSlideshowPageSlideGridElement >> initialize [
	super initialize.


	self
		vFitContent;
		hMatchParent;
		when: BlMouseLeaveEvent
			do: [ :anEvent | 
				anEvent consumed: true.
				self hasFocus ifTrue: [ self loseFocus ] ];
		when: BlElementAddedToSceneGraphEvent
			do: [ :anEvent | 
				anEvent consumed: true.
				parentTool
					ifNil: [ parentTool := self
								allParentsDetect: [ :each | each isKindOf: LeSlideshowPageElement ]
								ifFound: #yourself
								ifNone: [ nil ].
						parentTool weak
							when: GtSlidesGridShowMoreDetailEvent
								do: [ :anAnnouncement | 
									self
										allowChildrenMouseEvents;
										removeEventHandler: self reorderingHandler ];
							when: GtSlidesGridShowLessDetailEvent
								do: [ :anAnnouncement | 
									self
										preventChildrenMouseEvents;
										addEventHandler: self reorderingHandler ] ] ]
]

{ #category : #accessing }
LeSlideshowPageSlideGridElement >> reorderingHandler [
	^ reorderingHandler
		ifNil: [ reorderingHandler := GtSlideReorderingHandler new page: self snippet page ]
]
