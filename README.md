code
Markdown
# 🏥 Organ Donation & Transplant Platform

A blockchain-based smart contract project to transparently connect organ donors with recipients, ensuring fairness and security in organ allocation.

## 🚀 Getting Started (For Team Members)

1. **Clone the repository.**
2. **Install dependencies** (Crucial fix for Node v25 compatibility):
   ```bash
   npm install --legacy-peer-deps
Compile the contracts:
code
Bash
npx hardhat compile
🌐 Live Testnet Deployment (Sepolia)
The system is successfully deployed on the Ethereum Sepolia Testnet.
Registration Contract (Person 1): 0xe7a503B2f605aD5180BcdcbC05CB5b70a4E36253
Matching Contract (Person 2): 0xEe3fe137c37Af70f64cA8Fa4319EEAAdc5Af12cA
✅ Transaction Logs (Task 5 Proof)
A live donor registration has been processed on-chain:
Transaction Hash: 0xf4f3d903cb226250563cc4f5d551af930f759a027ce8805dc1af585e18abbe32
View on Etherscan: Click Here
📋 Module Overview: Person 1 (Nowisar)
This module acts as the "Source of Truth" for the entire platform, covering Tasks 1 through 7:
Data Integrity (Task 1): Implemented Enums for OrganType and BloodType to eliminate manual data entry errors and ensure matching accuracy.
Secure Storage (Task 1): Utilized Mappings and Structs for gas-efficient, 
O
(
1
)
O(1)
 medical record lookups.
Access Control (Task 5): Integrated a Role-Based Access Control system. Only verified medical institutions (Authorized Hospitals) can register patients to the recipient list.
Validation Logic (Task 7): Developed require checks to prevent zero-address entries, duplicate registrations, and invalid medical priority scores.
Security Bonus: Conducted a static security analysis using Slither to identify and mitigate potential vulnerabilities.
🛠 Implemented Functions
registerDonor: Allows users to record their donation intent.
authorizeHospital: (Admin Only) Verifies hospital credentials.
registerRecipient: (Hospital Only) Securely adds patients to the transplant waitlist.
getDonorInfo / getRecipientInfo: High-speed data retrieval functions.