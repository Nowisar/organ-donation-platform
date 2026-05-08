// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./OrganRegistration.sol";

/**
 * @title Organ Matching & Logic Contract
 * @author Person 2 - Matching Specialist
 */

contract OrganMatching {

    OrganRegistration public registrationContract;

    address public admin;

    enum OrganStatus {
        Available,
        Reserved,
        Transplanted,
        Cancelled,
        Expired
    }

    struct Organ {
        uint256 organId;
        address donor;
        OrganRegistration.OrganType organType;
        OrganRegistration.BloodType bloodType;
        string donorLocation;
        uint256 expiryTime;
        OrganStatus status;
        address matchedRecipient;
    }

    uint256 public organCounter;

    mapping(uint256 => Organ) public organs;

    // =========================
    // EVENTS
    // =========================

    event OrganRegistered(
        uint256 indexed organId,
        address indexed donor,
        OrganRegistration.OrganType organType,
        uint256 expiryTime
    );

    event MatchFound(
        uint256 indexed organId,
        address indexed recipient
    );

    event TransplantConfirmed(
        uint256 indexed organId,
        address indexed recipient
    );

    event DonationCancelled(
        uint256 indexed organId
    );

    event OrganExpired(
        uint256 indexed organId
    );

    // =========================
    // MODIFIERS
    // =========================

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin allowed");
        _;
    }

    modifier organExists(uint256 _organId) {
        require(
            _organId > 0 &&
            _organId <= organCounter,
            "Invalid organ ID"
        );
        _;
    }

    modifier organAvailable(uint256 _organId) {
        require(
            organs[_organId].status ==
            OrganStatus.Available,
            "Organ not available"
        );
        _;
    }

    modifier organNotAllocated(uint256 _organId) {
        require(
            organs[_organId].matchedRecipient ==
            address(0),
            "Organ already allocated"
        );
        _;
    }

    modifier withinTimeLimit(uint256 _organId) {
        require(
            block.timestamp <
            organs[_organId].expiryTime,
            "Organ expired"
        );
        _;
    }

    // =========================
    // CONSTRUCTOR
    // =========================

    constructor(address _registrationContract) {

        require(
            _registrationContract != address(0),
            "Invalid registration contract"
        );

        admin = msg.sender;

        registrationContract =
            OrganRegistration(_registrationContract);
    }

    // =========================
    // TASK 1
    // REGISTER ORGAN
    // =========================

    function registerOrgan(
        address _donor,
        uint256 _validHours
    )
        external
        onlyAdmin
    {

        require(
            _donor != address(0),
            "Invalid donor address"
        );

        require(
            _validHours > 0,
            "Invalid expiry hours"
        );

        (
            address donorAddress,
            OrganRegistration.BloodType bloodType,
            OrganRegistration.OrganType organType,
            string memory location,
            ,
            bool isRegistered

        ) = registrationContract.donors(_donor);

        require(
            isRegistered,
            "Donor not registered"
        );

        organCounter++;

        organs[organCounter] = Organ({
            organId: organCounter,
            donor: donorAddress,
            organType: organType,
            bloodType: bloodType,
            donorLocation: location,
            expiryTime: block.timestamp + (_validHours * 1 hours),
            status: OrganStatus.Available,
            matchedRecipient: address(0)
        });

        emit OrganRegistered(
            organCounter,
            donorAddress,
            organType,
            block.timestamp + (_validHours * 1 hours)
        );
    }

    // =========================
    // TASK 2
    // MATCH ORGAN
    // =========================

    function matchOrgan(
        uint256 _organId,
        address[] calldata _recipientList
    )
        external
        onlyAdmin
        organExists(_organId)
        organAvailable(_organId)
        organNotAllocated(_organId)
        withinTimeLimit(_organId)
        returns(address)
    {

        require(
            _recipientList.length > 0,
            "Recipient list empty"
        );

        Organ storage organ = organs[_organId];

        address bestRecipient = address(0);

        uint256 highestScore = 0;

        for(uint256 i = 0; i < _recipientList.length; i++) {

            address recipientAddress = _recipientList[i];

            (
                ,
                OrganRegistration.BloodType recipientBlood,
                OrganRegistration.OrganType neededOrgan,
                uint256 priority,
                OrganRegistration.Status recipientStatus,
                bool isRegistered

            ) = registrationContract.recipients(
                    recipientAddress
            );

            if(
                isRegistered &&
                recipientStatus ==
                OrganRegistration.Status.Pending &&
                neededOrgan == organ.organType &&
                isCompatible(
                    organ.bloodType,
                    recipientBlood
                )
            ) {

                uint256 score = priority;

                // Higher priority gets selected
                if(score > highestScore) {

                    highestScore = score;

                    bestRecipient = recipientAddress;
                }
            }
        }

        require(
            bestRecipient != address(0),
            "No compatible recipient found"
        );

        organ.status = OrganStatus.Reserved;

        organ.matchedRecipient = bestRecipient;

        emit MatchFound(
            _organId,
            bestRecipient
        );

        return bestRecipient;
    }

    // =========================
    // BLOOD MATCHING LOGIC
    // =========================

    function isCompatible(
        OrganRegistration.BloodType donor,
        OrganRegistration.BloodType recipient
    )
        public
        pure
        returns(bool)
    {

        // Exact match
        if(donor == recipient) {
            return true;
        }

        // Universal donor
        if(
            donor ==
            OrganRegistration.BloodType.O_Minus
        ) {
            return true;
        }

        return false;
    }

    // =========================
    // TASK 3
    // CONFIRM TRANSPLANT
    // =========================

    function confirmTransplant(
        uint256 _organId
    )
        external
        onlyAdmin
        organExists(_organId)
    {

        Organ storage organ = organs[_organId];

        require(
            organ.status ==
            OrganStatus.Reserved,
            "Organ not reserved"
        );

        require(
            organ.matchedRecipient != address(0),
            "No recipient matched"
        );

        organ.status =
            OrganStatus.Transplanted;

        emit TransplantConfirmed(
            _organId,
            organ.matchedRecipient
        );
    }

    // =========================
    // TASK 4
    // CANCEL DONATION
    // =========================

    function cancelDonation(
        uint256 _organId
    )
        external
        onlyAdmin
        organExists(_organId)
    {

        require(
            organs[_organId].status !=
            OrganStatus.Transplanted,
            "Already transplanted"
        );

        organs[_organId].status =
            OrganStatus.Cancelled;

        emit DonationCancelled(
            _organId
        );
    }

    // =========================
    // HANDLE EXPIRED ORGANS
    // =========================

    function markExpired(
        uint256 _organId
    )
        external
        onlyAdmin
        organExists(_organId)
    {

        require(
            block.timestamp >=
            organs[_organId].expiryTime,
            "Still valid"
        );

        organs[_organId].status =
            OrganStatus.Expired;

        emit OrganExpired(_organId);
    }

    // =========================
    // VIEW FUNCTIONS
    // =========================

    function getOrganInfo(
        uint256 _organId
    )
        external
        view
        returns(Organ memory)
    {
        return organs[_organId];
    }

    function getOrganStatus(
        uint256 _organId
    )
        external
        view
        returns(OrganStatus)
    {
        return organs[_organId].status;
    }
}