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
