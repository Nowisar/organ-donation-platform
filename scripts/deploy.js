const hre = require("hardhat");

async function main() {

    console.log("Starting deployment of OrganRegistration...");
    console.log("--------------------------------------------------");

    // Deploy Registration Contract
    const OrganRegistration = await hre.ethers.getContractFactory(
        "OrganRegistration"
    );

    const registration = await OrganRegistration.deploy();

    await registration.waitForDeployment();

    const registrationAddress = await registration.getAddress();

    console.log(
        `SUCCESS: OrganRegistration deployed to: ${registrationAddress}`
    );

    console.log("--------------------------------------------------");

    console.log("Starting deployment of OrganMatching...");
    console.log("--------------------------------------------------");

    // Deploy Matching Contract
    const OrganMatching = await hre.ethers.getContractFactory(
        "OrganMatching"
    );

    const matching = await OrganMatching.deploy(
        registrationAddress
    );

    await matching.waitForDeployment();

    const matchingAddress = await matching.getAddress();

    console.log(
        `SUCCESS: OrganMatching deployed to: ${matchingAddress}`
    );

    console.log("--------------------------------------------------");

    console.log("DEPLOYMENT COMPLETED SUCCESSFULLY!");
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