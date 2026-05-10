const contractAddress = "0xe7a503B2f605aD5180BcdcbC05CB5b70a4E36253";
const abi = [
    "function registerDonor(uint8 bloodType, uint8 organType, string location, address hospital) external"
];

let contract;

async function connect() {
    if (window.ethereum) {
        try {
            const provider = new ethers.providers.Web3Provider(window.ethereum);
            await provider.send("eth_requestAccounts", []);
            const signer = provider.getSigner();
            contract = new ethers.Contract(contractAddress, abi, signer);
            document.getElementById("status").innerText = "Connected: " + await signer.getAddress();
            document.getElementById("connectBtn").style.background = "#6c757d";
        } catch (err) {
            document.getElementById("status").innerText = "Error: Connection rejected.";
        }
    } else {
        alert("Please install MetaMask extension!");
    }
}

async function register() {
    if (!contract) {
        alert("Please click 'Connect MetaMask' first!");
        return;
    }

    const blood = document.getElementById("bloodType").value;
    const organ = document.getElementById("organType").value;
    const loc = document.getElementById("location").value;

    try {
        document.getElementById("status").innerText = "🚀 Sending to Sepolia...";
        const tx = await contract.registerDonor(blood, organ, loc, "0x0000000000000000000000000000000000000000");
        document.getElementById("status").innerText = "⏳ Confirming... Hash: " + tx.hash;
        await tx.wait();
        document.getElementById("status").innerHTML = "✅ <b>Success!</b> Donor registered on Blockchain.";
    } catch (err) {
        document.getElementById("status").innerText = "❌ Error: " + (err.reason || "Transaction failed");
    }
}

document.getElementById("connectBtn").onclick = connect;
document.getElementById("registerBtn").onclick = register;