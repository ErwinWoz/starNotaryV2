pragma solidity >=0.4.24;

import "../node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";

contract StarNotary is ERC721 {

    struct Star {
        string name;
    }

    // Add a name and a symbol for your starNotary tokens
    string public constant name = "Star Token";
    string public constant symbol = "SRTN";

    mapping(uint256 => Star) public tokenIdToStarInfo;
    mapping(uint256 => uint256) public starsForSale;


    // Create Star using the Struct
    function createStar(string memory _name, uint256 _tokenId) public { // Passing the name and tokenId as a parameters
        Star memory newStar = Star(_name); // Star is an struct so we are creating a new Star
        tokenIdToStarInfo[_tokenId] = newStar; // Creating in memory the Star -> tokenId mapping
        _mint(msg.sender, _tokenId); // _mint assign the the star with _tokenId to the sender address (ownership)
    }

    // Putting an Star for sale (Adding the star tokenid into the mapping starsForSale, first verify that the sender is the owner)
    function putStarUpForSale(uint256 _tokenId, uint256 _price) public {
        require(ownerOf(_tokenId) == msg.sender, "You can't sale the Star you don't owned");
        starsForSale[_tokenId] = _price;
    }


    // Function that allows you to convert an address into a payable address
    function _make_payable(address x) internal pure returns (address payable) {
        return address(uint160(x));
    }

    function buyStar(uint256 _tokenId) public  payable {
        require(starsForSale[_tokenId] > 0, "The Star should be up for sale");
        uint256 starCost = starsForSale[_tokenId];
        address ownerAddress = ownerOf(_tokenId);
        require(msg.value > starCost, "You need to have enough Ether");
        _transferFrom(ownerAddress, msg.sender, _tokenId); // We can't use _addTokenTo or_removeTokenFrom functions, now we have to use _transferFrom
        address payable ownerAddressPayable = _make_payable(ownerAddress); // We need to make this conversion to be able to use transfer() function to transfer ethers
        ownerAddressPayable.transfer(starCost);
        if(msg.value > starCost) {
            msg.sender.transfer(msg.value - starCost);
        }
    }

    // Task 1. Add functions: 
    // lookUptokenIdToStarInfo()
    // exchangeStars()
    // transferStar()


    function lookUptokenIdToStarInfo(uint _tokenId) public view returns (string memory) {
        return tokenIdToStarInfo[_tokenId].name;
    }

    function exchangeStars(uint256 _tokenId1, uint256 _tokenId2) public {
        require(ownerOf(_tokenId1) == msg.sender || ownerOf(_tokenId2) == msg.sender, "You can't exchange star you don't own");
        address address1 = ownerOf(_tokenId1);
        address address2 = ownerOf(_tokenId2);

        // function transferFrom requires the msg.sender to be the owner, approved, or operator.
        _transferFrom(address1, address2, _tokenId1);
        _transferFrom(address2, address1, _tokenId2);
    }  

    function transferStar(address _to1, uint256 _tokenId) public {
        require(ownerOf(_tokenId) == msg.sender, "You can't transfer star you don't own");
        transferFrom(msg.sender, _to1, _tokenId);
    }
}