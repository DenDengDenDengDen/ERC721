// SPDX-License-Identifier: MIT
pragma solidity >=0.8.6;

contract TTTNFT{
    uint public totalSupply;
    string private _name;
    string private _symbol;
    uint public _id = 0;

    mapping(address => uint) balances;
    mapping(uint => address) tokenOwners;
    mapping(uint => bool) tokenExists;
    mapping(address => mapping(address => uint256)) allowed;

    event Transfer(address indexed from, address indexed to, uint indexed tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint indexed _tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    constructor(string memory name_, string memory symbol_){
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function createBEV(address _owner)public{
        totalSupply++;
        _id += 1;
        balances[_owner] += 1;
        tokenExists[_id] = true;
        tokenOwners[_id] = _owner;
        emit Transfer(address(0), _owner, _id);
    }

    function ownerTokens(address _owner)view public returns(uint[] memory _tokenIds){
        _tokenIds = new uint[](balances[_owner]);
        uint count = 0;
        for(uint i=1; i<=_id; i++){
            if(tokenOwners[i] == _owner){
                _tokenIds[count] = i;
                count++;
            }
        }
    }

    function balanceOf(address _owner)public view returns(uint _balance){
        return balances[_owner];
    }

    function ownerOf(uint _tokenId)public view returns(address _owner){
        require(tokenExists[_tokenId]);
        return tokenOwners[_tokenId];
    }

    function transfer(address _to, uint _tokenId)public {
        address currentOwner = msg.sender;
        address newOwner = _to;
        require(tokenExists[_tokenId]);
        require(currentOwner == tokenOwners[_tokenId]);
        require(newOwner != address(0));

        tokenOwners[_tokenId] = newOwner;
        balances[currentOwner] -= 1;
        balances[newOwner] += 1;

        emit Transfer(currentOwner, newOwner, _tokenId);
    }

    function approve(address _to, uint _tokenId)public{
        require(msg.sender == ownerOf(_tokenId), "this token is't your");
        require(msg.sender != _to);

        allowed[msg.sender][_to] = _tokenId;
        emit Approval(msg.sender, _to, _tokenId);
    }

    function takeOwnership(uint _tokenId)public{
        require(tokenExists[_tokenId]);

        address oldOwner = ownerOf(_tokenId);
        address newOwner = msg.sender;

        require(newOwner != oldOwner);
        require(allowed[oldOwner][newOwner] == _tokenId);

        balances[oldOwner] -= 1;
        tokenOwners[_tokenId] = newOwner;
        balances[newOwner] += 1;
        allowed[oldOwner][newOwner] = 0;
        emit Transfer(oldOwner, newOwner, _tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view returns (bool) {
        return true;
    }
}