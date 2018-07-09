pragma solidity ^0.4.20;
import "./VestingSchedule.sol";
import "./ESOP.sol";

contract Vesting is ESOP, VestingSchedule {

    event getOptionCoinEvent(address, uint);

    struct VestingStruct {
        uint32 vestingDate;
        uint vestingAmount;
    }
    //查看某地址、某ESOP、某个时间点的成熟数量
    function showVestingDetailByDate ( address _issueAddress, bytes32 _issuekey, uint32 _date ) public view returns (uint32, uint) {
        require(hasIssue(_issueAddress, _issuekey));
        require(hasSchedule(issueList[_issueAddress][issuekey].scheduleKey));

        return calculateVesting();
    }
    //查看某个地址、某ESOP的成熟详情
    function showVestingDetail ( address _issueAddress, bytes32 _issuekey ) public view {
        require(hasIssue(_issueAddress, _issuekey));
        require(hasSchedule(issueList[_issueAddress][issuekey].scheduleKey));
        // return calculateVesting();
    }

    //查看某个地址、截止到某一时间点的成熟总数
    function showTotalVested ( address _issueAddress, bytes32 _issuekey, uint32 _date ) public view returns () {
        require(hasIssue(_issueAddress, _issuekey));
        require(hasSchedule(issueList[_issueAddress][_issuekey].scheduleKey));

        return calculateVesting();
    }

    // 公司设置员工是否可以提取OptionCoin
    function changeIssueStatus ( address _issueAddress, bytes32 _issuekey ) external checkStatus onlyOwner {
        require(issueList[_issueAddress][_issuekey].issueState == IssueState.Open);
        issueList[_issueAddress][_issuekey].issueState = IssueState.Close;
    }

    //issue address 根据成熟情况获取Option Coin
    function getVestedOptionCoin( address _issueAddress, bytes32 _issuekey, uint _amount ) public onlyOwner checkStatus {
        //数量是否超过已成熟数量、数量是否超过持有Option的数量
        require(_amount <= calculateVesting(_issuekey));
        require(issueList[_issueAddress][_issuekey].issueState == IssueState.Open);

        transfer(_issueAddress, _amount);

        emit getOptionCoinEvent(issueAddress, _amount);
    }

    //内部调用方法，计算成熟详情
    function calculateVesting ( bytes32 _issuekey, bytes32 _scheduleKey ) internal returns ( VestingStruct[] ) {
        VestingStruct[] VestingStructs;

        return VestingStructs;
    }

}