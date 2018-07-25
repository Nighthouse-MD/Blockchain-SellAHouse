pragma solidity ^0.4.24;

contract SellAHouse {
//
  struct House {
    bytes32 houseName;
    uint askingPrice;
    address owner;
    uint auctionEnd;
    bool auctionEnded;
    bool sold;
    address buyer;
  }

  struct Offer {
    address bidder;
    uint amount;
    uint validUntil;
    uint createdOn;
  }

  mapping(address => Offer) public highestOfferByBidder;

  House public house;
  Offer[] public offers;
  Offer public highestOffer;

  //This is the constructor, it is called once you deploy the contract
  constructor(bytes32 houseName, uint askingPrice, address owner, uint daysUntilEndOfAuction) public {
    //...
    house = House({
      houseName: houseName,
      askingPrice: askingPrice,
      owner: owner,
      auctionEnd: now + daysUntilEndOfAuction,
      auctionEnded: false,
      sold: false,
      buyer: 0
    });

    highestOffer = Offer({bidder: 0, amount:0, validUntil: now, createdOn: now});
  }

  //getHouseInfo

  function sellToHighestBidder() public {
    require(house.owner == msg.sender, "Only the owner can decide to sell the house!");
    require(highestOffer.amount > 0, "No valid bidding yet");
    house.sold = true;
    house.auctionEnded = true;
    house.buyer = highestOffer.bidder;
  }

  function getHighestOffer() public view returns (address, uint, uint) {
    require(house.owner == msg.sender, "Only the owner can view this info!");
    return (highestOffer.bidder, highestOffer.amount, highestOffer.validUntil);
  }

  function getHighestOfferAmount() public view returns (uint) {
    return highestOffer.amount;
  }

  // function getAllOffers() public view returns (Offer) {
  //   return highestOffer;//todo return json array
  // }

  //todo check validityInDays and 'now' type
  function makeAnOffer(uint amount, uint validityInDays) public {
    require(!house.auctionEnded, "The bidding has ended");
    require(!house.sold, "The house was sold");
    require(house.owner != msg.sender, "The owner cannot make an offer!");

    var highestOfferForBidder = highestOfferByBidder[msg.sender];
    require(amount > highestOfferForBidder.amount, "The offer should be higher than your last offer.");
    require(amount > highestOffer.amount, "The offer should be higher than the last offer");

    var newOffer = Offer({
      bidder: msg.sender,
      amount: amount,
      validUntil: now + validityInDays,
      createdOn: now
      });

    offers.push(newOffer);
    highestOffer = newOffer;

    highestOfferByBidder[msg.sender] = newOffer;

    if(amount >= house.askingPrice)
      sellToHighestBidder();
  }

  // Returns the total votes a candidate has received
  function totalOffersRecieved() view public returns (uint) {
    return offers.length;
  }

  //todo total unique bidders
}