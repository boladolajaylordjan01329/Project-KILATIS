// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract KilatisProcure {
    
    // --- DATA STRUCTURES ---
    struct Bid {
        uint bidId;
        string contractorName;
        string documentHash; // SHA-256 of the PDF file
        uint timestamp;
    }

    // --- STATE VARIABLES ---
    address public dbmAdmin;
    uint public biddingDeadline;
    Bid[] public bidLedger; // The Immutable Ledger

    // --- EVENTS (For Audit Trail) ---
    event NewBidSubmitted(uint id, string name, uint time);
    event BiddingClosed(uint time);

    // --- CONSTRUCTOR ---
    // Sets the duration of bidding in minutes
    constructor(uint _minutesDuration) {
        dbmAdmin = msg.sender;
        biddingDeadline = block.timestamp + (_minutesDuration * 1 minutes);
    }

    // --- MODIFIER (The Anti-Corruption Logic) ---
    // This code automatically rejects late bids
    modifier onlyBeforeDeadline() {
        require(block.timestamp < biddingDeadline, "KILATIS ERROR: Bidding period has ended.");
        _;
    }

    // --- FUNCTION: SUBMIT BID ---
    function submitBid(string memory _name, string memory _hash) public onlyBeforeDeadline {
        bidLedger.push(Bid(
            bidLedger.length + 1,
            _name,
            _hash,
            block.timestamp
        ));
        emit NewBidSubmitted(bidLedger.length, _name, block.timestamp);
    }
}
