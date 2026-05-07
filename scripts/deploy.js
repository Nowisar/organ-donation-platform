const hre = require("hardhat");

async function main() {
  console.log("Starting deployment of OrganRegistration...");

  // Get the contract factory
  const OrganRegistration = await hre.ethers.getContractFactory("OrganRegistration");

  // Deploy the contract
  const contract = await OrganRegistration.deploy();

  // Wait for deployment to finish
  await contract.waitForDeployment();

  const address = await contract.getAddress();

  console.log("-----------------------------------------------");
  console.log(`SUCCESS: OrganRegistration deployed to: ${address}`);
  console.log("-----------------------------------------------");
  console.log("SAVE THIS ADDRESS! You need to give it to Person 4 and 5.");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});