/**
 * Monaco Editor Extension for Harbour Language
 */

function registerHarbour(monaco) {
    // 1. Register the language ID
    monaco.languages.register({ id: 'harbour' });

    // 1b. Language Configuration (Indentation, auto-closing, etc.)
    monaco.languages.setLanguageConfiguration('harbour', {
        comments: {
            lineComment: '//',
            blockComment: ['/*', '*/'],
        },
        brackets: [
            ['{', '}'],
            ['[', ']'],
            ['(', ')'],
        ],
        autoClosingPairs: [
            { open: '{', close: '}' },
            { open: '[', close: ']' },
            { open: '(', close: ')' },
            { open: '"', close: '"' },
            { open: "'", close: "'" },
        ],
        surroundingPairs: [
            { open: '{', close: '}' },
            { open: '[', close: ']' },
            { open: '(', close: ')' },
            { open: '"', close: '"' },
            { open: "'", close: "'" },
        ],
        indentationRules: {
            increaseIndentPattern: /^\s*(function|procedure|method|class|if|else|elseif|while|for|for each|do case|case|otherwise|switch|try|catch|begin sequence|begin|static function|static procedure|dynamic function)\b/i,
            decreaseIndentPattern: /^\s*(else|elseif|endif|next|enddo|endcase|endclass|end|catch|finally|next)\b/i
        }
    });

    // 2. Define the Tokenizer (Syntax Highlighting)
    monaco.languages.setMonarchTokensProvider('harbour', {
        keywords: [
            'function', 'return', 'local', 'static', 'if', 'else', 'elseif', 'endif', 
            'while', 'enddo', 'for', 'next', 'do', 'case', 'endcase', 'switch', 
            'function', 'procedure', 'method', 'class', 'endclass', 'return',
            'if', 'else', 'elseif', 'endif', 'while', 'enddo', 'for', 'next', 'each',
            'do', 'case', 'endcase', 'otherwise', 'switch', 'exit', 'loop',
            'try', 'catch', 'finally', 'end', 'begin', 'sequence', 'external',
            'request', 'field', 'memvar', 'public', 'private', 'static', 'local',
            'init', 'exit', 'parameters', 'announce', 'request', 'using', 'with'
        ],

        functions: [
            // Harbour standard
            'dbusearea', 'dbselectarea', 'dbclosearea', 'dbseek', 'dbskip', 'dberase',
            'eof', 'found', 'bof', 'recno', 'reccount', 'alias', 'indexord',
            'alltrim', 'ltrim', 'rtrim', 'upper', 'lower', 'substr', 'at', 'rat',
            'empty', 'len', 'val', 'str', 'dtoc', 'ctod', 'dtos', 'stod',
            'hb_memoread', 'hb_memowrit', 'hb_eol', 'hb_ps', 'hb_dirbase',
            'valtype', 'type', 'eval', 'scriptcallmethod', 'scriptcallmethodarg',
            // FiveMac specific
            'msginfo', 'msgyesno', 'msgalert', 'msgstop', 'respath', 'apppath',
            'sysrefresh', 'nslog', 'define', 'activate', 'window', 'dialog'
        ],

        operators: [
            '+', '-', '*', '/', '%', '==', '!=', '<', '>', '<=', '>=', '&&', '||', 
            '!', ':=', '=>', '+=', '-=', '*=', '/=', '^', '++', '--'
        ],
        brackets: [
            { open: '{', close: '}', token: 'delimiter.curly' },
            { open: '[', close: ']', token: 'delimiter.square' },
            { open: '(', close: ')', token: 'delimiter.parenthesis' }
        ],
        tokenizer: {
            root: [
                // Identifiers, keywords and functions
                [/[a-zA-Z_]\w*/, {
                    cases: {
                        '@keywords': 'keyword',
                        '@functions': 'type.identifier',
                        '@default': 'identifier'
                    }
                }],
                // Whitespace
                { include: '@whitespace' },
                
                // Brackets
                [/[{}()\[\]]/, '@brackets'],

                // Symbols
                [/[<>][!=\?]?|[*\/%+\-!^=]|:=|=>/, 'operator'],
                [/[0-9]+/, 'number'],
                [/[;,.]/, 'delimiter'],

                // Strings
                [/"([^"\\]|\\.)*"/, 'string'],
                [/'([^'\\]|\\.)*'/, 'string'],
            ],
            whitespace: [
                [/[ \t\r\n]+/, 'white'],
                [/\/\*/, 'comment', '@comment'],
                [/\/\/.*$/, 'comment'],
                [/^\s*\*.*$/, 'comment'],
                [/\&\&.*$/, 'comment'],
            ],
            comment: [
                [/[^\/*]+/, 'comment'],
                [/\*\//, 'comment', '@pop'],
                [/[\/*]/, 'comment']
            ]
        }
    });

    // 3. Define Folding Rules (Stack-based for nested blocks)
    monaco.languages.registerFoldingRangeProvider('harbour', {
        provideFoldingRanges: function(model, context, token) {
            const ranges = [];
            const lines = model.getLineCount();
            const stack = [];
            let lastFunctionLine = -1;

            // Bloques con fin explícito
            const startPatterns = /^\s*(if|while|for|do case|switch|begin sequence|begin|try|class)\b/i;
            const endPatterns = /^\s*(endif|next|enddo|endcase|end|endclass|catch|finally)\b/i;
            
            // Bloques que terminan cuando empieza otro igual (Funciones)
            const functionPatterns = /^\s*(static\s+)?(function|procedure|method)\b/i;

            for (let i = 1; i <= lines; i++) {
                const content = model.getLineContent(i).trim();
                if (!content) continue;

                // 1. Manejo de Funciones/Procedimientos (Cierran la anterior)
                if (content.match(functionPatterns)) {
                    if (lastFunctionLine !== -1) {
                        ranges.push({
                            start: lastFunctionLine,
                            end: i - 1,
                            kind: monaco.languages.FoldingRangeKind.Region
                        });
                    }
                    lastFunctionLine = i;
                }

                // 2. Manejo de bloques anidables (IF, WHILE...)
                if (content.match(startPatterns)) {
                    stack.push(i);
                } else if (content.match(endPatterns)) {
                    if (stack.length > 0) {
                        const start = stack.pop();
                        if (start < i) {
                            ranges.push({
                                start: start,
                                end: i,
                                kind: monaco.languages.FoldingRangeKind.Region
                            });
                        }
                    }
                }
            }

            // Cerrar la última función al final del archivo
            if (lastFunctionLine !== -1 && lastFunctionLine < lines) {
                ranges.push({
                    start: lastFunctionLine,
                    end: lines,
                    kind: monaco.languages.FoldingRangeKind.Region
                });
            }

            return ranges;
        }
    });

    // 4. Define IntelliSense (Suggestions)
    monaco.languages.registerCompletionItemProvider('harbour', {
        provideCompletionItems: function(model, position) {
            const suggestions = [
                {
                    label: 'FUNCTION',
                    kind: monaco.languages.CompletionItemKind.Keyword,
                    insertText: 'FUNCTION ${1:Name}()\n\t$0\nRETURN NIL',
                    insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
                    detail: 'Define a function'
                },
                {
                    label: 'IF',
                    kind: monaco.languages.CompletionItemKind.Keyword,
                    insertText: 'IF ${1:condition}\n\t$0\nENDIF',
                    insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
                    detail: 'Conditional block'
                },
                {
                   label: 'WHILE',
                   kind: monaco.languages.CompletionItemKind.Keyword,
                   insertText: 'WHILE ${1:condition}\n\t$0\nENDDO',
                   insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
                   detail: 'While loop'
                },
                {
                   label: 'FOR',
                   kind: monaco.languages.CompletionItemKind.Keyword,
                   insertText: 'FOR ${1:n} := 1 TO ${2:limit}\n\t$0\nNEXT',
                   insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
                   detail: 'For loop'
                },
                {
                   label: 'TRY',
                   kind: monaco.languages.CompletionItemKind.Keyword,
                   insertText: 'TRY\n\t$1\nCATCH ${2:oErr}\n\t$0\nEND',
                   insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
                   detail: 'Error handling block'
                },
                {
                   label: 'METHOD',
                   kind: monaco.languages.CompletionItemKind.Keyword,
                   insertText: 'METHOD ${1:Name}() CLASS ${2:ClassName}\n\t$0',
                   insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
                   detail: 'Class method definition'
                },
                {
                   label: 'CLASS',
                   kind: monaco.languages.CompletionItemKind.Keyword,
                   insertText: 'CLASS ${1:Name} FROM ${2:Parent}\n\tDATA $3\n\tMETHOD $4\nENDCLASS',
                   insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
                   detail: 'Class definition'
                },
                {
                   label: 'DO CASE',
                   kind: monaco.languages.CompletionItemKind.Keyword,
                   insertText: 'DO CASE\n\tCASE ${1:condition}\n\t\t$0\n\tOTHERWISE\nENDCASE',
                   insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
                   detail: 'Case selection block'
                },
                { label: 'LOCAL', kind: monaco.languages.CompletionItemKind.Keyword, insertText: 'LOCAL ' },
                { label: 'STATIC', kind: monaco.languages.CompletionItemKind.Keyword, insertText: 'STATIC ' },
                { label: 'RETURN', kind: monaco.languages.CompletionItemKind.Keyword, insertText: 'RETURN ' },
                { label: 'MSGINFO', kind: monaco.languages.CompletionItemKind.Function, insertText: 'MsgInfo( ${1:cText} )', insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet },
                { label: 'HB_MEMOREAD', kind: monaco.languages.CompletionItemKind.Function, insertText: 'hb_MemoRead( ${1:cFile} )', insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet }
            ];
            return { suggestions: suggestions };
        }
    });

    // 5. Define Hover Support (Documentation on mouse over)
    monaco.languages.registerHoverProvider('harbour', {
        provideHover: function (model, position) {
            const word = model.getWordAtPosition(position);
            if (!word) return null;

            const hovers = {
                'msginfo': '**MsgInfo( cMessage, [cTitle] )**\n\nMuestra un diálogo nativo de información en macOS.',
                'msgyesno': '**MsgYesNo( cQuestion, [cTitle] )**\n\nMuestra un diálogo con botones Sí/No. Retorna .T. si se pulsa Sí.',
                'dbusearea': '**dbUseArea( [lNewArea], [cDriver], [cPath], [cAlias], [lShared], [lReadOnly] )**\n\nAbre una base de datos en un área de trabajo.',
                'hb_memoread': '**hb_MemoRead( cFileName )**\n\nLee el contenido de un archivo de texto en una cadena de caracteres.',
                'if': '**IF <lCondition>**\n\nBloque condicional básico. Debe cerrarse con ENDIF.',
                'while': '**WHILE <lCondition>**\n\nBucle que se ejecuta mientras la condición sea verdadera. Se cierra con ENDDO.'
            };

            const cleanWord = word.word.toLowerCase();
            if (hovers[cleanWord]) {
                return {
                    range: new monaco.Range(position.lineNumber, word.startColumn, position.lineNumber, word.endColumn),
                    contents: [
                        { value: '### Harbour Help' },
                        { value: hovers[cleanWord] }
                    ]
                };
            }
            return null;
        }
    });

    // 6. Define Outline / Document Symbols (Cmd+Shift+O)
    monaco.languages.registerDocumentSymbolProvider('harbour', {
        provideDocumentSymbols: function(model, token) {
            const symbols = [];
            const lines = model.getLineCount();
            
            // Regex para detectar declaraciones
            const symbolRegex = /^\s*(static\s+)?(function|procedure|method|class)\s+([a-zA-Z0-9_\(\): ]+)/i;

            for (let i = 1; i <= lines; i++) {
                const line = model.getLineContent(i);
                const match = line.match(symbolRegex);
                
                if (match) {
                    const type = match[2].toLowerCase();
                    const name = match[3].trim();
                    
                    let kind = monaco.languages.SymbolKind.Function;
                    if (type === 'class') kind = monaco.languages.SymbolKind.Class;
                    if (type === 'method') kind = monaco.languages.SymbolKind.Method;

                    symbols.push({
                        name: name,
                        detail: type.toUpperCase(),
                        kind: kind,
                        range: {
                            startLineNumber: i,
                            startColumn: 1,
                            endLineNumber: i,
                            endColumn: line.length + 1
                        },
                        selectionRange: {
                            startLineNumber: i,
                            startColumn: 1,
                            endLineNumber: i,
                            endColumn: line.length + 1
                        }
                    });
                }
            }
            return symbols;
        }
    });

    console.log("Harbour extension loaded successfully.");
}

function setupEditorIA(editor, active, monaco) {
    if (!active || !editor || !monaco) return;
    
    editor.addAction({
        id: 'gen-ai-request',
        label: 'Gemma: Ask AI Assistant',
        keybindings: [
            monaco.KeyMod.CtrlCmd | monaco.KeyCode.KeyK
        ],
        contextMenuGroupId: 'navigation',
        contextMenuOrder: 1.5,
        run: function(ed) {
            const selection = ed.getSelection();
            const text = ed.getModel().getValueInRange(selection);
            window.webkit.messageHandlers.fivemac.postMessage( 'onAIRequest:' + text );
        }
    });
}
