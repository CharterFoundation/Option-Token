pragma solidity ^0.4.20;
import "./Tool.sol";
import "./ERC20OptionToken.sol";

contract ESOP{
    event issueEvent(bytes32 issueKey);

    // 授予记录数据
    enum IssueState { Close, Open }
    struct IssueStruct {
        //授予数量
        uint issueAmount;
        //行权单价
        uint32 exercisePrice;
        //授予日期
        uint32 issueDate;
        //成熟计划
        bytes32 scheduleKey;
        //成熟期算日
        uint32 vestingStartDate;
        //状态
        IssueState issueState;
        // 每个证书领取Option的数量
        uint receiveAmount;
        // 数据上链的时间
        uint32 createDate;
    }

    mapping (address => mapping (bytes32 => IssueStruct)) public issueList;

    // 授予
    function issue (
        address _issueAddress, uint _issueAmount, uint32 _exercisePrice,
        uint32 _issueDate, bytes32 _schedulekey, uint32 _vestingStartDate
    ) 
        external 
        checkStatus 
        onlyOwner 
    {
        require(_issueAddress != 0x0);
        require(_issueAmount < getAmount());

        bytes32 issueKey = sha256(_issueAddress, _issueAmount, _exercisePrice, _issueDate, _schedulekey, _vestingStartDate, block.timestamp);
        // 授予
        issueList[_issueAddress][issueKey] = IssueStruct({
            issueAmount: _issueAmount,
            exercisePrice: _exercisePrice,
            issueDate: _issueDate,
            scheduleKey: _schedulekey,
            vestingStartDate: _vestingStartDate,
            issueState: IssueState.Open,
            receiveAmount: 0,
            createDate: block.timestamp
        });
        scheduleList[_schedulekey].count += 1;

        emit issueEvent(issueKey);
    }

    // 根据address、key 查看授予详情
    function showIssueDetail ( address _issueAddress, bytes32 _issueKey ) 
        public 
        view 
        returns ( uint, uint32, uint32, bytes32, uint32 ) 
    {
        require(hasIssue(_issueAddress, _issueKey));
        IssueStruct storage issueDetail = issueList[_issueAddress][_issueKey];
        return ( 
            issueDetail.issueAmount, issueDetail.exercisePrice, issueDetail.issueDate, 
            issueDetail.scheduleKey, issueDetail.vestingStartDate
        );
    }

    // 通过address 和 key 判断是否有该授予纪录
    function hasIssue ( address _issueAddress, bytes32 _issueKey )
        internal 
        view 
        returns (bool) 
    {
        if (issueList[_issueAddress][_issueKey].issueAmount != 0) {
            return true;
        } else {
            return false;
        }
    }

    // 获取期权池剩余Option数
    function getAmount () 
        internal 
        view
        returns ( uint )
    {   
        uint issuedAmount = 1000;
        require(issuedAmount < initialSupply);
        return initialSupply - issuedAmount;
    }

    // 获取ESOP授予总数
    function getTotalIssueAmount() external view {}
    // 获取ESOP已领取Option总数
    function getTotalOptionAmount() external view {}
    // 获取ESOP授予总次数
    function getTotalIssueCount() external view {}
    // 获取ESOP授予人数
    function getTotalIssueMemberCount() external view {}
    
    // 查看某地址授予总数
    function getAddressIssueAmount() external view {}
    // 查看某地址已领取Option总数
    function getAddressOptionAmount() external view {}
}
