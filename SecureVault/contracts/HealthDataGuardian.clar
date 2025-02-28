;; Define a data structure for a health data entry
(define-map health-data-vault 
  {entry-id: int} ;; unique identifier for each entry
  {
    custodian: principal,
    entry-data: (buff 1000) ;; encrypted data storage
  }
)

;; Define a data structure for access permissions
(define-map data-access-registry
  {entry-id: int, permitted-viewer: principal}
  {
    has-permission: bool,
    access-end-height: (optional uint) ;; time-limited access
  }
)

;; Define a data structure for the activity log
(define-data-var activity-log-counter uint u0)
(define-map activity-log-registry
  {log-id: uint}
  {
    entry-id: int,
    actor: principal,
    operation: (string-ascii 50),
    block-time: uint
  }
)

;; Function to record operations to the activity log
(define-private (record-operation (entry-id int) (operation (string-ascii 50)))
  (begin
    (map-insert activity-log-registry
      {log-id: (var-get activity-log-counter)}
      {
        entry-id: entry-id,
        actor: tx-sender,
        operation: operation,
        block-time: block-height
      }
    )
    (var-set activity-log-counter (+ (var-get activity-log-counter) u1))
  )
)

;; Function to create a new health data entry
(define-public (store-health-data (entry-id int) (encrypted-data (buff 1000)))
  (begin
    ;; Validate input parameters
    (asserts! (> entry-id 0) (err "Entry ID must be positive"))
    (asserts! (> (len encrypted-data) u0) (err "Data cannot be empty"))
    
    ;; Check if entry already exists
    (asserts! (is-none (map-get? health-data-vault {entry-id: entry-id})) 
              (err "Entry already exists"))
    
    ;; Create the entry
    (map-insert health-data-vault
      {entry-id: entry-id}
      {
        custodian: tx-sender,
        entry-data: encrypted-data
      }
    )
    (record-operation entry-id "Data Stored")
    (ok true)
  )
)

;; Function to grant or update access to a health data entry
(define-public (authorize-data-access (entry-id int) (viewer principal) (expiry-height (optional uint)))
  (begin
    ;; Validate input parameters
    (asserts! (> entry-id 0) (err "Entry ID must be positive"))
    (asserts! (not (is-eq tx-sender viewer)) (err "Cannot grant access to yourself"))
    
    ;; Validate expiry height if provided
    (if (is-some expiry-height)
        (asserts! (> (unwrap-panic expiry-height) block-height) 
                 (err "Expiry height must be in the future"))
        true)
    
    ;; Check if the entry exists and caller is the owner
    (let ((entry (map-get? health-data-vault {entry-id: entry-id})))
      (asserts! (not (is-none entry)) (err "Entry Not Found"))
      (asserts! (is-eq tx-sender (get custodian (unwrap-panic entry))) 
                (err "Not Authorized to Grant Access"))
      
      ;; Grant access
      (map-insert data-access-registry
        {entry-id: entry-id, permitted-viewer: viewer}
        {
          has-permission: true,
          access-end-height: expiry-height
        }
      )
      (record-operation entry-id "Access Authorized")
      (ok true)
    )
  )
)

;; Function to revoke access to a health data entry
(define-public (cancel-data-access (entry-id int) (viewer principal))
  (begin
    ;; Validate input parameters
    (asserts! (> entry-id 0) (err "Entry ID must be positive"))
    (asserts! (not (is-eq tx-sender viewer)) (err "Cannot revoke access from yourself"))
    
    ;; Check if the entry exists and caller is the owner
    (let ((entry (map-get? health-data-vault {entry-id: entry-id})))
      (asserts! (not (is-none entry)) (err "Entry Not Found"))
      (asserts! (is-eq tx-sender (get custodian (unwrap-panic entry))) 
                (err "Not Authorized to Cancel Access"))
      
      ;; Revoke access
      (map-insert data-access-registry
        {entry-id: entry-id, permitted-viewer: viewer}
        {
          has-permission: false,
          access-end-height: none
        }
      )
      (record-operation entry-id "Access Canceled")
      (ok true)
    )
  )
)

;; Function to access a health data entry
(define-public (view-health-data (entry-id int))
  (begin
    ;; Validate input parameters
    (asserts! (> entry-id 0) (err "Entry ID must be positive"))
    
    ;; Check if permission exists
    (let ((permission (map-get? data-access-registry {entry-id: entry-id, permitted-viewer: tx-sender})))
      (asserts! (not (is-none permission)) (err "No Permission"))
      
      (let ((perm (unwrap-panic permission)))
        ;; Check if permission is valid
        (asserts! (get has-permission perm) (err "Access Denied"))
        
        ;; Check if permission has not expired
        (asserts! (or (is-none (get access-end-height perm))
                    (>= (default-to u0 (get access-end-height perm)) block-height))
                 (err "Access Expired"))
        
        ;; Get the entry data
        (let ((entry (map-get? health-data-vault {entry-id: entry-id})))
          (asserts! (not (is-none entry)) (err "Entry Not Found"))
          
          (record-operation entry-id "Data Viewed")
          (ok (get entry-data (unwrap-panic entry)))
        )
      )
    )
  )
)