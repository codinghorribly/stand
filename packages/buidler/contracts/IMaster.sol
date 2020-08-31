pragma solidity >=0.4.0 <0.7.0;

interface IMaster {
  enum Types {
    USER, //0
    COMMUNITY, //1
    DELETED //2
  }

  function getType(address _address) external view returns (Types) ;
  function createUser(string calldata name) external;
  function deleteUser(address user) external;
  function addCommunity(address root, address userContract, address communityContract) external;
  function removeCommunity(address root, address communityContract) external;
}
