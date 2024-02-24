require("dotenv").config();
const ethers = require('ethers'); // ethers v6
const fs = require('fs');
const url = 'https://sepolia.blast.io';
const provider = new ethers.JsonRpcProvider(url);
// const url = `https://sepolia.infura.io/v3/${process.env.INFURA_KEY}`;
// const provider = new ethers.JsonRpcProvider(url);

async function main() {
	const wallet = new ethers.Wallet(process.env.BLAST_TESTNET_PRIVATE_KEY, provider);
	provider.getBalance(wallet.address).then((balance) => {
		console.log("Address: " + wallet.address);
		console.log("Start Balance: " + ethers.formatEther(balance) + " ETH");
	});

	await sleep(1000);

	const json = JSON.parse(fs.readFileSync("artifacts/contracts/Lock.sol/Lock.json"));
	const bytecode = json.bytecode;
	const abi = json.abi;

	const currentTimestampInSeconds = Math.round(Date.now() / 1000);
	const unlockTime = currentTimestampInSeconds + 600;

	const lockedAmount = ethers.parseEther("0.05");

	const Lock = new ethers.ContractFactory(abi, bytecode, wallet);

	const lock = await Lock.deploy(
		unlockTime, lock.target,
		{
			value: lockedAmount,
		}
	);

	console.log(
		`Lock with ${ethers.formatEther(
			lockedAmount
		)}ETH and unlock timestamp ${unlockTime} deployed to ${lock.target}`
	);
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
