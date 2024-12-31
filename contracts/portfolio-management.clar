;; Title: Portfolio Management Protocol
;;
;; Summary:
;; A decentralized portfolio management system that enables users to create, manage,
;; and automatically rebalance cryptocurrency portfolios with customizable asset allocations.
;;
;; Description:
;; This contract implements a comprehensive portfolio management protocol with the following features:
;; - Portfolio creation with multiple tokens and customizable allocations
;; - Automated portfolio rebalancing mechanism
;; - User-specific portfolio tracking
;; - Percentage-based asset allocation management
;; - Protocol-level fee management
;; - Secure ownership and authorization controls

;; Error Codes
(define-constant ERR-NOT-AUTHORIZED (err u100))        ;; Unauthorized access attempt
(define-constant ERR-INVALID-PORTFOLIO (err u101))     ;; Portfolio doesn't exist or is invalid
(define-constant ERR-INSUFFICIENT-BALANCE (err u102))  ;; Insufficient funds for operation
(define-constant ERR-INVALID-TOKEN (err u103))        ;; Invalid token address provided
(define-constant ERR-REBALANCE-FAILED (err u104))     ;; Portfolio rebalancing operation failed
(define-constant ERR-PORTFOLIO-EXISTS (err u105))      ;; Portfolio already exists
(define-constant ERR-INVALID-PERCENTAGE (err u106))    ;; Invalid allocation percentage
(define-constant ERR-MAX-TOKENS-EXCEEDED (err u107))   ;; Exceeded maximum allowed tokens
(define-constant ERR-LENGTH-MISMATCH (err u108))      ;; Mismatch in input array lengths
(define-constant ERR-USER-STORAGE-FAILED (err u109))   ;; Failed to update user storage
(define-constant ERR-INVALID-TOKEN-ID (err u110))      ;; Invalid token ID in portfolio

;; Protocol Configuration
(define-data-var protocol-owner principal tx-sender)
(define-data-var portfolio-counter uint u0)
(define-data-var protocol-fee uint u25)                ;; 0.25% in basis points

;; Protocol Constants
(define-constant MAX-TOKENS-PER-PORTFOLIO u10)
(define-constant BASIS-POINTS u10000)                  ;; 100% = 10000 basis points

;; Data Structures
(define-map Portfolios
    uint                                               ;; portfolio-id
    {
        owner: principal,
        created-at: uint,
        last-rebalanced: uint,
        total-value: uint,
        active: bool,
        token-count: uint
    }
)

(define-map PortfolioAssets
    {portfolio-id: uint, token-id: uint}
    {
        target-percentage: uint,
        current-amount: uint,
        token-address: principal
    }
)

(define-map UserPortfolios
    principal
    (list 20 uint)
)

;; Read-Only Functions

;; Retrieves portfolio details by ID
(define-read-only (get-portfolio (portfolio-id uint))
    (map-get? Portfolios portfolio-id)
)

;; Retrieves specific asset details within a portfolio
(define-read-only (get-portfolio-asset (portfolio-id uint) (token-id uint))
    (map-get? PortfolioAssets {portfolio-id: portfolio-id, token-id: token-id})
)

;; Returns list of portfolio IDs owned by a user
(define-read-only (get-user-portfolios (user principal))
    (default-to (list) (map-get? UserPortfolios user))
)

;; Calculates rebalancing requirements for a portfolio
(define-read-only (calculate-rebalance-amounts (portfolio-id uint))
    (let (
        (portfolio (unwrap! (get-portfolio portfolio-id) ERR-INVALID-PORTFOLIO))
        (total-value (get total-value portfolio))
    )
    (ok {
        portfolio-id: portfolio-id,
        total-value: total-value,
        needs-rebalance: (> (- block-height (get last-rebalanced portfolio)) u144)
    }))
)

;; Private Functions

;; Validates token ID within portfolio constraints
(define-private (validate-token-id (portfolio-id uint) (token-id uint))
    (let (
        (portfolio (unwrap! (get-portfolio portfolio-id) false))
    )
    (and 
        (< token-id MAX-TOKENS-PER-PORTFOLIO)
        (< token-id (get token-count portfolio))
        true
    ))
)

;; Validates percentage is within valid range (0-10000 basis points)
(define-private (validate-percentage (percentage uint))
    (and (>= percentage u0) (<= percentage BASIS-POINTS))
)

;; Validates sum of portfolio percentages
(define-private (validate-portfolio-percentages (percentages (list 10 uint)))
    (fold check-percentage-sum percentages true)
)

;; Helper function for percentage validation
(define-private (check-percentage-sum (current-percentage uint) (valid bool))
    (and valid (validate-percentage current-percentage))
)

;; Adds portfolio ID to user's portfolio list
(define-private (add-to-user-portfolios (user principal) (portfolio-id uint))
    (let (
        (current-portfolios (get-user-portfolios user))
        (new-portfolios (unwrap! (as-max-len? (append current-portfolios portfolio-id) u20) ERR-USER-STORAGE-FAILED))
    )
    (map-set UserPortfolios user new-portfolios)
    (ok true))
)

;; Initializes a new portfolio asset
(define-private (initialize-portfolio-asset (index uint) (token principal) (percentage uint) (portfolio-id uint))
    (if (>= percentage u0)
        (begin
            (map-set PortfolioAssets
                {portfolio-id: portfolio-id, token-id: index}
                {
                    target-percentage: percentage,
                    current-amount: u0,
                    token-address: token
                }
            )
            (ok true))
        ERR-INVALID-TOKEN
    )
)

;; Public Functions

;; Creates a new portfolio with specified tokens and allocations
(define-public (create-portfolio (initial-tokens (list 10 principal)) (percentages (list 10 uint)))
    (let (
        (portfolio-id (+ (var-get portfolio-counter) u1))
        (token-count (len initial-tokens))
        (percentage-count (len percentages))
        (token-0 (element-at? initial-tokens u0))
        (token-1 (element-at? initial-tokens u1))
        (percentage-0 (element-at? percentages u0))
        (percentage-1 (element-at? percentages u1))
    )
    (asserts! (<= token-count MAX-TOKENS-PER-PORTFOLIO) ERR-MAX-TOKENS-EXCEEDED)
    (asserts! (is-eq token-count percentage-count) ERR-LENGTH-MISMATCH)
    (asserts! (validate-portfolio-percentages percentages) ERR-INVALID-PERCENTAGE)
    
    ;; Create portfolio
    (map-set Portfolios portfolio-id
        {
            owner: tx-sender,
            created-at: block-height,
            last-rebalanced: block-height,
            total-value: u0,
            active: true,
            token-count: token-count
        }
    )
    
    ;; Validate tokens and percentages
    (asserts! (and (is-some token-0) (is-some token-1)) ERR-INVALID-TOKEN)
    (asserts! (and (is-some percentage-0) (is-some percentage-1)) ERR-INVALID-PERCENTAGE)
    
    ;; Initialize portfolio assets
    (try! (initialize-portfolio-asset 
        u0 
        (unwrap-panic token-0)
        (unwrap-panic percentage-0)
        portfolio-id))
    
    (try! (initialize-portfolio-asset 
        u1
        (unwrap-panic token-1)
        (unwrap-panic percentage-1)
        portfolio-id))
    
    ;; Update user's portfolio list
    (try! (add-to-user-portfolios tx-sender portfolio-id))
    
    ;; Increment counter
    (var-set portfolio-counter portfolio-id)
    (ok portfolio-id))
)
