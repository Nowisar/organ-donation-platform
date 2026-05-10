// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract OrganDonationNFT is ERC721, Ownable {
    using Strings for uint256;

    uint256 private _nextTokenId;

    // Struct لحفظ بيانات الشهادة
    struct CertData {
        string certType; // "Donor" or "Recipient"
        string organType;
        string date;
        string hospital;
    }

    mapping(uint256 => CertData) public certificateDetails;
    
    // تحديد الكونتراكتس اللي مسموح ليها تعمل Mint (زي كونتراكت 1 و 2)
    mapping(address => bool) public authorizedMinters;

    event MinterAdded(address minter);
    event MinterRemoved(address minter);

    constructor() ERC721("OrganDonationCert", "ODC") Ownable(msg.sender) {
        _nextTokenId = 1;
    }

    modifier onlyMinter() {
        require(authorizedMinters[msg.sender] || msg.sender == owner(), "Not authorized to mint");
        _;
    }

    // دالة لإضافة كونتراكت التسجيل والمطابقة كـ Minters معتمدين
    function setMinter(address minter, bool status) external onlyOwner {
        authorizedMinters[minter] = status;
        if (status) emit MinterAdded(minter);
        else emit MinterRemoved(minter);
    }

    // Task 2: دالة إصدار شهادة للمتبرع
    function mintDonorNFT(
        address to,
        string memory _organType,
        string memory _date,
        string memory _hospital
    ) external onlyMinter returns (uint256) {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);

        certificateDetails[tokenId] = CertData({
            certType: "Donor Certificate",
            organType: _organType,
            date: _date,
            hospital: _hospital
        });

        return tokenId;
    }

    // Task 3: دالة إصدار شهادة للمريض بعد الزرع
    function mintTransplantNFT(
        address to,
        string memory _organType,
        string memory _date,
        string memory _hospital
    ) external onlyMinter returns (uint256) {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);

        certificateDetails[tokenId] = CertData({
            certType: "Transplant Certificate",
            organType: _organType,
            date: _date,
            hospital: _hospital
        });

        return tokenId;
    }

    // Task 5: تطبيق Soulbound Logic عشان الشهادة متتنقلش
    function _update(address to, uint256 tokenId, address auth) internal virtual override returns (address) {
        address from = _ownerOf(tokenId);
        // السماح بالـ Minting والـ Burning فقط، ومنع الـ Transfer بين المحافظ
        require(from == address(0) || to == address(0), "Soulbound: Certificate is non-transferable");
        return super._update(to, tokenId, auth);
    }

    // Task 4: On-chain SVG Metadata
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_ownerOf(tokenId) != address(0), "ERC721Metadata: URI query for nonexistent token");

        CertData memory data = certificateDetails[tokenId];

        // تصميم SVG للشهادة بتدرجات الـ Pink والـ Purple
        string memory svg = string(abi.encodePacked(
            '<svg width="400" height="400" xmlns="http://www.w3.org/2000/svg">',
            '<defs>',
            '<linearGradient id="grad" x1="0%" y1="0%" x2="100%" y2="100%">',
            '<stop offset="0%" style="stop-color:#ff9a9e;stop-opacity:1" />',
            '<stop offset="100%" style="stop-color:#fecfef;stop-opacity:1" />',
            '</linearGradient>',
            '</defs>',
            '<rect width="100%" height="100%" rx="15" fill="url(#grad)" />',
            '<text x="50%" y="20%" font-size="28" fill="#6a0572" text-anchor="middle" font-family="Arial, sans-serif" font-weight="bold">', data.certType, '</text>',
            '<text x="50%" y="45%" font-size="20" fill="#6a0572" text-anchor="middle" font-family="Arial, sans-serif">Organ: ', data.organType, '</text>',
            '<text x="50%" y="60%" font-size="20" fill="#6a0572" text-anchor="middle" font-family="Arial, sans-serif">Hospital: ', data.hospital, '</text>',
            '<text x="50%" y="75%" font-size="20" fill="#6a0572" text-anchor="middle" font-family="Arial, sans-serif">Date: ', data.date, '</text>',
            '</svg>'
        ));

        // تحويل الـ JSON والـ SVG لـ Base64
        string memory json = Base64.encode(
            bytes(string(abi.encodePacked(
                '{"name": "', data.certType, ' #', tokenId.toString(), '",',
                '"description": "Organ Donation Soulbound Certificate",',
                '"image": "data:image/svg+xml;base64,', Base64.encode(bytes(svg)), '"}'
            )))
        );

        return string(abi.encodePacked("data:application/json;base64,", json));
    }
}