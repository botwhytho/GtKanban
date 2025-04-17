Extension { #name : #LeUnnamedPageType }

{ #category : #'*GtKanban' }
LeUnnamedPageType class >> leJsonV4AttributeMapping [
	^ super leJsonV4AttributeMapping
		add: #defaultTitle -> #defaultTitle;
		in: [ :aMapping | 
			(self defaultSystemPageTypes includes: self)
				ifFalse: [ aMapping add: #pageTypeRepo -> #pageTypeRepo ].
			aMapping ]
]
