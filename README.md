\# Organ Donation \& Transplant Platform - Registration Module



This is the core registration contract for the Blockchain Smart Contract Project (Section E3).



\## 🚀 Getting Started

1\. Clone the repository.

2\. Install dependencies (Node v25 fix):

&#x20;  ```bash

&#x20;  npm install --legacy-peer-deps







Compile the contract:

```

npx hardhat compile



```

📋 Module Overview (Person 1 Tasks)



This module acts as the "Source of Truth" for the entire platform, handling Tasks 1 through 7:



Data Integrity (Task 1): Uses Enums for OrganType and BloodType to prevent invalid medical data.



Secure Storage (Task 1): Uses Mappings and Structs to manage Donor and Recipient records efficiently.



Access Control (Task 5): Only authorized hospitals can register patients to the recipient list.



Input Validation (Task 7): Includes checks for zero-addresses and duplicate registrations.



🛠 Functions

registerDonor: Allows users to register their intent to donate an organ.



authorizeHospital: (Admin Only) Verifies medical institutions to manage patients.



registerRecipient: (Hospital Only) Adds a patient needing a transplant to the system.

