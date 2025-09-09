# TradeArcana - Card Trading Game Smart Contract

TradeArcana is a Clarity-based smart contract that powers a collectible card trading game on the blockchain. Each card is a unique **NFT** with customizable attributes like attack, defense, rarity, and element. The contract enables card creation, trading, marketplace listings, and peer-to-peer swaps, ensuring secure and transparent gameplay.

---

## Features

### Card System

* **NFT-based Cards**: Each card is a unique non-fungible token (`card`) identified by a `card-id`.
* **Card Attributes**: Cards store metadata including:

  * `name` – Card name
  * `attack` – Attack power
  * `defense` – Defense power
  * `rarity` – Rarity level
  * `element` – Element type (e.g., Fire, Water)

### Marketplace

* Players can **list cards for sale**, setting a price in STX.
* Buyers purchase listed cards by paying the specified price.
* Cards are transferred securely from seller to buyer.
* Owners may also **unlist cards**, returning them to their wallets.

### Player-to-Player Trading

* **Direct swaps** between two players:

  * Each party specifies a card to exchange.
  * Transfers occur atomically, ensuring fairness.

---

## Functions

### Admin

* `create-card (name attack defense rarity element)`
  Owner-only function to mint new cards with specified attributes. Increments `next-card-id` for uniqueness.

### Trading & Marketplace

* `list-card (card-id price)`
  Owner of a card can list it for sale. Card is escrowed in the contract until sold or unlisted.

* `unlist-card (card-id)`
  Seller retrieves their card from the marketplace.

* `buy-card (card-id)`
  Buyer pays STX equal to the card’s price. The card is transferred from escrow to the buyer.

* `trade-cards (send-card-id receive-card-id counterparty)`
  Two players swap cards directly without involving STX.

### Read-Only

* `get-card-details (card-id)` → Returns attributes of a given card.
* `get-market-listing (card-id)` → Returns sale price and seller if card is listed.
* `get-card-owner (card-id)` → Returns the owner of a given card.

---

## Access Control

* **Contract Owner**: Only the contract owner can create new cards.
* **Card Owners**: Only card owners can list, unlist, or trade their cards.
* **Buyers**: Any user can buy listed cards if they have sufficient STX.

---

## Error Handling

* `err-owner-only (u100)` – Action restricted to contract owner.
* `err-not-token-owner (u101)` – Caller is not the card owner.
* `err-invalid-card (u102)` – Card does not exist.
* `err-card-exists (u103)` – Card already exists (not used in this version, but reserved).
* `err-insufficient-payment (u104)` – Buyer has insufficient payment (validation handled by `stx-transfer?`).

---

## Summary

TradeArcana is a secure, feature-rich card trading game contract that uses NFTs to represent collectible cards. Players can mint, buy, sell, and trade cards while relying on blockchain-based trust and transparency. This framework allows developers to expand the ecosystem with gameplay mechanics, rarity-based economies, or battle modules.
