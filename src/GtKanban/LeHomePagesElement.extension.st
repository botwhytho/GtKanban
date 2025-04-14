Extension { #name : #LeHomePagesElement }

{ #category : #'*GtKanban' }
LeHomePagesElement >> onPageClick: aLePageViewModel [
	aLePageViewModel pageModel gtSpotterActDefaultFrom: self
]
