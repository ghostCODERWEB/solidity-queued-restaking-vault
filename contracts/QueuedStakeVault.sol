// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {SuiteBase, AssetFlow} from "./SuiteBase.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title Slashable queued staking vault
/// @notice ERC20 staking shares with delayed withdrawal requests, pro-rata losses and bounded admin slashing.
/// @dev Reference implementation; independent audit required before production.

contract QueuedStakeVault is ERC20, SuiteBase {
    using SafeERC20 for IERC20;
    IERC20 public immutable token;
    uint64 public immutable exitDelay;
    uint16 public immutable maxSlashBps;
    uint256 public nextExit;
    struct Exit {
        address owner;
        uint256 shares;
        uint64 ready;
        bool completed;
    }
    mapping(uint256 => Exit) public exits;
    event Deposited(address indexed owner, uint256 assets, uint256 shares);
    event ExitRequested(
        uint256 indexed id,
        address indexed owner,
        uint256 shares,
        uint64 ready
    );
    event ExitCompleted(uint256 indexed id, uint256 assets);
    event Slashed(uint256 assets, address indexed recipient);
    constructor(
        address asset,
        uint64 delay,
        uint16 maxSlash,
        address admin
    ) ERC20("Queued Stake Share", "QSS") SuiteBase(admin) {
        require(
            asset.code.length > 0 &&
                delay > 0 &&
                maxSlash > 0 &&
                maxSlash <= 5000,
            "config"
        );
        token = IERC20(asset);
        exitDelay = delay;
        maxSlashBps = maxSlash;
    }
    function totalAssets() public view returns (uint256) {
        return token.balanceOf(address(this));
    }
    function previewRedeem(uint256 shares) public view returns (uint256) {
        return Math.mulDiv(shares, totalAssets() + 1, totalSupply() + 1000);
    }
    function deposit(
        uint256 amount,
        uint256 minShares
    ) external nonReentrant whenNotPaused returns (uint256 shares) {
        shares = Math.mulDiv(amount, totalSupply() + 1000, totalAssets() + 1);
        require(shares > 0 && shares >= minShares, "shares");
        AssetFlow.pullExact(token, msg.sender, amount);
        _mint(msg.sender, shares);
        emit Deposited(msg.sender, amount, shares);
    }
    function requestExit(
        uint256 shares
    ) external whenNotPaused returns (uint256 id) {
        require(shares > 0, "shares");
        _transfer(msg.sender, address(this), shares);
        id = ++nextExit;
        uint64 ready = uint64(block.timestamp) + exitDelay;
        exits[id] = Exit(msg.sender, shares, ready, false);
        emit ExitRequested(id, msg.sender, shares, ready);
    }
    function completeExit(uint256 id, uint256 minAssets) external nonReentrant {
        Exit storage e = exits[id];
        require(
            e.owner == msg.sender && !e.completed && block.timestamp >= e.ready,
            "exit"
        );
        uint256 amount = previewRedeem(e.shares);
        require(amount >= minAssets, "slippage");
        e.completed = true;
        _burn(address(this), e.shares);
        token.safeTransfer(msg.sender, amount);
        emit ExitCompleted(id, amount);
    }
    function slash(
        uint256 bps,
        address recipient
    ) external onlyOwner nonReentrant {
        require(
            bps > 0 &&
                bps <= maxSlashBps &&
                recipient != address(0) &&
                recipient != address(this),
            "slash"
        );
        uint256 amount = Math.mulDiv(totalAssets(), bps, 10000);
        require(amount > 0, "dust");
        token.safeTransfer(recipient, amount);
        emit Slashed(amount, recipient);
    }
}
