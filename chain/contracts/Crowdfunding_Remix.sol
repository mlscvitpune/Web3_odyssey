// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;


contract CrowdFunding{

    uint public CampignCount;

    mapping(uint => mapping(address => uint)) public pledgedAmount;
    mapping (uint => Creater) public Creaters;
     
    constructor(address _token){
    }


    struct Creater{
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
 
 
    function creater(uint _goal)public{
      require(_goal > 0 , "Goal is not Equal to Zero");
      CampignCount++;
      Creaters[CampignCount] = Creater(msg.sender , CampignCount , _goal , 0 ,block.timestamp , block.timestamp + 10000 ,false);
    }

    function payContract() public payable{

    }

    function payUser() public payable{
        payable(msg.sender).transfer(1 ether);
    }
// Donateing Money
    function pledge(uint _compaignID , uint _amount ) public payable{
        Creater storage CreaterVar = Creaters[_compaignID];
        require(CreaterVar.endAt >= block.timestamp ,"This Compaign Has been Ended");
        CreaterVar.donatingAmount +=_amount;     

        pledgedAmount[_compaignID][msg.sender] += _amount;
        
    }

// Donater withdraw money they are not donating 
    function unplege(uint _compaignID , uint _amount )public{
        Creater storage CreaterVar = Creaters[_compaignID];

        if(CreaterVar.endAt >= block.timestamp ){
             pledgedAmount[_compaignID][msg.sender] -= _amount;
             CreaterVar.donatingAmount -=_amount; 
            payable(msg.sender).transfer(_amount);
        
            }
        else if(CreaterVar.endAt <= block.timestamp ) {
            if(CreaterVar.goal >= CreaterVar.donatingAmount){
               pledgedAmount[_compaignID][msg.sender] -= _amount;
               CreaterVar.donatingAmount -=_amount; 
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
               Creater storage CreaterVar = Creaters[_compaignID];
               require(msg.sender == CreaterVar.owner , "only Owner Can Claim");
            //    require(block.timestamp > CreaterVar.endAt , "Not ended ");
            //    require(CreaterVar.donatingAmount >= CreaterVar.goal , "Goal Not Completed");
            //    require(!CreaterVar.claimed ," Already claimed ");
               CreaterVar.claimed =true;

              payable(CreaterVar.owner).transfer(CreaterVar.donatingAmount);

    }

}