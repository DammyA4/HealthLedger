# HealthLedger - Secure Health Data Management on Blockchain

The HealthLedger project is a blockchain-based solution for securely storing and sharing health data. At the core of this project is the HealthDataGuardian smart contract, which provides a secure, permissioned system for managing sensitive health information.

## Project Overview

HealthLedger provides a decentralized approach to health data management with the following key features:

- **Secure Data Storage**: Store encrypted health data on the blockchain
- **Granular Access Control**: Grant time-limited access to specific healthcare providers
- **Comprehensive Audit Trail**: Track all interactions with health data
- **Patient-controlled Sharing**: Patients maintain full control over who can access their data

## Smart Contract Architecture

The HealthDataGuardian contract implements three primary data structures:

1. **Health Data Vault**: Stores encrypted health data entries
2. **Access Registry**: Manages permission settings with time-limited access capabilities
3. **Activity Log**: Records a comprehensive audit trail of all system interactions

## Functions

### For Patients

- **`store-health-data`**: Store new encrypted health data records
- **`authorize-data-access`**: Grant time-limited access to specific healthcare providers
- **`cancel-data-access`**: Revoke access permissions at any time

### For Healthcare Providers

- **`view-health-data`**: Access patient data (requires explicit permission)

## Security Features

The contract includes multiple security mechanisms:

- Comprehensive input validation
- Time-limited access controls
- Permission verification on every data access attempt
- Complete audit logging of all operations
- Robust error handling with clear user feedback

## Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - A Clarity development environment

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/HealthLedger.git
   cd HealthLedger
   ```

2. Initialize the Clarinet project (if not already initialized):
   ```
   clarinet new SecureVault
   cd SecureVault
   ```

3. Deploy the contracts locally:
   ```
   clarinet console
   ```

### Usage Example

```clarity
;; Store encrypted health data
(contract-call? .HealthDataGuardian store-health-data 1 0x123456...)

;; Grant access to a healthcare provider
(contract-call? .HealthDataGuardian authorize-data-access 1 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM (some u100000))

;; Healthcare provider accessing the data
(as-contract 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM (contract-call? .HealthDataGuardian view-health-data 1))

;; Revoking access
(contract-call? .HealthDataGuardian cancel-data-access 1 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request
