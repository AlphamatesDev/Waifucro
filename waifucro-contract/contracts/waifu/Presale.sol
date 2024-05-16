//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Presale is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable {

    IERC20 public saleTokenAddress;

    uint256 public timeToStart;
    uint256 public timeToEnd;
    uint256 public timeToClaim;

    uint256 public minimumCROAmount;

    uint256 public amtAllToken;
    uint256 public croTotal;

    mapping(address => uint256) public userDeposited;
    mapping(address => bool) public userClaimed;

    event DepositCRO(address _from, uint256 _amount);
    event ClaimToken(address _user, uint256 _amount);

    receive() payable external {}
    fallback() payable external {}

    function initialize() public initializer {
        __Ownable_init();

        // saleTokenAddress = IERC20(0x932B8a352375c4A2Cd95Af3DB1A567E24A871791); //Main Network
        saleTokenAddress = IERC20(0xa2BdEd4913f74C4ffE8E64784D1DEC112fe94F6F); //Test Network

        timeToStart = 1716451200; // May 23th, 10:00AM CET
        timeToEnd = 1716537600; // May 24th, 10:00AM CET
        timeToClaim = 1716541200; // May 24th, 11:00AM CET

        minimumCROAmount = 200000000000000000000;

        amtAllToken = 6000000000000000000000000000;
        croTotal = 0;
    }

    function depositCRO() external nonReentrant payable {
        require(block.timestamp >= timeToStart && block.timestamp <= timeToEnd, "Presale: Not presale period");

        require(msg.value >= minimumCROAmount, "Invalid request: minimum deposit amount is 200 CRO");

        userDeposited[msg.sender] += msg.value;
        croTotal += msg.value;

        emit DepositCRO(msg.sender, msg.value);
    }

    function claimToken() external {
        require(block.timestamp > timeToClaim, "Presale: Invalid claim time!");
        require(userDeposited[msg.sender] > 0, "Presale: Invlaid claim amount!");
        require(userClaimed[msg.sender] == false, "Presale: Already claimed!");

        uint256 amtClaimable = amtAllToken * userDeposited[msg.sender] / croTotal;

        saleTokenAddress.transfer(msg.sender, amtClaimable);

        emit ClaimToken(msg.sender, amtClaimable);

        userClaimed[msg.sender] = true;
    }

    function withdrawAll() external onlyOwner {
        require(block.timestamp > timeToEnd);

        uint256 CRObalance = address(this).balance;
        
        if (CRObalance > 0)
            payable(owner()).transfer(CRObalance);
    }

    function withdrawToken() public onlyOwner returns (bool) {
        require(block.timestamp > timeToEnd);

        uint256 balance = saleTokenAddress.balanceOf(address(this));
        return saleTokenAddress.transfer(msg.sender, balance);
    }

    function setTimeToStart(uint256 _timeToStart) public onlyOwner {
        timeToStart = _timeToStart;
    }

    function setTimeToEnd(uint256 _timeToEnd) public onlyOwner {
        timeToEnd = _timeToEnd;
    }

    function setTimeToClaim(uint256 _timeToClaim) public onlyOwner {
        timeToClaim = _timeToClaim;
    }

    function setSaleTokenAddress(address _address) public onlyOwner {
        saleTokenAddress = IERC20(_address);
    }

    function setAmtAllToken(uint256 _amtAllToken) public onlyOwner {
        amtAllToken = _amtAllToken;
    }

    function getClaimableToken() public view returns(uint256) {
        return amtAllToken * userDeposited[msg.sender] / croTotal;
    }
}