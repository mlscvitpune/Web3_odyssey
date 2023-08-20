//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

// import "./ERC_Remote.sol";


 contract Crowdfunding_Remix{

    uint public CampaignCount;
    // IERC20 defines function signatures without specifying behavior; the function names, inputs and outputs, but no process. ERC20 inherits this Interface and is required to implement all the functions described or else the contract will not deploy.

     address immutable owner;

    mapping(uint => mapping(address => uint)) public donatedAmount;
    mapping(uint => Author) public Authors;

    constructor() {
        owner = msg.sender;
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
        Authors[CampaignCount] = Author(msg.sender, CampaignCount, _goal, 0, block.timestamp, block.timestamp + 10000, false);
       
    }


     

    function donate(uint256 _campaignID, uint256 _amount) public payable{
        Author storage AuthorVar = Authors[_campaignID];
        require(AuthorVar.endAt >= block.timestamp, "This Campaign Has been Ended");
        AuthorVar.donatingAmount += _amount;
        
        donatedAmount[_campaignID][msg.sender] += _amount;
           payable(AuthorVar.owner).transfer(address(this).balance);
        
    }

    function unDonate(uint _campaignID, uint _amount) public payable{
        Author storage AuthorVar = Authors[_campaignID];
        
        if(AuthorVar.endAt >= block.timestamp){
            donatedAmount[_campaignID][msg.sender] -= _amount;
            AuthorVar.donatingAmount -= _amount;
            bool sendSuccess= payable(msg.sender).send(address(this).balance * 1e18);
    require(sendSuccess, "Couldn't send the funds");
        }
        else if(AuthorVar.endAt <= block.timestamp) {
            if(AuthorVar.goal >= AuthorVar.donatingAmount){
                donatedAmount[_campaignID][msg.sender] = _amount;
                AuthorVar.donatingAmount -= _amount;
                bool sendSuccess= payable(msg.sender).send(address(this).balance);
    require(sendSuccess, "Couldn't send the funds");

            }
            else{
                revert("Campaign Is Ended");
            }
        }
        else {
            revert("Something went wrong");
        }
    }


    function seeDonatedAmount(uint _campaignID) public view returns(uint){
        Author storage AuthorVar = Authors[_campaignID];
        return AuthorVar.donatingAmount;
    }
}