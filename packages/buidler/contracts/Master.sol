pragma solidity >=0.4.0 <0.7.0;

import "./IMaster.sol";
import "./User.sol";
import "./Community.sol";

contract Master is IMaster {
  address[] public users;
  address[] public communitiesAndProjects;

  enum Types {
    USER,
    COMMUNITY,
    DELETED
  }

  mapping (address => Types) typeOf;

  event Created(address contractAddress, uint time);
  event UserCreated(address root, address user, string name, uint time);
  event UserRemoved(address user, uint time);
  event CommProjCreated(address user, address community, uint time);
  event CommProjRemoved(address community, uint time);

  modifier onlyUser() {
    require(
        typeOf[msg.sender] == Types.USER,
        "only user accounts may perform this action"
    );
    _;
  }

  modifier onlyActive() {
    require(
      typeOf[msg.sender] == Types.USER || typeOf[msg.sender] == Types.COMMUNITY,
      "only members of the platform may perform this action"
    );
    _;
  }

  constructor() public {
    emit Created(address(this), now);
  }

  function getType(address _address) public view {
    return typeOf[_address];
  }

  function createUser(string memory name) public {
    address userContract = new User(msg.sender, name);
    users.push(userContract);
    typeOf[userContract] = Types.USER;

    emit UserCreated(msg.sender, userContract, name, now);
  }

  function deleteUser(address user) public {
    require(msg.sender == user);
    user.pop(user);
    typeOf.user = Types.DELETED;

    emit UserRemoved(user, now);
  }

  function addCommunity(address root, address userContract, address communityContract) public onlyUser {
    require(
      userContract == msg.sender,
      "unauthorized contract call"
    );
    require(
      // psuedocode userContract.root == root
    );

    communitiesAndProjects.push(communityContract);
    typeOf[communityContract] = Types.COMMUNITY;

    emit CommProjCreated(msg.sender, communityContract, now);
  }

  function removeCommunity(address root, address communityContract) public onlyUser {
    require(
      communityContract == msg.sender,
      "unauthorized contract call"
    );
    require(
      // psuedocode userContract.root == root
    );

    communitiesAndProjects.pop(communityContract);
    typeOf[communityContract] =  Types.DELETED;

    emit CommProjRemoved(msg.sender, now);
  }

}
