# ABI reference

Generated from the successfully compiled primary contract. Includes inherited methods. Authorization and economic semantics are documented in the source.

| Signature | Type | Mutability | Returns |
|---|---|---|---|
| `constructor(address asset,uint64 delay,uint16 maxSlash,address admin)` | constructor | nonpayable |  |
| `ERC20InsufficientAllowance(address spender,uint256 allowance,uint256 needed)` | error |  |  |
| `ERC20InsufficientBalance(address sender,uint256 balance,uint256 needed)` | error |  |  |
| `ERC20InvalidApprover(address approver)` | error |  |  |
| `ERC20InvalidReceiver(address receiver)` | error |  |  |
| `ERC20InvalidSender(address sender)` | error |  |  |
| `ERC20InvalidSpender(address spender)` | error |  |  |
| `EnforcedPause()` | error |  |  |
| `ExpectedPause()` | error |  |  |
| `OwnableInvalidOwner(address owner)` | error |  |  |
| `OwnableUnauthorizedAccount(address account)` | error |  |  |
| `ReentrancyGuardReentrantCall()` | error |  |  |
| `SafeERC20FailedOperation(address token)` | error |  |  |
| `Approval(address owner,address spender,uint256 value)` | event |  |  |
| `Deposited(address owner,uint256 assets,uint256 shares)` | event |  |  |
| `ExitCompleted(uint256 id,uint256 assets)` | event |  |  |
| `ExitRequested(uint256 id,address owner,uint256 shares,uint64 ready)` | event |  |  |
| `OwnershipTransferStarted(address previousOwner,address newOwner)` | event |  |  |
| `OwnershipTransferred(address previousOwner,address newOwner)` | event |  |  |
| `Paused(address account)` | event |  |  |
| `Slashed(uint256 assets,address recipient)` | event |  |  |
| `Transfer(address from,address to,uint256 value)` | event |  |  |
| `Unpaused(address account)` | event |  |  |
| `acceptOwnership()` | function | nonpayable |  |
| `allowance(address owner,address spender)` | function | view | uint256  |
| `approve(address spender,uint256 value)` | function | nonpayable | bool  |
| `balanceOf(address account)` | function | view | uint256  |
| `completeExit(uint256 id,uint256 minAssets)` | function | nonpayable |  |
| `decimals()` | function | view | uint8  |
| `deposit(uint256 amount,uint256 minShares)` | function | nonpayable | uint256 shares |
| `exitDelay()` | function | view | uint64  |
| `exits(uint256 )` | function | view | address owner, uint256 shares, uint64 ready, bool completed |
| `maxSlashBps()` | function | view | uint16  |
| `name()` | function | view | string  |
| `nextExit()` | function | view | uint256  |
| `owner()` | function | view | address  |
| `paused()` | function | view | bool  |
| `pendingOwner()` | function | view | address  |
| `previewRedeem(uint256 shares)` | function | view | uint256  |
| `renounceOwnership()` | function | nonpayable |  |
| `requestExit(uint256 shares)` | function | nonpayable | uint256 id |
| `setPaused(bool value)` | function | nonpayable |  |
| `slash(uint256 bps,address recipient)` | function | nonpayable |  |
| `symbol()` | function | view | string  |
| `token()` | function | view | address  |
| `totalAssets()` | function | view | uint256  |
| `totalSupply()` | function | view | uint256  |
| `transfer(address to,uint256 value)` | function | nonpayable | bool  |
| `transferFrom(address from,address to,uint256 value)` | function | nonpayable | bool  |
| `transferOwnership(address newOwner)` | function | nonpayable |  |
