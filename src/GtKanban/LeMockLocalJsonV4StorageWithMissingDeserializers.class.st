Class {
	#name : #LeMockLocalJsonV4StorageWithMissingDeserializers,
	#superclass : #LeLocalJsonV4Storage,
	#instVars : [
		'removeDeserializers'
	],
	#category : #'GtKanban-LocalJSON-Store'
}

{ #category : #loading }
LeMockLocalJsonV4StorageWithMissingDeserializers >> loadFromFile: aFileReference [
	| aReader originalException result |
	aReader := LeJsonV4 new newReader.
	self removeDeserializers
		do: [ :each | 
			aReader mappings removeKey: each.
			(aReader instVarNamed: #typeMap) removeKey: each leJsonV4Name ].
	result := [ aFileReference
			readStreamDo: [ :aStream | 
				| object |
				object := aReader
						on: aStream;
						next.	"If the deserialised object is a Dictionary, the __schema should be removed"
				object isDictionary ifTrue: [ object removeKey: '__schema' ifAbsent: [  ] ].
				object ] ]
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

{ #category : #accessing }
LeMockLocalJsonV4StorageWithMissingDeserializers >> removeDeserializers [
	^ removeDeserializers
]

{ #category : #accessing }
LeMockLocalJsonV4StorageWithMissingDeserializers >> removeDeserializers: aCollection [
	removeDeserializers := aCollection
]
