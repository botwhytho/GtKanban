Extension { #name : #LeLocalJsonV4Storage }

{ #category : #'*GtKanban' }
LeLocalJsonV4Storage >> loadFromFile: aFileReference [
	| originalException result |
	result := [ aFileReference
			readStreamDo: [ :stream | self leJsonV4 deserialize: stream ] ]
			on: NeoJSONParseError
			do: [ :ex | 
				originalException := ex.
				nil ].
	originalException
		ifNotNil: [ | corruptFileReference loadError |
			corruptFileReference := (aFileReference withExtension: 'corrupt') nextVersion.
			UIManager default
				inform: 'Lepiter: Unable to load: ' , aFileReference basename , ' in '
						, aFileReference parent fullName , ' due to a JSON parser error'.
			aFileReference resolve renameTo: corruptFileReference basename.
			loadError := LeDBLoadError new.
			loadError properties at: #fileReference put: corruptFileReference.
			loadError
				reason: 'JSON Parse Error';
				originalException: originalException.
			loadError signal ].
	^ result
]
