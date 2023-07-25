// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    //uint256 number = 1;
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 USERStartingBal = 10 ether;
    uint256 constant GASPRICE = 1;

    function setUp() external {
        //number = 2;
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, USERStartingBal);
    }

    function testMinimumDollarIsFive() public {
        //return (fundMe.MINIMUM_USD);
        //There is am error;
        assertEq(fundMe.MINIMUM_USD(), 5 * 1e18); // why add () fix the problem
    }

    //function testMinimumDollarIsFive2() public view returns (uint256) {
    //  return (fundMe.MINIMUM_USD());
    //}

    function testOwner() public {
        //console.log(fundMe.ownerAddress());
        //console.log(msg.sender);
        //console.log(address(this));
        //console.log(this);
        //assertEq(fundMe.ownerAddress(), address(this));
        assertEq(fundMe.getOwnerAddress(), msg.sender);
    }

    //function testMyValue() public {
    //  assertEq(fundMe.myvalue(), 1);
    //}

    function testPriceFeedVersionIsAccurate() public {
        //uint256 theversion = theversion.getversion();
        //uint256 theversion = fundMe.getTheDataFeedVersion();
        uint256 theversion = fundMe.getversion();
        console.log(theversion);

        assertEq(theversion, 4);
    }

    //function testDemo() public {
    //console.log(number);
    //console.log("Hello!");
    //console.log("Hi");
    //assertEq(number, 2);
    //}

    function testFundMeFailsWithoutEnoughETH() public {
        vm.expectRevert(); //hey, the next line shouldrevert! If the next line does not revert, the test will fail.
        fundMe.fund(); //this means 0 value
    }

    function testFundUpdateFundedDataStructure() public {
        vm.prank(USER); //The next TX will be sent by USER.
        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddresstoAmountFunded(address(USER));
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddFunderTOArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        //uint256 newFunderIndex = fundMe.s_funders.length;
        uint256 newFunderIndex = fundMe.getFunderLength() - 1;
        address newFunderAddress = fundMe.getFunder(newFunderIndex);
        assertEq(newFunderAddress, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyUserCanWithdraw() public funded {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testUserCanWithdraw() public funded {
        // vm.expectEmit();
        //fundMe.withdraw();
        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwnerAddress().balance;
        uint256 startingfundMeBalance = address(fundMe).balance;

        //Act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GASPRICE);
        vm.prank(fundMe.getOwnerAddress());
        fundMe.withdraw();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = tx.gasprice * (gasStart - gasEnd);
        console.log(gasUsed);
        //Assert
        uint256 endingOwnerBalance = fundMe.getOwnerAddress().balance;
        uint256 endingfundMeBalance = address(fundMe).balance;
        assertEq(
            endingOwnerBalance,
            startingfundMeBalance + startingOwnerBalance
        );
        assertEq(endingfundMeBalance, 0);
    }

    function testWithdrawFromMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        //console.log(address(1));
        //console.log(address(2));
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            //vm.prank();
            // vm.deal();
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwnerAddress().balance;
        uint256 startingfundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwnerAddress());
        fundMe.withdraw();
        vm.stopPrank;

        uint256 endingOwnerBalance = fundMe.getOwnerAddress().balance;
        uint256 endngfundMeBalance = address(fundMe).balance;

        assertEq(endngfundMeBalance, 0);
        assert(
            endingOwnerBalance == startingfundMeBalance + startingOwnerBalance
        );
    }

    function testWithdrawFromMultipleFundersCheaper() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        //console.log(address(1));
        //console.log(address(2));
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            //vm.prank();
            // vm.deal();
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwnerAddress().balance;
        uint256 startingfundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwnerAddress());
        fundMe.withdrawCheaper();
        vm.stopPrank;

        uint256 endingOwnerBalance = fundMe.getOwnerAddress().balance;
        uint256 endngfundMeBalance = address(fundMe).balance;

        assertEq(endngfundMeBalance, 0);
        assert(
            endingOwnerBalance == startingfundMeBalance + startingOwnerBalance
        );
    }
}
