;; Card Trading Game Contract

;; Constants
(define-constant game-manager tx-sender)
(define-constant err-manager-only (err u100))
(define-constant err-not-card-owner (err u101))
(define-constant err-invalid-card (err u102))
(define-constant err-card-exists (err u103))
(define-constant err-insufficient-balance (err u104))

;; Define the NFT for cards
(define-non-fungible-token game-card uint)

;; Data Maps
(define-map card-attributes
   uint    ;; card-id
   {
       title: (string-utf8 50),
       attack: uint,
       defense: uint,
       tier: uint,
       category: (string-utf8 20)
   })

(define-map card-marketplace
   uint    ;; card-id
   {
       price: uint,
       seller: principal
   })

;; Variables
(define-data-var card-counter uint u1)

;; Admin Functions
(define-public (mint-card (title (string-utf8 50)) 
                         (attack uint) 
                         (defense uint) 
                         (tier uint)
                         (category (string-utf8 20)))
   (let ((card-id (var-get card-counter)))
       (begin
           (asserts! (is-eq tx-sender game-manager) err-manager-only)
           (try! (nft-mint? game-card card-id game-manager))
           (map-set card-attributes card-id
               {
                   title: title,
                   attack: attack,
                   defense: defense,
                   tier: tier,
                   category: category
               })
           (var-set card-counter (+ card-id u1))
           (ok card-id))))

;; Trading Functions
(define-public (sell-card (card-id uint) (price uint))
   (begin
       (asserts! (is-eq (unwrap! (nft-get-owner? game-card card-id) err-invalid-card) tx-sender) 
                err-not-card-owner)
       (try! (nft-transfer? game-card card-id tx-sender (as-contract tx-sender)))
       (map-set card-marketplace card-id {price: price, seller: tx-sender})
       (ok true)))

(define-public (cancel-sale (card-id uint))
   (let ((marketplace-listing (unwrap! (map-get? card-marketplace card-id) err-invalid-card)))
       (begin
           (asserts! (is-eq (get seller marketplace-listing) tx-sender) err-not-card-owner)
           (try! (as-contract (nft-transfer? game-card card-id (as-contract tx-sender) tx-sender)))
           (map-delete card-marketplace card-id)
           (ok true))))

(define-public (purchase-card (card-id uint))
   (let ((listing (unwrap! (map-get? card-marketplace card-id) err-invalid-card))
         (price (get price listing))
         (seller (get seller listing)))
       (begin
           (try! (stx-transfer? price tx-sender seller))
           (try! (as-contract (nft-transfer? game-card card-id (as-contract tx-sender) tx-sender)))
           (map-delete card-marketplace card-id)
           (ok true))))

;; Direct Trading Between Players
(define-public (swap-cards (send-card-id uint) (receive-card-id uint) (recipient principal))
   (begin
       (asserts! (is-eq (unwrap! (nft-get-owner? game-card send-card-id) err-invalid-card) tx-sender)
                err-not-card-owner)
       (asserts! (is-eq (unwrap! (nft-get-owner? game-card receive-card-id) err-invalid-card) recipient)
                err-not-card-owner)
       (try! (nft-transfer? game-card send-card-id tx-sender recipient))
       (try! (nft-transfer? game-card receive-card-id recipient tx-sender))
       (ok true)))

;; Read-Only Functions
(define-read-only (get-card-attributes (card-id uint))
   (map-get? card-attributes card-id))

(define-read-only (get-marketplace-listing (card-id uint))
   (map-get? card-marketplace card-id))

(define-read-only (get-card-owner (card-id uint))
   (nft-get-owner? game-card card-id))