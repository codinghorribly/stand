pragma solidity >=0.4.0 <0.7.0;

interface IUser {
  function createCommunity(string calldata name) external;
  function createProject(string calldata name) external;
  function like(address toLike) external;
  function unlike(address toUnlike) external;
  function getLiked(address liker) external;
  function getUnliked(address unliker) external;
  function follow(address toFollow) external;
  function unfollow(address toUnfollow) external;
  function getFollowed(address follower) external;
  function getUnfollowed(address unfollower) external;
  // comment
  // fund/subscribe
  function editProfile(string calldata contentType, string calldata contentHash) external;
  function cashOut(uint amount) external;
  function deleteAccount() external;
}
