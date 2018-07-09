pragma solidity ^0.4.20;
import "./Tool.sol";

contract VestingSchedule is Ownable , Status {

    // event addScheduleEvent(uint32 _maturePeriod, uint32 _scheduleLength, uint32 _matureLockupPeriod, uint32 _matureProportion);
    event addScheduleEvent(bytes32 _scheduleKey);
    event updateScheduleEvent(bytes32 _scheduleKey);
    event deleteScheduleEvent(bytes32 _scheduleKey);

    struct Schedule {
        // 成熟周期，单位月
        uint32 maturePeriod;
        // 成熟计划长度，单位月
        uint32 scheduleLength;
        // 成熟锁定期,单位月
        uint32 matureLockupPeriod;
        // 立即成熟比例
        uint32 matureProportion;
        // 使用次数
        uint32 useCount;
    }
    // 成熟计划mapping数据
    mapping (bytes32 => Schedule) scheduleList;

    // 添加成熟计划
    function addSchedule( uint32 _maturePeriod, uint32 _scheduleLength, uint32 _matureLockupPeriod, uint32 _matureProportion) 
        external 
        onlyOwner 
        checkStatus 
    {
        bytes32 scheduleKey = createSchedule(_maturePeriod, _scheduleLength, _matureLockupPeriod, _matureProportion);
        emit addScheduleEvent(scheduleKey);
        // emit addScheduleEvent(_maturePeriod, _scheduleLength, _matureLockupPeriod, _matureProportion);
    }

    //查看成熟计划详情
    function showSchedule( bytes32 _scheduleKey ) 
        external 
        view 
    returns (uint32, uint32, uint32, uint32) {
        require(hasSchedule(_scheduleKey));
        Schedule storage schedule = scheduleList[_scheduleKey];
        return (schedule.maturePeriod, schedule.scheduleLength, schedule.matureLockupPeriod, schedule.matureProportion);
    }

    //通过index验证是否有该成熟计划
    function hasSchedule ( bytes32 _scheduleKey ) 
        internal 
        view 
        returns (bool) 
    {
        if (scheduleList[_scheduleKey].maturePeriod != 0) {
            return true;
        } else {
            return false;
        }
    }

    //修改成熟计划
    //ESOP是否使用过该成熟计划
    function updateSchedule( 
        bytes32 _scheduleKey, uint32 _maturePeriod, uint32 _scheduleLength, 
        uint32 _matureLockupPeriod, uint32 _matureProportion
    ) 
        external 
        onlyOwner 
        checkStatus
    {
        require(hasSchedule(_scheduleKey));
        require(scheduleList[_scheduleKey].useCount == 0);
        delete scheduleList[_scheduleKey];
        bytes32 newScheduleKey = createSchedule(_maturePeriod, _scheduleLength, _matureLockupPeriod, _matureProportion);
        emit updateScheduleEvent(newScheduleKey);
    }

    //删除成熟计划
    function deleteSchedule( bytes32 _scheduleKey ) 
        external 
        onlyOwner 
        checkStatus
    {
        require(hasSchedule(_scheduleKey));
        require(scheduleList[_scheduleKey].useCount == 0);
        delete scheduleList[_scheduleKey];
        emit deleteScheduleEvent(_scheduleKey);
    }

    function createSchedule( uint32 _maturePeriod, uint32 _scheduleLength, uint32 _matureLockupPeriod, uint32 _matureProportion )
        internal
        returns (bytes32)
    {   
        require(_maturePeriod != 0);

        // 针对传入的数据进行判断

        require(_maturePeriod <= _scheduleLength);
        bytes32 scheduleKey = sha256(_maturePeriod, _scheduleLength, _matureLockupPeriod, _matureProportion);
        if (!hasSchedule(scheduleKey)) {
            scheduleList[scheduleKey] = Schedule({
                maturePeriod: _maturePeriod,
                scheduleLength: _scheduleLength,
                matureLockupPeriod: _matureLockupPeriod,
                matureProportion: _matureProportion,
                useCount: 0
            });
            return scheduleKey;
        }
    }
}