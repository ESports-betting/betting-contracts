// SPDX-License-Identifier: MIT

pragma solidity >=0.5.16;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";

contract Bet {
  using SafeMath for uint256;

  address payable public owner;
  uint256 public pot;
  uint256 public minimumBet;
  uint SetWinner = 0;

  enum BettingStatus { Not_started, Started, Finished }
  BettingStatus public betStatus;
  uint startedTimestamp;
  uint public avaiableSeconds = 60;

  struct Payment {
      uint amount;
      uint timestamp;
  }

  struct Player  {
    uint entry;
    uint256 amountBet;
    uint numPayments;
    bool teamA;
    bool teamB;
    bool collect;
    mapping(uint => Payment) payments; // maps the payments to unassigned integers . a counter
  }

  address public tokenAddress;

  mapping (address => Player) public playerBet; //mapping adddress to the (struct)balance)

  event BetPlayer(address indexed _from, uint256 _amount, uint player);
  event PaymentSent(address _from, uint _amount);
  event CheckWinner(uint _winner);
  event CheckBool(bool _team);
  event AvailableSecondsChanged(uint oldSeconds, uint newSeconds);

  constructor(address token) public {
    owner = msg.sender;
    tokenAddress = token;
    betStatus = BettingStatus.Not_started;

    minimumBet = 2000000000000000000;
    pot = 2000000000000000000;
  }

  function startBetting(uint256 amount) public {
    require(
      amount >= minimumBet,
      "POT value needs 2 tokens at least"
    );

    betStatus = BettingStatus.Started;
    pot = amount;
    startedTimestamp = now;
    SetWinner = 0;
  }

  function betPlayer(uint player) public {
    require(
      betStatus == BettingStatus.Started,
      "Betting is not started"
    );
    require(
      IERC20(tokenAddress).balanceOf(msg.sender) >= pot,
      "Insufficent token balance for betting"
    );
    require(
      player == 1 || player == 2,
      "Invalid player value"
    );
    require(
      startedTimestamp + avaiableSeconds * 1 seconds >= now,
      "You are late for betting"
    );            

    IERC20(tokenAddress).transferFrom(
      msg.sender,
      address(this),
      pot
    );

    emit BetPlayer(msg.sender, pot, player);

    //records memory of payment made and timestamp
    Payment memory payment = Payment(pot, now); //creating a new payment (stored in memory, msg.value amount sent / not --> gives current timestamp / Type payment created)
    playerBet[msg.sender].payments[playerBet[msg.sender].numPayments] = payment; //balanceReceived[by the address]--> calls payments[track what i just received from sender].numPayments(calls the struct to register that as payment= payment)

    playerBet[msg.sender].teamA = true;
    playerBet[msg.sender].entry = 1;
  }

  function makeWinner(uint player) public {
    require(
      msg.sender == owner, "Not the owner"
    );
    require(
      player == 1 || player == 2,
      "Invalid player value"
    );    
    SetWinner = player;
    betStatus = BettingStatus.Finished;

    emit CheckWinner(player);
  }

  function setAvailableSeconds(uint newSeconds) public {
    uint oldValue = avaiableSeconds;
    avaiableSeconds = newSeconds;
    emit AvailableSecondsChanged(oldValue, newSeconds);
  }

  function payouts() public {
    require(playerBet[msg.sender].entry == SetWinner, "You did not win");
    require(playerBet[msg.sender].collect == false, "You already collected your winnings");
    uint256 withdrawAmount = pot.mul(2);
    require(
      IERC20(tokenAddress).balanceOf(address(this)) >= withdrawAmount.mul(2),
      "Insufficent token balance to pay out"
    );

    if (playerBet[msg.sender].entry == 1 && SetWinner ==1) {
      playerBet[msg.sender].amountBet += pot;
      playerBet[msg.sender].collect = true;
      
    } else{
       playerBet[msg.sender].entry == 2 && SetWinner ==2;
       playerBet[msg.sender].amountBet += pot;
       playerBet[msg.sender].collect = true;
       
    }

    // added for sending 2*tokens to winner
    IERC20(tokenAddress).transfer(msg.sender, withdrawAmount.mul(2));

    emit PaymentSent(msg.sender, withdrawAmount.mul(2));
  }

  function withdrawTokens(uint _amount) public {
    require(playerBet[msg.sender].amountBet > 0, "You have nothing to withdraw");
    require(playerBet[msg.sender].entry == SetWinner, "You lost this one");
    require(playerBet[msg.sender].collect == true, "Please collect your winnings");
    _amount = (playerBet[msg.sender].amountBet);
    msg.sender.transfer(_amount);
  }

  //  function destroyContract() public onlyOwner {
      
      

      
  // }
}