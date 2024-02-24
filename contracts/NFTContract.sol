// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import {IBlast} from "./IBlast.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {ERC721Pausable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721Burnable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

/// @custom:security-contact stowerling@duck.com
contract NFTContract is ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Pausable, Ownable, ERC721Burnable {
    uint256 private _nextTokenId;

	IBlast public constant BLAST = IBlast(0x4300000000000000000000000000000000000002);
	address public lastUser;

    constructor(address initialOwner)
        ERC721("CAPToken", "CAPT")
        Ownable(initialOwner)
    {
		lastUser = initialOwner;
		BLAST.configureClaimableGas(); 
		BLAST.configureClaimableYield();
	}

	modifier rebateGas() {
		BLAST.claimAllGas(address(this), lastUser);
		lastUser = msg.sender;
		_;
	}

	function _baseURI() internal pure override returns (string memory) {
        return "ipfs://bafybeigr6eynpmqlcjevlb5b4d2c2goxforj6f2qyewyhxazutme3w2jki/";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

	function safeTransferFrom(address from, address to, uint256 tokenId) public override(ERC721, ERC721Pausable) rebateGas() {
		super.safeTransferFrom(from, to, tokenId);
	}

	function approve(address to, uint256 tokenId) public override(ERC721, ERC721Pausable) rebateGas() {
		super.approve(to, tokenId);
	}

	function setApprovalForAll(address operator, bool approved) public override(ERC721, ERC721Pausable) rebateGas() {
		super.setApprovalForAll(operator, approved);
	}

	function transferFrom(address from, address to, uint256 tokenId) public override(ERC721, ERC721Pausable) rebateGas() {
		super.transferFrom(from, to, tokenId);
	}

    function safeMint(address to, string memory uri) public onlyOwner rebateGas {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

	function paidMint(address to, uint256 quantity) public payable rebateGas {
		require(msg.value >= quantity * 0.1 ether, "Insufficient payment");
		for (uint256 i = 0; i < quantity; i++) {
			uint256 tokenId = _nextTokenId++;
			_safeMint(to, tokenId);
		}
	}

    // The following functions are overrides required by Solidity.

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable, ERC721Pausable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

	function claimMyContractsGas() external onlyOwner {
    	BLAST.claimAllGas(address(this), msg.sender);
  	}

}

