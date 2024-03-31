
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface Morpheus {
    function getFeed(
        uint256 feedID
    )
        external
        view
        returns (
            uint256 value,
            uint256 decimals,
            uint256 timestamp,
            string memory valStr
        );

    function requestFeeds(
        string[] calldata APIendpoint,
        string[] calldata APIendpointPath,
        uint256[] calldata decimals,
        uint256[] calldata bounties
    ) external payable returns (uint256[] memory feeds);
}


contract GAMBLEnWinAll {
    address public owner;
    uint256 public endTime;
    uint256 public poolAmount;
    address public winner;
    uint256 public entranceFee=0.01 ether;
    uint256 vrfID;
    Morpheus public morpheus;

    


 function requestNum() payable public {
        string[] memory apiEndpoint = new string[](1);
        apiEndpoint[0] = "vrf";
        string[] memory apiEndpointPath = new string[](1);
        apiEndpointPath[0] = "";
        uint256[] memory decimals = new uint256[](1);
        decimals[0] = 0;
        uint256[] memory bounties = new uint256[](1);
        bounties[0] = 0.0001 ether ;
        uint256[] memory feeds = morpheus.requestFeeds{value: 0.0001 ether }(
            apiEndpoint,
            apiEndpointPath,
            decimals,
            bounties
        );
    vrfID= feeds[0];
    }

     function getdata() public view returns (uint256 vrfValue) {
        ( vrfValue, , , ) = morpheus.getFeed(vrfID);
        return vrfValue;
    }

    mapping(address => uint256) public playerBalances;

    event WinnerSelected(address winner, uint256 amount);

    constructor(uint256 durationInSeconds) {
        owner = msg.sender;
        morpheus = Morpheus(0x0000000000071821e8033345A7Be174647bE0706);

        endTime = block.timestamp + durationInSeconds;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier onlyBeforeEndTime() {
        require(block.timestamp < endTime, "time has passed");
        _;
    }

    modifier onlyAfterEndTime() {
        require(block.timestamp >= endTime, "time has not passed yet");
        _;
    }

    function enterPool() external payable onlyBeforeEndTime {
        require(msg.value > entranceFee, "Value sent must be greater than 0");
        playerBalances[msg.sender] += msg.value;
        poolAmount += msg.value;
    }



    function selectWinner() external onlyOwner onlyAfterEndTime {
        require(poolAmount > 0, "No funds available to distribute");
        require(getdata()!=0);
        uint256 randomNumber = getdata();
        uint256 cumulativeAmount = 0;
        address currentWinner;
        for (uint256 i = 0; i < address(this).balance; i++) {
            cumulativeAmount += playerBalances[address(uint160(uint256(uint160(address(this)))))];
            if (cumulativeAmount >= randomNumber) {
                currentWinner = address(uint160(uint256(uint160(address(this))))); // Select winner
                break;
            }
        }

        winner = currentWinner;
        payable(winner).transfer(poolAmount);
        emit WinnerSelected(winner, poolAmount);
        poolAmount = 0;
    }

    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
