pragma solidity >=0.4.0 <0.7.0;

interface IMaster {
  enum Types {
    USER,
    COMMUNITY,
    DELETED
  }

  function getType(address _address) external {}
  function createUser(string calldata name) external {}
  function deleteUser(address user) external {}
  function addCommunity(address root, address userContract, address communityContract) external {}
  function removeCommunity(address root, address communityContract) external {}
}
