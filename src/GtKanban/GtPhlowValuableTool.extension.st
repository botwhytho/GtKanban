Extension { #name : #GtPhlowValuableTool }

{ #category : #'*GtKanban' }
GtPhlowValuableTool >> icon [
	^ icon
]

{ #category : #'*GtKanban' }
GtPhlowValuableTool >> icon: anIcon [
	icon := anIcon
]

{ #category : #'*GtKanban' }
GtPhlowValuableTool >> tabLook [
	^ icon
		ifNil: [ BrGlamorousTabSwitcherWithLabelAptitude ]
		ifNotNil: [ BrGlamorousTabSwitcherWithIconAptitude ]
]
