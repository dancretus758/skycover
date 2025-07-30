;; Skycover - Underwriting Contract
;; This smart contract calculates risk scores and determines crop insurance premiums

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DATA DEFINITIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-data-var admin principal tx-sender)

;; Risk score range: 1 (low risk) to 100 (high risk)
(define-map risk-scores {
  farmer: principal,
  crop-type: (string-ascii 32),
  season: (string-ascii 10)
} uint)

;; Base premium percentages by risk tier
(define-map base-premium-tiers uint uint) ;; risk-tier -> basis points (1% = 100)

;; Farmer-specific premium discounts (e.g., loyalty, subsidies)
(define-map premium-discounts principal uint) ;; principal -> basis points

;; Track policy submissions (mock integration for the factory)
(define-map policy-submissions {
  farmer: principal,
  season: (string-ascii 10)
} bool)

;; Constants
(define-constant ERR-NOT-AUTHORIZED u100)
(define-constant ERR-RISK-NOT-FOUND u101)
(define-constant ERR-ALREADY-SCORED u102)
(define-constant ERR-INVALID-RISK u103)
(define-constant ERR-TIER-NOT-FOUND u104)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PRIVATE HELPERS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-private (is-admin)
  (is-eq tx-sender (var-get admin)))

(define-private (get-risk-tier (score uint))
  (cond
    ((<= score u20) (ok u1))
    ((<= score u40) (ok u2))
    ((<= score u60) (ok u3))
    ((<= score u80) (ok u4))
    ((<= score u100) (ok u5))
    (else (err ERR-INVALID-RISK))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PUBLIC FUNCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-public (set-base-premium-tier (tier uint) (bps uint))
  (begin
    (asserts! (is-admin) (err ERR-NOT-AUTHORIZED))
    (ok (map-set base-premium-tiers tier bps))))

(define-public (set-premium-discount (farmer principal) (bps uint))
  (begin
    (asserts! (is-admin) (err ERR-NOT-AUTHORIZED))
    (ok (map-set premium-discounts farmer bps))))

(define-public (submit-risk-score
  (farmer principal)
  (crop-type (string-ascii 32))
  (season (string-ascii 10))
  (score uint))
  (begin
    (asserts! (is-admin) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? risk-scores { farmer: farmer, crop-type: crop-type, season: season })) (err ERR-ALREADY-SCORED))
    (asserts! (<= score u100) (err ERR-INVALID-RISK))
    (ok (map-set risk-scores { farmer: farmer, crop-type: crop-type, season: season } score))))

(define-read-only (get-risk-score (farmer principal) (crop-type (string-ascii 32)) (season (string-ascii 10)))
  (map-get? risk-scores { farmer: farmer, crop-type: crop-type, season: season }))

(define-read-only (get-base-premium (score uint))
  (match (get-risk-tier score)
    tier (match (map-get? base-premium-tiers tier)
      val (ok val)
      (err ERR-TIER-NOT-FOUND))
    err (err ERR-INVALID-RISK)))

(define-read-only (calculate-final-premium
  (farmer principal)
  (crop-type (string-ascii 32))
  (season (string-ascii 10)))
  (let
    (
      (score-map (map-get? risk-scores { farmer: farmer, crop-type: crop-type, season: season }))
      (discount (default-to u0 (map-get? premium-discounts farmer)))
    )
    (match score-map
      score
        (match (get-base-premium score)
          base-premium
            (ok (if (< discount base-premium)
                    (- base-premium discount)
                    u0))
          err err)
      (err ERR-RISK-NOT-FOUND))))

(define-public (mark-policy-submitted (farmer principal) (season (string-ascii 10)))
  (begin
    (asserts! (is-admin) (err ERR-NOT-AUTHORIZED))
    (ok (map-set policy-submissions { farmer: farmer, season: season } true))))

(define-read-only (has-submitted-policy (farmer principal) (season (string-ascii 10)))
  (default-to false (map-get? policy-submissions { farmer: farmer, season: season })))

(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-admin) (err ERR-NOT-AUTHORIZED))
    (var-set admin new-admin)
    (ok true)))
