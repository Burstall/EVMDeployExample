require("dotenv").config();
const ethers = require('ethers'); // ethers v6
const fs = require('fs');
const url = 'https://sepolia.blast.io';
const provider = new ethers.JsonRpcProvider(url);

async function main() {
	const wallet = new ethers.Wallet(process.env.BLAST_TESTNET_PRIVATE_KEY, provider);
	provider.getBalance(wallet.address).then((balance) => {
		console.log("Address: " + wallet.address);
		console.log("Start Balance: " + ethers.formatEther(balance) + " ETH");
	});

	await sleep(1000);

	const json = JSON.parse(fs.readFileSync("artifacts/contracts/NFTContract.sol/NFTContract.json"));
	const bytecode = json.bytecode;
	const abi = json.abi;


	const NFTContract = new ethers.ContractFactory(abi, bytecode, wallet);

	const nftContract = await NFTContract.attach(process.env.NFTContract);

	await nftContract.safeMint(wallet.address, 'metadataUR2.json');
}

async function sleep(ms) {
	return new Promise((resolve) => {
		setTimeout(resolve, ms);
	});
}

main().catch((error) => {
	console.error(error);
	process.exitCode = 1;
});
