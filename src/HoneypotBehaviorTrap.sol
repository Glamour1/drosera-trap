// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title HoneypotBehaviorTrap
/// @notice Detects honeypot-like behavior: sustained buys with suppressed sells.
contract HoneypotBehaviorTrap {
    uint256 public immutable window;
    uint256 public immutable minAvgBuy;
    uint256 public immutable maxAvgSell;
    uint256 public immutable ratioPct;

    constructor(
        uint256 _window,
        uint256 _minAvgBuy,
        uint256 _maxAvgSell,
        uint256 _ratioPct
    ) {
        require(_window >= 1, "window >= 1");
        require(_ratioPct >= 100, "ratioPct >= 100");
        window = _window;
        minAvgBuy = _minAvgBuy;
        maxAvgSell = _maxAvgSell;
        ratioPct = _ratioPct;
    }

    function shouldRespond(
        uint256[] memory buyVolume,
        uint256[] memory sellVolume
    ) public view returns (bool) {
        uint256 n = buyVolume.length;
        if (n == 0 || n != sellVolume.length) return false;
        if (n < window) return false;

        uint256 start = n - window;
        uint256 sumBuy = 0;
        uint256 sumSell = 0;

        for (uint256 i = start; i < n; ++i) {
            sumBuy += buyVolume[i];
            sumSell += sellVolume[i];
        }

        uint256 avgBuy = sumBuy / window;
        uint256 avgSell = sumSell / window;

        if (avgBuy < minAvgBuy) return false;
        if (avgSell > maxAvgSell) return false;

        if (avgBuy * 100 >= (avgSell + 1) * ratioPct) {
            return true;
        }

        return false;
    }
}
