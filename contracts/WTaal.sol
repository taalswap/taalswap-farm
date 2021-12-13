// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import 'taal-swap-lib/contracts/token/ERC20/IERC20.sol';
import 'taal-swap-lib/contracts/token/ERC20/SafeERC20.sol';
import "./libs/TransferHelper.sol";

contract WTAL is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    event  Deposit(uint _amount);
    event  Withdraw(uint _amount);
    event  WithdrawAll(uint _amount);
    event  SetBridge(address indexed _oldBridge, address indexed _bridge);

    address public immutable TAL;
    address public bridgeContract;

    modifier limitedAccess() {
        require(owner() == _msgSender() || _msgSender() == bridgeContract,
            'WTAL: only limited access allowed');
        _;
    }

    constructor(address _taal) public {
        TAL = _taal;
    }

    function deposit(uint _amount) public limitedAccess returns(bool) {
        require(_amount > 0, "amount must be greater than 0");
        require(IERC20(TAL).balanceOf(msg.sender) >= _amount, "insufficient TAL balance");
//        TransferHelper.safeTransferFrom(TAL, msg.sender, address(this), _amount);
        IERC20(TAL).safeTransferFrom(msg.sender, address(this), _amount);
        emit Deposit(_amount);
        return true;
    }

    function withdraw(uint _amount) public limitedAccess returns(bool) {
        require(_amount > 0, "amount must be greater than 0");
        require(IERC20(TAL).balanceOf(address(this)) >= _amount, "insufficient TAL balance");
//        TransferHelper.safeTransferFrom(TAL, address(this), msg.sender, _amount);
        IERC20(TAL).safeTransfer(address(this), _amount);
        emit Withdraw(_amount);
        return true;
    }

    function withdrawAll() public onlyOwner {
        uint256 _amount = IERC20(TAL).balanceOf(address(this));
        require(_amount > 0, "no TAL balance");
//        TransferHelper.safeTransferFrom(TAL, address(this), msg.sender, _amount);
        IERC20(TAL).safeTransfer(address(this), _amount);
        emit WithdrawAll(_amount);
    }

    function setBridge(address _bridge) public onlyOwner {
        require(address(_bridge) != address(0), "Invalid bridge contract address");
        address _oldBridge = bridgeContract;
        if (bridgeContract != address(0)) {
            IERC20(TAL).approve(bridgeContract, 0);
        }
        bridgeContract = _bridge;
        IERC20(TAL).approve(bridgeContract, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        emit SetBridge(_oldBridge, _bridge);
    }
}
