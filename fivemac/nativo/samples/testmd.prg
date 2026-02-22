#include "FiveMac.ch"

function Main()

    local oWnd, oMd
    local cText := "# TMarkdownView Test" + CRLF + CRLF + ;
        "## Features" + CRLF + ;
        "- **Native** rendering using Apple's engine." + CRLF + ;
        "- *Lightweight* (no full browser required)." + CRLF + ;
        "- Supports [Links](http://www.fivetechsoft.com)." + CRLF + CRLF + ;
        "### Sample List" + CRLF + ;
        "1. First item" + CRLF + ;
        "2. Second item" + CRLF + ;
        "3. Third item" + CRLF + CRLF + ;
        "> This is a blockquote rendered natively."

    DEFINE WINDOW oWnd TITLE "Markdown Native View" ;
        FROM 200, 200 TO 700, 800

    @ 20, 20 MARKDOWN oMd SIZE 560, 460 OF oWnd TEXT cText

    ACTIVATE WINDOW oWnd

return nil
