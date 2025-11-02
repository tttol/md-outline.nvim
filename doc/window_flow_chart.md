# Window Module Flow Chart

## Overview
This document visualizes the logic flow of `lua/core/window.lua` using Mermaid.js diagrams.

## M.show() - Opening Outline Window

```mermaid
flowchart TD
    Start([User executes :MdoOpen]) --> GetCurrentState[Get current window and buffer]
    GetCurrentState --> ReadLines[Read all lines from buffer]

    ReadLines --> CollectHeadings{Iterate through lines}
    CollectHeadings -->|Match ^#+\s+| AddPosition[Add to heading_positions table]
    CollectHeadings -->|No match| SkipLine[Skip line]
    AddPosition --> CollectHeadings
    SkipLine --> CollectHeadings
    CollectHeadings -->|Done| SavePositions[Save positions to vim.b source_buf]

    SavePositions --> ExtractHeadings[Call string.extractHeadings lines]
    ExtractHeadings --> CreateOutline[Call string.createOutline headings]

    CreateOutline --> CreateBuffer[Create new outline buffer]
    CreateBuffer --> AddFooter[Add empty line and footer message]
    AddFooter --> WriteContent[Write outlines to buffer]

    WriteContent --> SetOptions[Set buffer options:<br/>modifiable=false<br/>buftype=nofile]
    SetOptions --> CreateWindow[vsplit + wincmd L]
    CreateWindow --> SetBuffer[Set buffer to new window]
    SetBuffer --> SetWidth[Set window width to 40]

    SetWidth --> HighlightFooter[Highlight footer with Comment group]
    HighlightFooter --> MapQKey[Map q key to close function]
    MapQKey --> ReturnFocus[Return focus to original window]

    ReturnFocus --> CreateAutocmd[Create autocmd group MdOutlineHighlight]
    CreateAutocmd --> SetupListener[Listen to CursorMoved and CursorMovedI]
    SetupListener --> InitialHighlight[Call update_highlight initially]

    InitialHighlight --> Return([Return outline_win and outline_buf])
```

## update_highlight() - Real-time Highlighting

```mermaid
flowchart TD
    Start([Cursor moves in source buffer]) --> CheckBuffers{Buffers valid?}
    CheckBuffers -->|No| End([Return early])
    CheckBuffers -->|Yes| GetState[Get heading_positions from vim.b source_buf<br/>Get prev_highlight from vim.b outline_buf]

    GetState --> ClearPrevious{Previous highlight exists?}
    ClearPrevious -->|Yes| ClearNamespace[Clear namespace for previous line]
    ClearPrevious -->|No| GetCursor[Get current cursor position]
    ClearNamespace --> GetCursor

    GetCursor --> FindHeading[Call find_current_heading cursor_line, positions]
    FindHeading --> HeadingFound{Heading found?}

    HeadingFound -->|No| End2([Return without highlighting])
    HeadingFound -->|Yes| CalcLine[Calculate highlight_line = heading_idx - 1]
    CalcLine --> ApplyHighlight[Apply CursorLine highlight to line]
    ApplyHighlight --> SaveState[Save highlight_line to vim.b outline_buf]
    SaveState --> End3([Complete])
```

## find_current_heading() - Find Current Section

```mermaid
flowchart TD
    Start([Input: cursor_line, positions]) --> Init[current_heading_idx = nil]
    Init --> Loop{For each position in positions}

    Loop -->|Has next| CheckLine{pos.line <= cursor_line?}
    CheckLine -->|Yes| UpdateIdx[current_heading_idx = i]
    CheckLine -->|No| Break[Break loop]
    UpdateIdx --> Loop

    Loop -->|No more| Return([Return current_heading_idx])
    Break --> Return

    style UpdateIdx fill:#90EE90
    style Break fill:#FFB6C1
```

## M.close() - Closing Outline Window

```mermaid
flowchart TD
    Start([User presses q or executes :MdoClose]) --> CheckWindow{Window valid?}
    CheckWindow -->|Yes| CloseWindow[Close outline window]
    CheckWindow -->|No| ClearAutocmd[Clear MdOutlineHighlight autocmd group]
    CloseWindow --> ClearAutocmd

    ClearAutocmd --> Return([Return nil, nil])
```

## Complete Interaction Flow

```mermaid
sequenceDiagram
    participant User
    participant MdoOpen
    participant Window
    participant String
    participant Vim
    participant Autocmd

    User->>MdoOpen: :MdoOpen
    MdoOpen->>Window: show()

    Window->>Vim: Get current buffer/lines
    Vim-->>Window: lines

    Window->>Window: Collect heading positions
    Window->>Vim: Save to vim.b[source_buf]

    Window->>String: extractHeadings(lines)
    String-->>Window: headings

    Window->>String: createOutline(headings)
    String-->>Window: outlines

    Window->>Vim: Create buffer and window
    Window->>Vim: Setup autocmd listeners
    Window->>Window: update_highlight()

    Window-->>User: Display outline window

    loop Cursor Movement
        User->>Vim: Move cursor
        Vim->>Autocmd: CursorMoved event
        Autocmd->>Window: update_highlight()
        Window->>Window: find_current_heading()
        Window->>Vim: Highlight corresponding line
        Vim-->>User: Visual feedback
    end

    User->>Window: Press 'q' or :MdoClose
    Window->>Vim: Close window
    Window->>Vim: Clear autocmds
    Window-->>User: Outline closed
```

## State Management

```mermaid
graph LR
    subgraph "Module Level"
        A[ns_id namespace ID]
    end

    subgraph "Buffer Variables vim.b"
        B[source_buf.md_outline_positions]
        C[outline_buf.md_outline_highlight_line]
    end

    subgraph "Function Parameters"
        D[outline_win window ID]
        E[outline_buf buffer ID]
        F[source_buf_local buffer ID]
    end

    A -.Used for highlighting.-> B
    B -.Read by.-> C
    D -.Passed between.-> E
    E -.Passed between.-> F

    style A fill:#4A5568,stroke:#A0AEC0,color:#E2E8F0
    style B fill:#2C5282,stroke:#4299E1,color:#E2E8F0
    style C fill:#2C5282,stroke:#4299E1,color:#E2E8F0
    style D fill:#553C9A,stroke:#9F7AEA,color:#E2E8F0
    style E fill:#553C9A,stroke:#9F7AEA,color:#E2E8F0
    style F fill:#553C9A,stroke:#9F7AEA,color:#E2E8F0
```

## Key Concepts

### Buffer-Local Variables
- **`vim.b[buf].md_outline_positions`**: Stores heading line numbers and text for the source buffer
- **`vim.b[buf].md_outline_highlight_line`**: Tracks which line is currently highlighted in outline buffer

### Namespace
- **`ns_id`**: Used to manage highlights (add/remove) without conflicts

### Autocmd Group
- **`MdOutlineHighlight`**: Groups cursor movement listeners for easy cleanup

### Pure Functions
- Functions accept all state as parameters instead of relying on global variables
- Makes testing easier and prevents unexpected side effects
