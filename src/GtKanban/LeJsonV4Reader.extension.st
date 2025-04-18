Extension { #name : #LeJsonV4Reader }

{ #category : #'*GtKanban' }
LeJsonV4Reader >> object: type from: map [
	^ typeMap
		at: type
		ifPresent: [ :cls | cls leFromJsonV4Dictionary: map ]
		ifAbsent: [ [ self unknownSnippetTypeFrom: map ]
				on: NeoJSONParseError
				do: [ self unknownPageTypeFrom: map ] ]
]

{ #category : #'*GtKanban' }
LeJsonV4Reader >> unknownPageTypeFrom: map [
	"If the supplied map looks like a page type, answer an unknown page, otherwise raise an exception"

	| class |
	"map is considered a page type if it has all the keys of LePageType"
	((LePageType leJsonV4AttributeMapping collect: #key as: GtStringContentSet)
		difference: map keys) ifNotEmpty: [ self error: 'Unknown page type' ].

	class := map
			at: #title
			ifPresent: [ :aTitle | LeUnknownNamedPageType ]
			ifAbsent: [ LeUnknownUnnamedPageType ].

	^ class leFromJsonV4Dictionary: map
]

{ #category : #'*GtKanban' }
LeJsonV4Reader >> unknownSnippetTypeFrom: map [
	"If the supplied map looks like a snippet, answer an unknown snippet, otherwise raise an exception"

	| children class snippet type |
	"map is considered a snippet if it has all the keys of LeBlock"
	((LeSnippet leJsonV4AttributeMapping collect: #key as: GtStringContentSet)
		difference: map keys) ifNotEmpty: [ self error: 'Unknown snippet type' ].

	children := map at: 'children'.
	map at: 'children' put: LeSnippets new.
	type := map at: #__type.
	class := LeUnknownSnippet withAllSubclasses
			detect: [ :each | each leJsonV4Name = type ]
			ifNone: [ LeUnknownSnippet ].
	snippet := class
			jsonString: (String
					streamContents: [ :stream | 
						LeJsonV4 uniqueInstance
							serialize: map
							on: stream
							prettyPrint: true ]).
	snippet
		children: children;
		uid: (map at: 'uid'). 
	map at: 'editTime' ifPresent: [ :editTime | snippet editTime: editTime ].
	^ snippet
]
