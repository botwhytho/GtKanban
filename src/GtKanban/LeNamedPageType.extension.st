Extension { #name : #LeNamedPageType }

{ #category : #'*GtKanban' }
LeNamedPageType class >> leJsonV3AttributeMapping [

	^ super leJsonV3AttributeMapping
		add: #title -> #title;
		in: [ :aMapping | 
			(self defaultSystemPageTypes includes: self)
				ifFalse: [ aMapping add: #pageTypeRepo -> #pageTypeRepo ].
			aMapping ]

]

{ #category : #'*GtKanban' }
LeNamedPageType class >> leJsonV4AttributeMapping [

	^ super leJsonV4AttributeMapping
		add: #title -> #title;
		in: [ :aMapping | 
			(self defaultSystemPageTypes includes: self)
				ifFalse: [ aMapping add: #pageTypeRepo -> #pageTypeRepo ].
			aMapping ]
]

{ #category : #'*GtKanban' }
LeNamedPageType class >> niceClassName [
	^ 'Named Page'
]
