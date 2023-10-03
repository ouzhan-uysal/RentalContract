// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

// Only a 1-year lease agreement can be made in this smart contract.

contract RentalContract {
    address private immutable owner;
    uint128 private immutable oneYear = 31556926;

    struct RentalPropertyInfo {
        address tenant; // kiraci
        address payable lessor; // mülk sahibi
        string propertyType; // mülk tipi, ev veya dükkan
        string propertyLocation; // mülkün konumu
        uint256 rentPrice; // kira ücreti
        uint256 endDate; // kira bitiş tarihi (timestamp)
        uint256 startDate; // kira başlangıç tarihi (timestamp)
    }
    uint256 private count = 0; // total ilan sayısı

    mapping(uint256 => RentalPropertyInfo) public realEstate; // açılan tüm ilanlar

    constructor() {
        owner = msg.sender;
    }

    modifier isLessor(address _lessor) {
        require(msg.sender == _lessor, "Only Lessor!");
        _;
    }

    modifier isTenant(address _tenant) {
        require(msg.sender == _tenant, "Only Tenant!");
        _;
    }

    // kiracisi yoksa
    modifier hasntTenant(address _tenant) {
        require(
            _tenant == 0x0000000000000000000000000000000000000000,
            "Already rented!"
        );
        _;
    }

    function ilanVer(
        string memory _propertyType,
        string memory _propertyLocation,
        uint256 _rentPrice
    ) public {
        realEstate[count] = RentalPropertyInfo({
            tenant: 0x0000000000000000000000000000000000000000,
            lessor: payable(msg.sender),
            propertyType: _propertyType,
            propertyLocation: _propertyLocation,
            rentPrice: _rentPrice,
            endDate: 0,
            startDate: 0
        });
    }

    function tumIlanlar() public view returns (RentalPropertyInfo[] memory) {
        RentalPropertyInfo[] memory result = new RentalPropertyInfo[](count);

        for (uint256 i = 0; i < count; i++) {
            result[i] = realEstate[i];
        }

        return result;
    }

    function kirala(
        uint256 _index
    ) public hasntTenant(realEstate[_index].tenant) {
        realEstate[_index].tenant = msg.sender;
        realEstate[_index].startDate = block.timestamp;
        realEstate[_index].endDate = block.timestamp + oneYear;
    }

    function kiralamayiSonlandir(
        uint256 _index
    ) public isTenant(realEstate[_index].tenant) {
        realEstate[_index].tenant = 0x0000000000000000000000000000000000000000;
        realEstate[_index].startDate = 0;
        realEstate[_index].endDate = 0;
    }
}
