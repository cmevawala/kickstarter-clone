// contracts/SpaceCoin.sol
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

enum Phase {
    Seed,
    General,
    Open
}

contract SpaceCoin is ERC20, Ownable {

    bool private _transferTax = false;
    bool private _pause = false;
    
    uint phaseLimit = 1500 ether;
    uint contributionLimit = 150 ether;

    Phase _phase = Phase.Seed;

    mapping(address => uint) private _whiteListedAddress;


    // Emit events at last

    modifier isWhitelisted() {
        
        if (_phase == Phase.Seed) {
            require(_whiteListedAddress[msg.sender] > 0, 'Error: Address not in whitelist');
        }
        _;
    }

    modifier underLimit() {
        require(msg.value <= contributionLimit, 'Error: More than contribution limit');
        require(getBalance() <= phaseLimit, 'Error: Phase limit over');
        _;
    }


    constructor(uint initialSupply) ERC20("SpaceCoin", "WSPC") {
        _mint(msg.sender, initialSupply);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function getPhase() public view returns (Phase) {
        return _phase;
    }

    function setPhase(Phase phase) external onlyOwner {
        _phase = phase;

        // console.log(_phase);

        phaseLimit = 3000;
        contributionLimit = 100;
    }

    function chargeTax() external onlyOwner {
        _transferTax = !_transferTax;
    }

    function addWhitelisted(address _address) external onlyOwner {
        _whiteListedAddress[_address]++;
    }

    function contribute() public payable isWhitelisted underLimit {
    }

}
