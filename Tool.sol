pragma solidity ^0.4.20;

contract Ownable {
    // replace with proper zeppelin smart contract
    address public owner;

    function Ownable() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner != address(0))
            owner = newOwner;
    }
}

contract Destructable is Ownable {
    function selfdestruct() external onlyOwner {
        // free ethereum network state when done
        selfdestruct(owner);
    }
}

contract Status is Ownable{

    bool public status;

    function Status() public {
        status = true;
    }

    modifier checkStatus() {
        require(status == true);
        _;
    }

    function unlockContract() external onlyOwner {
        status = true;
    }

    function lockContract() external onlyOwner {
        status = false;
    }

}

contract Math {
    // scale of the emulated fixed point operations
    uint public FP_SCALE = 10000;

    // todo: should be a library
    function divRound(uint v, uint d) internal view returns(uint) {
      // round up if % is half or more
        return (v + (d/2)) / d;
    }

    function absDiff(uint v1, uint v2) public view returns(uint) {
        return v1 > v2 ? v1 - v2 : v2 - v1;
    }

    function safeMul(uint a, uint b) public view returns (uint) {
        uint c = a * b;
        require(a == 0 || c / a == b);
        return c;
    }

    function safeAdd(uint a, uint b) internal view returns (uint) {
        uint c = a + b;
        require(c>=a && c>=b);
        return c;
    }
}

contract Whitelist is Status{
    mapping (address => uint) whitelist;

    function addWhiteList (address _user, uint _amount) public onlyOwner checkStatus {
        whitelist[_user] = _amount;
    }

    function removeWhiteList (address _user) public onlyOwner checkStatus {
        delete whitelist[_user];
    }

    function isAllowTransfer(address _user) public view returns (bool) {
        return whitelist[_user] == 0 ? false : true;
    }

    function getAllowAmount(address _user) public view returns (uint) {
        return whitelist[_user];
    }
}

