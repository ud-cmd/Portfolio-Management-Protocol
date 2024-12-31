# Portfolio Management Protocol

A decentralized portfolio management system implemented in Clarity for managing and automatically rebalancing cryptocurrency portfolios with customizable asset allocations.

## Overview

The Portfolio Management Protocol enables users to create and manage cryptocurrency portfolios with multiple tokens and automated rebalancing capabilities. It provides a secure and efficient way to maintain desired asset allocations while ensuring proper authorization controls.

## Features

- **Portfolio Creation**: Create portfolios with multiple tokens (up to 10) and customizable allocations
- **Automated Rebalancing**: Built-in mechanism for portfolio rebalancing
- **User-Specific Portfolio Tracking**: Track and manage multiple portfolios per user
- **Percentage-Based Allocation**: Define and update asset allocations using basis points
- **Protocol-Level Fee Management**: Integrated fee structure (0.25% fee)
- **Secure Authorization**: Robust ownership and access controls

## Contract Structure

### Constants

- `MAX-TOKENS-PER-PORTFOLIO`: Maximum number of tokens allowed per portfolio (10)
- `BASIS-POINTS`: Base unit for percentage calculations (10000 = 100%)

### Error Codes

```clarity
ERR-NOT-AUTHORIZED (u100)        - Unauthorized access attempt
ERR-INVALID-PORTFOLIO (u101)     - Portfolio doesn't exist or is invalid
ERR-INSUFFICIENT-BALANCE (u102)  - Insufficient funds for operation
ERR-INVALID-TOKEN (u103)         - Invalid token address provided
ERR-REBALANCE-FAILED (u104)      - Portfolio rebalancing operation failed
ERR-PORTFOLIO-EXISTS (u105)      - Portfolio already exists
ERR-INVALID-PERCENTAGE (u106)    - Invalid allocation percentage
ERR-MAX-TOKENS-EXCEEDED (u107)   - Exceeded maximum allowed tokens
ERR-LENGTH-MISMATCH (u108)       - Mismatch in input array lengths
ERR-USER-STORAGE-FAILED (u109)   - Failed to update user storage
ERR-INVALID-TOKEN-ID (u110)      - Invalid token ID in portfolio
```

### Data Maps

#### Portfolios

Stores portfolio information:

- `owner`: Principal who owns the portfolio
- `created-at`: Block height when created
- `last-rebalanced`: Last rebalancing timestamp
- `total-value`: Total portfolio value
- `active`: Portfolio status
- `token-count`: Number of tokens in portfolio

#### PortfolioAssets

Stores individual asset information within portfolios:

- `target-percentage`: Desired allocation percentage
- `current-amount`: Current token amount
- `token-address`: Token contract address

#### UserPortfolios

Maps user principals to their portfolio IDs

## Public Functions

### create-portfolio

```clarity
(define-public (create-portfolio (initial-tokens (list 10 principal)) (percentages (list 10 uint))))
```

Creates a new portfolio with specified tokens and their target allocations.

**Parameters:**

- `initial-tokens`: List of token contract addresses
- `percentages`: List of allocation percentages in basis points

**Requirements:**

- Minimum 2 tokens required
- Total allocation must equal 100% (10000 basis points)
- Token count must not exceed MAX-TOKENS-PER-PORTFOLIO

### rebalance-portfolio

```clarity
(define-public (rebalance-portfolio (portfolio-id uint)))
```

Rebalances portfolio assets to match target allocations.

**Parameters:**

- `portfolio-id`: ID of the portfolio to rebalance

### update-portfolio-allocation

```clarity
(define-public (update-portfolio-allocation (portfolio-id uint) (token-id uint) (new-percentage uint)))
```

Updates allocation percentage for a specific token in a portfolio.

**Parameters:**

- `portfolio-id`: Target portfolio ID
- `token-id`: Token position in portfolio
- `new-percentage`: New target percentage in basis points

## Read-Only Functions

### get-portfolio

```clarity
(define-read-only (get-portfolio (portfolio-id uint)))
```

Retrieves portfolio details by ID.

### get-portfolio-asset

```clarity
(define-read-only (get-portfolio-asset (portfolio-id uint) (token-id uint)))
```

Retrieves specific asset details within a portfolio.

### get-user-portfolios

```clarity
(define-read-only (get-user-portfolios (user principal)))
```

Returns list of portfolio IDs owned by a user.

### calculate-rebalance-amounts

```clarity
(define-read-only (calculate-rebalance-amounts (portfolio-id uint)))
```

Calculates rebalancing requirements for a portfolio.

## Protocol Administration

### initialize

```clarity
(define-public (initialize (new-owner principal)))
```

Initializes or transfers protocol ownership.

## Usage Example

```clarity
;; Create a new portfolio with two tokens
(create-portfolio
    (list 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
          'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wbtc-token)
    (list u5000 u5000))  ;; 50-50 split

;; Update allocation for a token
(update-portfolio-allocation u1 u0 u6000)  ;; Update first token to 60%

;; Rebalance portfolio
(rebalance-portfolio u1)
```

## Security Considerations

1. **Authorization Controls**: All portfolio modifications require owner authorization
2. **Input Validation**: Comprehensive validation for all inputs including:
   - Token addresses
   - Percentage allocations
   - Portfolio existence
   - Token count limits
3. **Percentage Validation**: Ensures allocations always total 100%
4. **Portfolio Limits**: Enforces maximum token limits per portfolio

## Protocol Fees

The protocol charges a 0.25% fee (25 basis points) on certain operations. This fee is managed through the `protocol-fee` variable and can only be modified by the protocol owner.

## Development and Testing

To interact with this contract, you'll need:

- A Clarity-compatible development environment
- Access to the token contracts you wish to include in portfolios
- Understanding of basis points for percentage calculations

## License

This project is licensed under the MIT License.
