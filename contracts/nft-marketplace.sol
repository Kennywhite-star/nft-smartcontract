// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

//INTERNAL  IMPORT NFT FROM OPENZEPPELLENE
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol"; 

import "hardhat/console.sol";

contract NFTMarketplace is ERC721URIStorage {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;
    Counters.Counter private _itemsSold;

    uint256 listingPrice = 0.0025 ether;

    address payable owner;

    mapping(uint256 =>  MarketItem) private idMarketItem;

    struct MarketItem{
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    event idMarketItemCreated(
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold

    ) ;

    modifier onlyOwner{
        //setting condition for only owner
        require(msg.sender == owner,
          "only owner of the marketplace can change the listing price"
          );
          _;
    }

//provide name and symbol for my nft
    constructor () ERC721("NFT Metaverse Token", "MYNFT"){
        //whoever deploy the message is the owner
        owner == payable(msg.sender);
    } 
      
      //let peple knw my price
    function updateListingPrice(uint256 _listingPrice) public payable onlyOwner
     {
        //only owner can update the pricing of the listing
        listingPrice = _listingPrice;
    }

    //allow anybody to fetch listing price and knw the amount they want to pay
    function getListingPrice() public view returns (uint256){
        return listingPrice;
    }

    //CREATING NFT TOKENN FUNTION
    function createToken(string memory tokenURL, uint256 price) public payable returns(uint256) {
        //increament the token id when  will get new id
        _tokenIds.increment();
        //get the current id/ which is going to be cces the new nft
        uint256 newTokenId = _tokenIds.current();

        //mint from  openze
        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURL);

        createMarketItem(newTokenId, price);

        return newTokenId;     

    }
  
  //Creating Market Items
    function createMarketItem(uint256 tokenId, uint256 price) private {
        require(price > 0, "price must be at least 1");
        require( msg.value == listingPrice, "price mmst be equal to listing price");
        //nft  features
        //the token id contain abt te  entire info of the nft
        idMarketItem[tokenId] = MarketItem(
            tokenId,
            payable(msg.sender),
            payable(address(this)),
            price,
            false
        ); 

        //transfer the fnction from the one wh created te nft to the contract
        _transfer(msg.sender, address(this), tokenId);
        //call tte event

        emit idMarketItemCreated(
            tokenId,
            msg.sender,
            address(this),
            price,
            false
        );
        
       }

        //FUNCTIN FOR RESAL TOKEN
        function reSellToken(uint256 tokenId, uint256 price) public payable {
            //check for conditions
            //check the token idd if is the same with the caller... then make the sales jappe.
            require(idMarketItem[tokenId].owner ==msg.sender,
             "only  item owner can perform this resale perations");

             require(msg.value == listingPrice, "price must be equal to list price");

             idMarketItem[tokenId].sold = false;
             idMarketItem[tokenId].price = price;
             idMarketItem[tokenId].seller = payable(msg.sender);
             idMarketItem[tokenId].owner = payable(address(this));

              _itemsSold.decrement();

              _transfer(msg.sender, address(this), tokenId);
  
        }

        //FUNCTION CREATEMARKETSALE

        function createMarketSale(uint256 tokenId) public payable {
            uint256 price =  idMarketItem[tokenId].price; 

            require(msg.value == price, 
            "please submit te asking price to complete the purchase"
            );

//whoever is calling the funcyin will become the owner once he made the payment
//updating data and making changes
            idMarketItem[tokenId].owner = payable(msg.sender);
             idMarketItem[tokenId].sold = true;
              idMarketItem[tokenId].owner = payable(address(0 ));

              _itemsSold.increment();

              _transfer(address(this),msg.sender,tokenId);

              payable(owner).transfer(listingPrice); 
              payable(idMarketItem[tokenId].seller).transfer(msg.value); 


        } 

        //GETTING UNSOLD NFT DATA
        function fetchMarketItem() public view returns(MarketItem[] memory){
         uint256 itemCount =  _tokenIds.current();
         uint256 unSoldItemCount =  _tokenIds.current() - _itemsSold.current();
         uint256 currentIndex = 0;
         //loop over the nft

         MarketItem[] memory Items = new MarketItem[](unSoldItemCount);
         for (uint256 i = 0; i < itemCount; i++){
            if(idMarketItem[i +1].owner == address(this)) {
                uint256 currentid = i + 1;

                MarketItem storage currentItem = idMarketItem[currentid];
                Items[currentIndex] = currentItem;
                currentIndex += 1;        

            }
         } 
         return Items;
        }

         //purchase item
         function fetchMyNFT() public view returns (MarketItem[] memory){
            uint256 totalCount =  _tokenIds.current();
            uint256 itemCount = 0;
            uint256 currentIndex = 0;

            //frst statement

            for (uint256 i = 0; i < totalCount; i++){
                 if(idMarketItem[i +1].owner == msg.sender) {
                    itemCount +=1;
                 }
         }

         MarketItem[] memory Items = new MarketItem[](itemCount);
          for (uint256 i = 0; i < totalCount; i++){

            if(idMarketItem[i + 1].owner == msg.sender){
             uint256 currentid = i + 1;
                MarketItem storage currentItem = idMarketItem[currentid];
                Items[currentIndex] = currentItem;
                currentIndex += 1; 
                 }
          }    
        
        return Items;

        }

        //single user items
        function fetchItemsListed() public view returns  (MarketItem[] memory){
            uint256 totalCount = _tokenIds.current();
            uint256 itemCount = 0;
            uint256 currentIndex = 0;

            for (uint256 i = 0; i < totalCount; i++){

            if(idMarketItem[i + 1].seller == msg.sender){
             itemCount += 1;
            }
            }

            MarketItem[] memory Items = new MarketItem[](itemCount);
            for (uint256 i = 0; i < totalCount; i++){
            if(idMarketItem[i + 1].seller == msg.sender){
             uint256 currentid = i + 1;
                MarketItem storage currentItem = idMarketItem[currentid];
                Items[currentIndex] = currentItem;
                currentIndex += 1;     
                 }
        }
        return Items;
            }

 


        }

