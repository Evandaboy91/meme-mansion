// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Meme Mansion
/// @notice Chamber IDs are sequential. Gallery locks until block LOCK_AFTER_BLOCK; treasury withdraws after that.
contract MemeMansion {
    event ChamberEntered(address indexed who, uint256 indexed chamberId, uint256 paidWei);
    event GalleryFundsWithdrawn(address indexed to, uint256 amountWei);

