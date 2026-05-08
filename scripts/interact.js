const hre = require("hardhat");

async function main() {
  // عنوان العقد الذي تم رفعه مسبقاً (شغل Person 2)
  const contractAddress = "0xe7a503B2f605aD5180BcdcbC05CB5b70a4E36253"; 
  
  const OrganRegistration = await hre.ethers.getContractFactory("OrganRegistration");
  const reg = await OrganRegistration.attach(contractAddress);

  console.log("--- Starting Interaction on Sepolia ---");
  console.log("Sending Transaction: Registering Donor...");

  // تسجيل متبرع (فصيلة دم 1، نوع عضو 1، القاهرة، بدون مستشفى حالياً)
  const tx = await reg.registerDonor(1, 1, "Cairo, Egypt", "0x0000000000000000000000000000000000000000");
  
  console.log("Transaction sent! Waiting for block confirmation...");
  
  const receipt = await tx.wait();

  console.log("-----------------------------------------");
  console.log("SUCCESS! Donor Registered on Blockchain.");
  console.log("Transaction Hash:", tx.hash);
  console.log("-----------------------------------------");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});