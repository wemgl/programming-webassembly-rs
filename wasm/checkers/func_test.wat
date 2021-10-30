(module
    (memory $mem 1)

    ;; Binary Value     Decimal Value       Game Meaning
    ;; ======================================================
    ;; 00000000         0                   Unoccupied Square
    ;; 00000001         1                   Black Piece
    ;; 00000010         2                   White Piece
    ;; 00000100         4                   Crowned Piece
    ;; ======================================================
    (global $BLACK i32 (i32.const 1))
    (global $WHITE i32 (i32.const 2))
    (global $CROWN i32 (i32.const 4))

    (func $indexForPosition (param $x i32) (param $y i32) (result i32)
        (i32.add
            (i32.mul
                (i32.const 8)
                (get_local $y)
            )
            (get_local $x)
        )
    )

    ;; offset = (x+y*8)*4
    ;;
    ;; The offset in a contiguous block of memory that represents an 8x8 checker board
    ;; is calculated with the above formula. 8 is the number of squares per row (i.e. columns)
    ;; and 4 is the number of bytes each column consists of. 4 is used since the board represents
    ;; 32-bit integers where 8 bits make up a byte, so 4 bytes will be used by WASM to index
    ;; the memory.
    (func $offsetForPosition (param $x i32) (param $y i32) (result i32)
        (i32.mul
            (call $indexForPosition (get_local $x) (get_local $y))
            (i32.const 4)
        )
    )

    ;; Determine if a piece has been crowned.
    (func $isCrowned (param $piece i32) (result i32)
        (i32.eq
            (i32.and (get_local $piece) (get_global $CROWN))
            (get_global $CROWN)
        )
    )

    ;; Determine if a piece if white.
    (func $isWhite (param $piece i32) (result i32)
        (i32.eq
            (i32.and (get_local $piece) (get_global $WHITE))
            (get_global $WHITE)
        )
    )

    ;; Determine if a piece is black.
    (func $isBlack (param $piece i32) (result i32)
        (i32.eq
            (i32.and (get_local $piece) (get_global $BLACK))
            (get_global $BLACK)
        )
    )

    ;; Determine if a piece is crowned.
    ;;
    ;; Value        Meaning             Operation       Mask        Result
    ;; =====================================================================
    ;; 0101         Crowned Black       &               0011        0001 (B)
    ;; 0001         UnCrowned Black     &               0011        0001 (B)
    ;; 0110         Crowned Black       &               0011        0010 (W)
    ;; =====================================================================

    ;; Adds a crown to a given piece (no mutation).
    (func $withCrown (param $piece i32) (result i32)
        (i32.or (get_local $piece) (get_global $CROWN))
    )

    ;; Removes a crown from a given piece (no mutation).
    (func $withoutCrown (param $piece i32) (result i32)
        (i32.and (get_local $piece) (i32.const 3))
    )

    ;; Sets a piece on the board.
    (func $setPiece (param $x i32) (param $y i32) (param $piece i32)
        (i32.store
            (call $offsetForPosition
                (get_local $x)
                (get_local $y)
            )
            (get_local $piece)
        )
    )

    ;; Gets a piece from the board. Out of range causes a trap.
    (func $getPiece (param $x i32) (param $y i32) (result i32)
        (if (result i32)
            (block (result i32)
                (i32.and
                    (call $inRange
                        (i32.const 0)
                        (i32.const 7)
                        (get_local $x)
                    )
                    (call $inRange
                        (i32.const 0)
                        (i32.const 7)
                        (get_local $y)
                    )
                )
            )
            (then
                (i32.load
                    (call $offsetForPosition
                        (get_local $x)
                        (get_local $y))
                )
            )
            (else
                (unreachable)
            )
        )
    )

    ;; Detect if values are within range (inclusive high and low).
    (func $inRange (param $low i32) (param $high i32)
                   (param $value i32) (result i32)
        (i32.and
            (i32.ge_s (get_local $value) (get_local $low))
            (i32.le_s (get_local $value) (get_local $high))
        )
    )

    (export "offsetForPosition" (func $offsetForPosition))
    (export "isCrowned" (func $isCrowned))
    (export "isWhite" (func $isWhite))
    (export "isBlack" (func $isBlack))
    (export "withCrown" (func $withCrown))
    (export "withoutCrown" (func $withoutCrown))
    (export "setPiece" (func $setPiece))
    (export "getPiece" (func $getPiece))
    (export "inRange" (func $inRange))
)
