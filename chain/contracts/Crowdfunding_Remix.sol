// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;


contract CrowdFunding{

    uint public CampignCount;

    mapping(uint => mapping(address => uint)) public pledgedAmount;
    mapping (uint => Author) public Authors;
     
    constructor(address _token){
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

    struct Donater{
        address donater;
        uint compaignID;
        uint amount;
    }
 
 
    function creator(uint _goal)public{

      require(_goal > 0 , "Goal is not Equal to Zero");
      CampignCount++;
      Authors[CampignCount] = Author(msg.sender , CampignCount , _goal , 0 ,block.timestamp , block.timestamp + 10000 ,false);
    }

    function payContract() public payable{

    }

    function payUser() public payable{
        payable(msg.sender).transfer(1 ether);
    }
// Donateing Money
    function donate(uint _compaignID , uint _amount ) public payable{
        Author storage AuthorVar = Authors[_compaignID];
        require(AuthorVar.endAt >= block.timestamp ,"This Compaign Has been Ended");
        AuthorVar.donatingAmount +=_amount;     

        pledgedAmount[_compaignID][msg.sender] += _amount;
        
    }

// Donater withdraw money they are not donating 
    function unDonate(uint _compaignID , uint _amount )public{
        Author storage AuthorVar = Authors[_compaignID];

        if(AuthorVar.endAt >= block.timestamp ){
             pledgedAmount[_compaignID][msg.sender] -= _amount;
             AuthorVar.donatingAmount -=_amount; 
            payable(msg.sender).transfer(_amount);
        
            }
        else if(AuthorVar.endAt <= block.timestamp ) {
            if(AuthorVar.goal >= AuthorVar.donatingAmount){
               pledgedAmount[_compaignID][msg.sender] -= _amount;
               AuthorVar.donatingAmount -=_amount; 
               payable(msg.sender).transfer(_amount);
            }
            else{
                revert("Campign Is Ended");
            }
        }else{
            revert("Something went wrong 2");
        }       
    
    
    }

   function claim(uint _compaignID )public {
               Author storage AuthorVar = Authors[_compaignID];
               require(msg.sender == AuthorVar.owner , "only Owner Can Claim");
               require(block.timestamp > AuthorVar.endAt , "Not ended ");
               require(AuthorVar.donatingAmount >= AuthorVar.goal , "Goal Not Completed");
               require(!AuthorVar.claimed ," Already claimed ");
               AuthorVar.claimed =true;

              payable(AuthorVar.owner).transfer(AuthorVar.donatingAmount);

    }

}