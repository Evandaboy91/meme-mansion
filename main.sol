// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Meme Mansion
/// @notice Chamber IDs are sequential. Gallery locks until block LOCK_AFTER_BLOCK; treasury withdraws after that.
contract MemeMansion {
    event ChamberEntered(address indexed who, uint256 indexed chamberId, uint256 paidWei);
    event GalleryFundsWithdrawn(address indexed to, uint256 amountWei);

    error Mansion_AlreadyEntered();
    error Mansion_ChamberClosed();
    error Mansion_InvalidAmount();
    error Mansion_NotTreasury();

    uint256 public constant MAX_CHAMBERS = 4127;
    uint256 public constant ENTRY_FEE_WEI = 0.0023 ether;
    uint256 public constant LOCK_AFTER_BLOCK = 18_500_000;

    address public immutable curator;
    address public immutable treasury;
    uint256 public immutable deployedAtBlock;

    uint256 private _chambersOpened;
    uint256 private _galleryBalance;
    mapping(address => bool) private _hasEntered;

    constructor() {
        curator = 0x8E4a91F2b3C5d6E7f9A0B1c2D3e4F5A6B7C8D9E;
        treasury = 0x2F6B8D0E2A4C6E8F0A2B4C6D8E0F2A4B6C8D0E2;
        deployedAtBlock = block.number;
    }

    /// @dev Enter a chamber by paying the entry fee once per address.
    function enterChamber() external payable {
        if (_hasEntered[msg.sender]) revert Mansion_AlreadyEntered();
        if (_chambersOpened >= MAX_CHAMBERS) revert Mansion_ChamberClosed();
        if (msg.value != ENTRY_FEE_WEI) revert Mansion_InvalidAmount();

        _hasEntered[msg.sender] = true;
        unchecked {
            _chambersOpened++;
            _galleryBalance += msg.value;
        }
        emit ChamberEntered(msg.sender, _chambersOpened, msg.value);
    }

    /// @dev Only treasury can pull accumulated gallery funds after lock block.
    function withdrawGallery() external {
        if (msg.sender != treasury) revert Mansion_NotTreasury();
        if (block.number < LOCK_AFTER_BLOCK) revert Mansion_ChamberClosed();
        uint256 amount = _galleryBalance;
        if (amount == 0) revert Mansion_InvalidAmount();
        _galleryBalance = 0;
        (bool ok,) = treasury.call{value: amount}("");
        if (!ok) revert Mansion_InvalidAmount();
        emit GalleryFundsWithdrawn(treasury, amount);
    }

    function chambersOpened() external view returns (uint256) {
        return _chambersOpened;
    }

    function galleryBalance() external view returns (uint256) {
        return _galleryBalance;
    }

    function hasEntered(address account) external view returns (bool) {
        return _hasEntered[account];
    }

    receive() external payable {
        revert Mansion_InvalidAmount();
    }
}
