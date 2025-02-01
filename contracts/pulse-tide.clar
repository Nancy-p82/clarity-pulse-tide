;; PulseTide Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-owner (err u100))
(define-constant err-invalid-event (err u101))
(define-constant err-already-voted (err u102))

;; Data structures
(define-map events 
  { event-id: uint }
  {
    creator: principal,
    title: (string-utf8 100),
    active: bool,
    total-votes: uint,
    timestamp: uint
  }
)

(define-map feedback
  { event-id: uint, user: principal }
  {
    rating: uint,
    timestamp: uint
  }
)

;; Data variables
(define-data-var event-counter uint u0)

;; Public functions
(define-public (create-event (title (string-utf8 100)))
  (let (
    (event-id (var-get event-counter))
  )
    (if (is-eq tx-sender contract-owner)
      (begin
        (map-set events 
          { event-id: event-id }
          {
            creator: tx-sender,
            title: title,
            active: true,
            total-votes: u0,
            timestamp: block-height
          }
        )
        (var-set event-counter (+ event-id u1))
        (ok event-id)
      )
      err-not-owner
    )
  )
)

(define-public (submit-feedback (event-id uint) (rating uint))
  (let (
    (event (unwrap! (map-get? events {event-id: event-id}) (err err-invalid-event)))
  )
    (if (is-some (map-get? feedback {event-id: event-id, user: tx-sender}))
      err-already-voted
      (begin
        (map-set feedback
          {event-id: event-id, user: tx-sender}
          {
            rating: rating,
            timestamp: block-height
          }
        )
        (map-set events
          {event-id: event-id}
          (merge event {total-votes: (+ (get total-votes event) u1)})
        )
        (ok true)
      )
    )
  )
)
