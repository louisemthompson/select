
Object subclass: #Select.


Select subclass: AnySelect [

  end [

  " Properly follows the algorithm for the 'end' variant of
  Select. "

    | thenBlocks condBlocks trueCondBlocks |

    condBlocks := super guardBlocks.
    thenBlocks := super thenBlocks.
    trueCondBlocks := OrderedCollection new.

    "checks if end call has been previously made"
    super conditions.

    "finds all true condition blocks"
    1 to: thenBlocks size do: [:i |
      (super evaluate: (condBlocks at: i)) ifTrue:[
        trueCondBlocks add: i
      ]
    ].

    "evaluate 'any' true condition block"
    trueCondBlocks size = 0 ifFalse:[
      (thenBlocks at: (trueCondBlocks at: (trueCondBlocks size))) value
    ]
    "if no true condition block, evaluate else statement if exists"
    ifTrue:[
        super elseBlock = nil ifFalse:[
          super elseBlock value
        ]
    ]
  ]
]

Select subclass: FirstSelect [

  end [
  " Properly follows the algorithm for the 'first' variant of
  Select. "

    | condBlocks thenBlocks |

    condBlocks := super guardBlocks.
    thenBlocks := super thenBlocks.

    "checks if end call has been previously made"
    super conditions.

    "finds first true condition block and evaluates then statement"
    1 to: thenBlocks size do: [:i |
      (super evaluate: (condBlocks at: i)) ifTrue:[
        (thenBlocks at: i) value.
        ^self
      ]
    ].

    "if no true condition, evaluates else statement if exists"
    super elseBlock = nil ifFalse:[
      super elseBlock value
    ]
  ]
]

Select subclass: AllSelect [

  end [
  " Properly follows the algorithm for the 'all' variant of
  Select. "


    | thenBlocks condBlocks trueCondBlock |

    condBlocks := super guardBlocks.
    thenBlocks := super thenBlocks.
    trueCondBlock := nil.

    "checks if end call has been previously made"
    super conditions.

    "finds all true condition blocks and evaluates then statement"
    1 to: thenBlocks size do: [:i |
      (super evaluate: (condBlocks at: i)) ifTrue:[
        trueCondBlock := 1.
        (thenBlocks at: i) value
      ]
    ].

    "if no true condition block, evaluates else statement if exists"
    trueCondBlock = nil ifTrue:[
        super elseBlock = nil ifFalse:[
          super elseBlock value
        ]
    ]
  ]
]

Select subclass: ExclusiveSelect [

  end [
  " Properly follows the algorithm for the 'exclusive' variant of
  Select. "

    | thenBlocks condBlocks trueCondBlocks |

    condBlocks := super guardBlocks.
    thenBlocks := super thenBlocks.
    trueCondBlocks := OrderedCollection new.

    "checks if end call has been previously made"
    super conditions.

    "finds all true condition blocks"
    1 to: thenBlocks size do: [:i |
      (super evaluate: (condBlocks at: i)) ifTrue:[
        trueCondBlocks add: i
      ]
    ].

    "if only one true condition block, evaluate then statement"
    trueCondBlocks size = 1 ifTrue:[
        (thenBlocks at: (trueCondBlocks at: 1)) value.
        ^self
    ].

    "checks if more than one true condition block and throws error"
    trueCondBlocks size > 1 ifTrue: [
      self error: '"exclusive" variant can only have one true condition block'
    ].

    "if no true condition block checks and evaluates else statement if exists,
     throws error if it does not"
    super elseBlock = nil ifFalse: [
      super elseBlock value
    ] ifTrue: [
        self error: '"exclusive" variant must have an else: statement if no
                     condition blocks are true'
    ]
  ]
]

Select class extend [

  "Variants of Select class:"
  all [ |r| r := AllSelect new. r init. ^r ]
  first [ |r| r := FirstSelect new. r init. ^r ]
  any [ |r| r := AnySelect new. r init. ^r ]
  exclusive [ |r| r := ExclusiveSelect new. r init. ^r ]

]

Select instanceVariableNames: 'guardBlocks thenBlocks elseBlock switchItem
                               caseBlocks endCall'.
Select extend [
  "Initialization of variables in Select class"
  init [guardBlocks := OrderedCollection new.
        thenBlocks := OrderedCollection new.
        elseBlock := nil.
        switchItem := nil.
        endCall := nil]

  "Functions to return Select variables (unused except elseBlock)"
  guardBlocks [^guardBlocks]
  thenBlocks [^thenBlocks]
  elseBlock [^elseBlock]
  switchItem [^switchItem]

  "if:then: message, checks if valid use of message"
  if: aGuardBlock then: aThenBlock [
    "Check if initialiation of a switch statement has occured"
    switchItem = nil ifFalse: [
      self error:'if:then: message cannot occur within a switch statement'
    ].
    "Check if else: message has occurred"
    elseBlock = nil ifFalse: [
      self error: 'if:then message cannot follow an else: message'
    ].

    "Saves guard and then blocks"
    guardBlocks add: aGuardBlock.
    thenBlocks add: aThenBlock
  ]

  "else: message, checks if valid use of message"
  else: anElseBlock [
    "checks if else: message follows some conditional block"

    guardBlocks size = 0 ifTrue: [
      self error: 'else: must follow an if:then:'
    ].

    "checks if elseBlock has been previously defined"
    elseBlock = nil ifTrue: [elseBlock := anElseBlock]
                    ifFalse: [self error: 'Cannot have more than one elseBlock']
  ]

  "switch: message initializes switch conditional statement,
   checks if valid use of switch"
  switch: item [
    "checks if existing if:then: statement"
    guardBlocks size > 0 ifTrue: [
      self error: 'cannot have a initiate a switch after guards'
    ].
    "checks if existing switch statement"
    switchItem = nil ifFalse: [
      self error: 'cannot have more than one switch: call'
    ].

    "Saves switch item"
    switchItem := item
  ]

  "case:then: message, checks if valid usage"
  case: aCaseBlock then: aThenBlock [
    "checks if switch statement has been initialized"
    switchItem = nil ifTrue: [
      self error: 'must have a switch statement before a case:then:'
    ].

    "Saves case block information"
    guardBlocks add: aCaseBlock.
    thenBlocks add: aThenBlock
  ]

  "Required contitions at beginning of each end call"
  conditions [
    "cannot have more than one end call"
    endCall = nil ifFalse: [self error: 'cannot have more than one end call'].
    endCall := 1.
  ]

  "Evaluates aCondBlock by whether its a switch or if:then: statement"
  evaluate: aCondBlock [

    switchItem = nil ifTrue:[
      ^aCondBlock value
    ] ifFalse: [
      ^(aCondBlock value) includes: switchItem
    ]
  ]
]
