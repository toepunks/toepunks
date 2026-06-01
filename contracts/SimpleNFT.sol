// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleNFT {
    string public name = "ToePunks";
    string public symbol = "TOEPUNKS";
    string public baseURI = "ipfs://__CID__/";
    
    mapping(address => uint256) public balanceOf;
    mapping(uint256 => address) public ownerOf;
    mapping(uint256 => string) public tokenURI;
    
    uint256 public totalSupply = 0;
    uint256 public maxSupply = 10000;
    uint256 public mintPrice = 0.01 ether;
    
    bool public mintOpen = false;
    address public owner;
    
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    
    constructor() {
        owner = msg.sender;
    }
    
    function setBaseURI(string calldata _newURI) external {
        require(msg.sender == owner);
        baseURI = _newURI;
    }
    
    function setMintPrice(uint256 _price) external {
        require(msg.sender == owner);
        mintPrice = _price;
    }
    
    function setMintOpen(bool _open) external {
        require(msg.sender == owner);
        mintOpen = _open;
    }
    
    function mint(uint256 quantity) external payable {
        require(mintOpen, "Mint not open");
        require(quantity > 0 && quantity <= 10, "Max 10 per tx");
        require(msg.value >= mintPrice * quantity, "Insufficient payment");
        require(totalSupply + quantity <= maxSupply, "Exceeds max supply");
        
        for (uint256 i = 0; i < quantity; i++) {
            uint256 tokenId = totalSupply + i;
            ownerOf[tokenId] = msg.sender;
            tokenURI[tokenId] = string(abi.encodePacked(baseURI, tokenId, ".json"));
            emit Transfer(address(0), msg.sender, tokenId);
        }
        
        balanceOf[msg.sender] += quantity;
        totalSupply += quantity;
    }
    
    function tokenUri(uint256 tokenId) external view returns (string memory) {
        require(ownerOf[tokenId] != address(0), "Token does not exist");
        return tokenURI[tokenId];
    }
    
    function withdraw() external {
        require(msg.sender == owner);
        payable(owner).transfer(address(this).balance);
    }
}