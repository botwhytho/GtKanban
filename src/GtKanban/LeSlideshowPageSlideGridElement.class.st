Class {
	#name : #LeSlideshowPageSlideGridElement,
	#superclass : #LeSlideshowPageSlideElement,
	#instVars : [
		'reorderingHandler'
	],
	#category : #'GtKanban-UI'
}

{ #category : #initialization }
LeSlideshowPageSlideGridElement >> initialize [
	| parentTool |
	super initialize.

	parentTool := self
			allParentsDetect: [ :each | each isKindOf: LeSlideshowPageElement ]
			ifFound: #yourself
			ifNone: [ nil ].
	self
		when: BlMouseLeaveEvent
		do: [ :anEvent | 
			anEvent consumed: true.
			self hasFocus ifTrue: [ self loseFocus ] ].
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
					addEventHandler: self reorderingHandler ]
]

{ #category : #accessing }
LeSlideshowPageSlideGridElement >> reorderingHandler [
	^ reorderingHandler
		ifNil: [ reorderingHandler := GtSlideReorderingHandler new page: self snippet page ]
]
