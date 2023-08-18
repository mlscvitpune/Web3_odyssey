//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "./ERC_Remote.sol";

contract Crowdfunding{

    uint public CampaignCount;
    IERC20 public token;
    // IERC20 defines function signatures without specifying behavior; the function names, inputs and outputs, but no process. ERC20 inherits this Interface and is required to implement all the functions described or else the contract will not deploy.


    mapping(uint => mapping(address => uint)) public donatedAmount;
    mapping(uint => Author) public Authors;

    constructor(address _token){
        token = IERC20(_token);
    }


    struct Author{
        address owner;
        uint id;
        uint goal;
        uint donatingAmount;
        uint startAt;
        uint endAt;
        bool claimed;
    }

    struct Donor{
        address donor;
        uint campaignID;
        uint amount;
    }

    function creator(uint _goal) public{
        require(_goal > 0, "Goal is not Equal to Zero");
        CampaignCount++;
        Authors[CampaignCount] = Author(msg.sender, CampaignCount, _goal, 0, block.timestamp, block.timestamp + 10, false);

    }

    function donate(uint _campaignID, uint _amount) public payable{
        Author storage AuthorVar = Authors[_campaignID];
        require(AuthorVar.endAt == block.timestamp, "This Campaign Has been Ended");
        AuthorVar.donatingAmount += _amount;

        donatedAmount[_campaignID][msg.sender] += _amount;
        token.transferFrom(msg.sender, address(this), _amount);
    }
}