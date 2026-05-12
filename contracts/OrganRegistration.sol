// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title Organ Registration Contract
 * @author Person 1 - Registration Specialist
 */
contract OrganRegistration {

    // --- TASK 1: Enums & Structs ---
    enum OrganType { None, Kidney, Liver, Heart, Lung, Pancreas }
    enum BloodType { None, A_Plus, A_Minus, B_Plus, B_Minus, AB_Plus, AB_Minus, O_Plus, O_Minus }
    enum Status { Pending, Matched, Completed, Cancelled }

    struct Donor {
        address donorAddress;
        BloodType bloodType;
        OrganType organToDonate;
        string location;
        address authorizedHospital;
        bool isRegistered;
    }

    struct Recipient {
        address recipientAddress;
        BloodType bloodType;
        OrganType neededOrgan;
        uint256 priorityScore; 
        Status status;
        bool isRegistered;
    }

    // --- TASK 1: Mappings & State ---
    address public owner;
    mapping(address => Donor) public donors;
    mapping(address => Recipient) public recipients;
    mapping(address => bool) public isHospital; 
    
    address[] public donorList;
    address[] public recipientList;

    // --- TASK 6: Events ---
    event DonorRegistered(address indexed donor, BloodType bloodType, OrganType organ);
    event RecipientRegistered(address indexed recipient, BloodType bloodType, uint256 priority);
    event HospitalAuthorized(address indexed hospital);
    event StatusUpdated(address indexed patient, Status status); // Added this event

    // --- TASK 5: Access Control (Roles) ---
    modifier onlyOwner() {
        require(msg.sender == owner, "Only Admin can perform this action");
        _;
    }

    modifier onlyHospital() {
        require(isHospital[msg.sender], "Only authorized hospitals can perform this");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function authorizeHospital(address _hospital) external onlyOwner {
        isHospital[_hospital] = true;
        emit HospitalAuthorized(_hospital);
    }

    // --- TASK 2 & 7: Register Donor with Validation ---
    function registerDonor(
        BloodType _bloodType, 
        OrganType _organType, 
        string memory _location, 
        address _hospital
    ) external {
        require(!donors[msg.sender].isRegistered, "Already registered as a donor");
        require(_bloodType != BloodType.None, "Invalid blood type");
        require(bytes(_location).length > 0, "Location required");

        donors[msg.sender] = Donor({
            donorAddress: msg.sender,
            bloodType: _bloodType,
            organToDonate: _organType,
            location: _location,
            authorizedHospital: _hospital,
            isRegistered: true
        });

        donorList.push(msg.sender);
        emit DonorRegistered(msg.sender, _bloodType, _organType);
    }

    // --- TASK 3 & 7: Register Recipient with Validation ---
    function registerRecipient(
        address _patient,
        BloodType _bloodType,
        OrganType _neededOrgan,
        uint256 _priority
    ) external onlyHospital {
        require(!recipients[_patient].isRegistered, "Patient already registered");
        require(_priority >= 1 && _priority <= 10, "Priority must be between 1 and 10");

        recipients[_patient] = Recipient({
            recipientAddress: _patient,
            bloodType: _bloodType,
            neededOrgan: _neededOrgan,
            priorityScore: _priority,
            status: Status.Pending,
            isRegistered: true
        });

        recipientList.push(_patient);
        emit RecipientRegistered(_patient, _bloodType, _priority);
    }

    // --- Task 6 Edge Case: Explicitly model Doctor Refusal / Expiry ---
    function updateRecipientStatus(address _patient, Status _newStatus) external onlyHospital {
        require(recipients[_patient].isRegistered, "Patient not found");
        
        // This handles Doctor Refusal or Expiry by setting status to Cancelled or Completed
        recipients[_patient].status = _newStatus;
        
        emit StatusUpdated(_patient, _newStatus);
    }

    // --- TASK 4: View Functions ---
    function getDonorInfo(address _donor) external view returns (Donor memory) {
        return donors[_donor];
    }

    function getRecipientInfo(address _recipient) external view returns (Recipient memory) {
        return recipients[_recipient];
    }

    function getAllDonors() external view returns (address[] memory) {
        return donorList;
    }

    function getAllRecipients() external view returns (address[] memory) {
        return recipientList;
    }
} // This bracket MUST be at the very end of the file