// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import 'taal-swap-lib/contracts/token/ERC20/IERC20.sol';
//import 'taal-swap-lib/contracts/token/ERC20/SafeERC20.sol';
import "./libs/TransferHelper.sol";

contract WTAL is Ownable {
    using SafeMath for uint256;

    event  Deposit(uint256 _amount);
    event  Withdraw(uint256 _amount);
    event  WithdrawAll(uint256 _amount);
    event  SetBridge(address indexed _bridge);

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

    function deposit(uint _amount) public limitedAccess {
        require(_amount > 0, "amount must be greater than 0");
        require(IERC20(TAL).balanceOf(msg.sender) >= _amount, "insufficient TAL balance");
        TransferHelper.safeTransferFrom(TAL, address(msg.sender), address(this), _amount);
        emit Deposit(_amount);
    }

    function withdraw(uint _amount) public limitedAccess {
        require(_amount > 0, "amount must be greater than 0");
        TransferHelper.safeTransfer(TAL, msg.sender, _amount);
        emit Withdraw(_amount);
    }

    function withdrawAll() public onlyOwner {
        uint256 _amount = IERC20(TAL).balanceOf(address(this));
        TransferHelper.safeTransfer(TAL, msg.sender, _amount);
        emit WithdrawAll(_amount);
    }

    function setBridge(address _bridge) public onlyOwner {
        bridgeContract = _bridge;
        emit SetBridge(_bridge);
    }
}
