# EVMDeployExample

> npm install
rename .env.example to .env (or create one)
update with your private key (please only use a throw away wallet!)
> npx hardhat compile
> node .\scripts\deploy.js

after 10 mins it will be unlocked
> node .\scripts\unlock.js

# On testnet, ETH balances will update hourly at a rate of ~0.01% per day.
If you left your ETH locked for an hour+
> node .\scripts\claimYield.js