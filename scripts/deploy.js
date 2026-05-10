import hre from "hardhat";

async function main() {
    console.log("Starting deployment of OrganDonationNFT (Person 3)...");
    console.log("--------------------------------------------------");

    // 1. Deploy NFT Contract
    const OrganDonationNFT = await hre.ethers.getContractFactory("OrganDonationNFT");
    const nft = await OrganDonationNFT.deploy();
    await nft.waitForDeployment();
    const nftAddress = await nft.getAddress();
    console.log(`SUCCESS: OrganDonationNFT deployed to: ${nftAddress}`);
    console.log("--------------------------------------------------");

    console.log("Starting deployment of OrganRegistration (Person 1)...");
    console.log("--------------------------------------------------");

    // 2. Deploy Registration Contract
    const OrganRegistration = await hre.ethers.getContractFactory("OrganRegistration");
    const registration = await OrganRegistration.deploy();
    await registration.waitForDeployment();
    const registrationAddress = await registration.getAddress();
    console.log(`SUCCESS: OrganRegistration deployed to: ${registrationAddress}`);
    console.log("--------------------------------------------------");

    console.log("Starting deployment of OrganMatching (Person 2)...");
    console.log("--------------------------------------------------");

    // 3. Deploy Matching Contract
    const OrganMatching = await hre.ethers.getContractFactory("OrganMatching");
    const matching = await OrganMatching.deploy(registrationAddress);
    await matching.waitForDeployment();
    const matchingAddress = await matching.getAddress();
    console.log(`SUCCESS: OrganMatching deployed to: ${matchingAddress}`);
    console.log("--------------------------------------------------");

    console.log("Setting Minter Permissions for Registration and Matching...");
    console.log("--------------------------------------------------");
    
    // 4. إعطاء صلاحيات الـ Minting للكونتراكتات التانية
    let tx1 = await nft.setMinter(registrationAddress, true);
    await tx1.wait();
    console.log("SUCCESS: Minter role assigned to OrganRegistration");

    let tx2 = await nft.setMinter(matchingAddress, true);
    await tx2.wait();
    console.log("SUCCESS: Minter role assigned to OrganMatching");
    console.log("--------------------------------------------------");

    console.log("🎉 DEPLOYMENT COMPLETED SUCCESSFULLY!");
    console.log("--------------------------------------------------");
    console.log("NFT Contract Address (Person 3):");
    console.log(nftAddress);
    console.log("--------------------------------------------------");
    console.log("Registration Contract Address:");
    console.log(registrationAddress);
    console.log("--------------------------------------------------");
    console.log("Matching Contract Address:");
    console.log(matchingAddress);
    console.log("--------------------------------------------------");
    console.log("SAVE THESE ADDRESSES FOR:");
    console.log("- Person 4 (Testing)");
    console.log("- Person 5 (Report & Slither)");
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});