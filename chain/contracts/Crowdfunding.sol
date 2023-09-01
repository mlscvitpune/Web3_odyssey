//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "./ERC_Remote.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Crowdfunding is ReentrancyGuard{

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

    event Donate(address indexed _from, uint value);
    event UnDonate(address indexed _from, uint _campaignId, uint _amount);

    function creator(uint _goal) public{
        require(_goal > 0, "Goal is not Equal to Zero");
        CampaignCount++;
        Authors[CampaignCount] = Author(msg.sender, CampaignCount, _goal, 0, block.timestamp, block.timestamp + 10000, false);

    }

    function donate(uint _campaignID, uint _amount) public payable{
        Author storage AuthorVar = Authors[_campaignID];
        require(msg.sender != Authors[_campaignID].owner, "Owner can not donate to his campaign");

        require(AuthorVar.endAt >= block.timestamp, "This Campaign Has been Ended");
        AuthorVar.donatingAmount += _amount;

        donatedAmount[_campaignID][msg.sender] += _amount;
        token.transferFrom(msg.sender, address(this), _amount);

        emit Donate(msg.sender, _amount);
    }

    function unDonate(uint _campaignID, uint _amount) public {
        Author storage AuthorVar = Authors[_campaignID];
        
        if(AuthorVar.endAt >= block.timestamp){
            donatedAmount[_campaignID][msg.sender] -= _amount;
            AuthorVar.donatingAmount -= _amount;
            token.transfer(msg.sender, _amount);
        }
        else if(AuthorVar.endAt <= block.timestamp) {
            if(AuthorVar.goal >= AuthorVar.donatingAmount){
                donatedAmount[_campaignID][msg.sender] = _amount;
                AuthorVar.donatingAmount -= _amount;
                token.transfer(msg.sender, _amount);

                emit UnDonate(msg.sender, _campaignID, _amount);

            }
            else{
                revert("Campaign Is Ended");
            }
        }
        else {
            revert("Something went wrong");
        }
    }

    function claim(uint _campaignID) public nonReentrant{
        Author storage AuthorVar = Authors[_campaignID];
        require(msg.sender == AuthorVar.owner, "only owner can claim");
        require(block.timestamp > AuthorVar.endAt, "Not Ended");
        require(AuthorVar.donatingAmount >= AuthorVar.goal, "Goal not completed");
        require(!AuthorVar.claimed, " Already claimed ");
        token.transfer(AuthorVar.owner, AuthorVar.donatingAmount);
    }
}