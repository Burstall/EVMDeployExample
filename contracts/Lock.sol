// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

import { IBlast } from "./IBlast.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract Lock is Ownable {
	address public constant BLAST = 0x4300000000000000000000000000000000000002;

    uint256 public unlockTime;
    address payable public depositor;

    event Withdrawal(uint256 amount, uint256 when);

    constructor(uint256 _unlockTime, address initialOwner) payable 
		Ownable(initialOwner)
	{
        require(
            block.timestamp < _unlockTime,
            "Unlock time in past"
        );

		IBlast(BLAST).configureClaimableYield();

        unlockTime = _unlockTime;
        depositor = payable(msg.sender);
    }

    function withdraw() public {
        require(block.timestamp >= unlockTime, "You can't withdraw yet");
        require(msg.sender == depositor, "You aren't the depositor");

        emit Withdrawal(address(this).balance, block.timestamp);

        depositor.transfer(address(this).balance);
    }

	function claimYield(address recipient, uint256 amount) external onlyOwner {
		IBlast(BLAST).claimYield(address(this), recipient, amount);
  	}

	function claimAllYield(address recipient) external onlyOwner {
		IBlast(BLAST).claimAllYield(address(this), recipient);
  	}
}
