// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/HoneypotBehaviorTrap.sol";

contract HoneypotBehaviorTrapTest is Test {
    HoneypotBehaviorTrap trap;

    function setUp() public {
        // window=4, minAvgBuy=100, maxAvgSell=10, ratioPct=400 (4x imbalance)
        trap = new HoneypotBehaviorTrap(4, 100, 10, 400);
    }

    function testZeroSellsTriggers() public {
        uint256[] memory buys = new uint256[](4);
        uint256[] memory sells = new uint256[](4);

        buys[0] = 200; buys[1] = 300; buys[2] = 250; buys[3] = 220;
        sells[0] = 0;  sells[1] = 0;   sells[2] = 0;   sells[3] = 0;

        assertTrue(trap.shouldRespond(buys, sells), "zero sells with strong buys = honeypot");
    }

    function testNormalMarketDoesNotTrigger() public {
        uint256[] memory buys = new uint256[](4);
        uint256[] memory sells = new uint256[](4);

        buys[0] = 200; buys[1] = 210; buys[2] = 220; buys[3] = 230;
        sells[0] = 180; sells[1] = 170; sells[2] = 160; sells[3] = 190;

        assertFalse(trap.shouldRespond(buys, sells), "normal sell activity should not trigger");
    }

    function testNotEnoughSamples() public {
        uint256[] memory buys = new uint256[](3);
        uint256[] memory sells = new uint256[](3);

        buys[0] = 200; buys[1] = 300; buys[2] = 250;
        sells[0] = 0;  sells[1] = 0;   sells[2] = 0;

        assertFalse(trap.shouldRespond(buys, sells), "requires at least window length samples");
    }

    function testRatioThreshold() public {
        uint256[] memory buys = new uint256[](4);
        uint256[] memory sells = new uint256[](4);

        buys[0] = 100; buys[1] = 120; buys[2] = 140; buys[3] = 160; // avg=130
        sells[0] = 10; sells[1] = 10;  sells[2] = 10;  sells[3] = 10;  // avg=10

        assertTrue(trap.shouldRespond(buys, sells), "high buy/sell ratio should trigger");
    }
}
