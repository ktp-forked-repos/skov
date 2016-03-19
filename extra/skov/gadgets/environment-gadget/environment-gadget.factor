! Copyright (C) 2015-2016 Nicolas Pénet.
USING: accessors arrays combinators combinators.smart kernel
listener locals math memory models namespaces sequences
skov.code skov.execution skov.gadgets skov.gadgets.buttons
skov.gadgets.connection-gadget skov.gadgets.connector-gadget
skov.gadgets.graph-gadget skov.gadgets.node-pile
skov.gadgets.plus-button-pile skov.gadgets.result-gadget
skov.gadgets.vocab-gadget skov.theme skov.utilities ui.commands
ui.gadgets ui.gadgets.borders ui.gadgets.editors
ui.gadgets.packs ui.gadgets.tracks ui.gestures ui.tools.browser
ui.tools.common vocabs.parser ;
IN: skov.gadgets.environment-gadget

{ 700 600 } environment-gadget set-tool-dim

SYMBOL: skov-root
vocab new "●" >>name skov-root set-global

: <help-button> ( -- button )
    [ drop show-browser ] "help" <word-button> "Help ( h )" >>tooltip ;

:: <environment-gadget> ( -- gadget )
    skov-root get-global <model> :> model
    horizontal environment-gadget new-track model >>model
    vertical <track>
      <help-button> f track-add
      model <plus-button-pile> { 0 0 } <border> 1 track-add
    f track-add
    <shelf> 1/2 >>align { 40 0 } >>gap
      model <node-pile> add-gadget
      model <result-gadget> add-gadget
      model <graph-gadget> add-gadget
    { 0 0 } <border> 1 track-add
    model <vocab-gadget> f track-add
    { 10 10 } <filled-border> with-background ;

: make-keyboard-safe ( env quot -- )
    [ world-focus editor? not ] swap smart-when* ; inline

: add-input ( env -- ) [ input add-to-word ] make-keyboard-safe ;
: add-output ( env -- ) [ output add-to-word ] make-keyboard-safe ;
: add-text ( env -- ) [ text add-to-word ] make-keyboard-safe ;
: add-slot ( env -- ) [ slot add-to-tuple ] make-keyboard-safe ;
: add-constructor ( env -- ) [ constructor add-to-word ] make-keyboard-safe ;
: add-destructor ( env -- ) [ destructor add-to-word ] make-keyboard-safe ;
: add-accessor ( env -- ) [ accessor add-to-word ] make-keyboard-safe ;
: add-mutator ( env -- ) [ mutator add-to-word ] make-keyboard-safe ;
: add-word ( env -- ) [ word add-to-word ] make-keyboard-safe ;
: add-vocab ( env -- ) [ vocab add-to-vocab ] make-keyboard-safe ;
: add-word-in-vocab ( env -- ) [ word add-to-vocab ] make-keyboard-safe ;
: add-tuple-in-vocab ( env -- ) [ tuple-class add-to-vocab ] make-keyboard-safe ;

: disconnect-connector-gadget ( env -- )
    [ hand-gadget get-global dup
      [ [ connector-gadget? ] [ connected? ] bi and ] [ control-value disconnect ] smart-when*
      find-env [ ] change-control-value drop
    ] make-keyboard-safe ;

: remove-node-gadget ( env -- )
    [ hand-gadget get-global find-node dup
      [ [ connectors>> [ links>> [ control-value disconnect ] each ] each ]
        [ control-value remove-from-parent ] bi
      ] when* find-env [ ] change-control-value drop
    ] make-keyboard-safe ;

: edit-node-gadget ( env -- )
    [ hand-gadget get-global find-node
      [ f >>name request-focus ] when* drop
    ] make-keyboard-safe ;

: more-inputs ( env -- )
    [ hand-gadget get-global find-node
      [ [ control-value variadic? ]
        [ dup control-value input add-element inputs>> last <connector-gadget> add-gadget drop ] smart-when*
      ] when* drop
    ] make-keyboard-safe ;

: less-inputs ( env -- )
    [ hand-gadget get-global find-node
      [ [ control-value [ variadic? ] [ inputs>> length 2 > ] bi and ]
        [ dup control-value [ but-last ] change-contents drop inputs>> last unparent ] smart-when*
      ] when* drop
    ] make-keyboard-safe ;

: show-result ( env -- )
    [ dup control-value [ word? ] [ dup run-word result>> swap set-control-value ] [ drop ] smart-if* ]
    make-keyboard-safe ;

:: next-nth-word ( env n -- )
    env [ dup control-value word/tuple? [
      [ vocab-control-value [ tuples>> ] [ words>> ] bi append ]
      [ control-value n next-nth ] [ dupd set-control-value ] tri
    ] when drop ] make-keyboard-safe ;

: previous-word ( env -- )  -1 next-nth-word ;
: next-word ( env -- )  +1 next-nth-word ;

: save-skov-image ( env -- )
    [ drop save ] make-keyboard-safe ;

: show-help ( env -- )
    [ hand-gadget get-global find-node
      [ [ control-value factor-name search (browser-window) ] with-interactive-vocabs ]
      [ show-browser ] if* drop
    ] make-keyboard-safe ;

environment-gadget "general" f {
    { T{ key-up f f "w" } add-word }
    { T{ key-up f f "i" } add-input }
    { T{ key-up f f "o" } add-output }
    { T{ key-up f f "t" } add-text }
    { T{ key-up f f "s" } add-slot }
    { T{ key-up f f "c" } add-constructor }
    { T{ key-up f f "d" } add-destructor }
    { T{ key-up f f "a" } add-accessor }
    { T{ key-up f f "m" } add-mutator }
    { T{ key-up f f "v" } add-vocab }
    { T{ key-up f f "n" } add-word-in-vocab }
    { T{ key-up f f "u" } add-tuple-in-vocab }
    { T{ key-up f f "x" } disconnect-connector-gadget }
    { T{ key-up f f "r" } remove-node-gadget }
    { T{ key-up f f "e" } edit-node-gadget }
    { T{ key-up f f "RIGHT" } more-inputs }
    { T{ key-up f f "LEFT" } less-inputs }
    { T{ key-down f { C+ } "s" } save-skov-image }
    { T{ key-up f f "h" } show-help }
    { T{ key-up f f "BACKSPACE" } show-result }
    { T{ key-up f f "UP" } previous-word }
    { T{ key-up f f "DOWN" } next-word }
} define-command-map
