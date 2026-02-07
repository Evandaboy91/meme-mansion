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
