pragma solidity >=0.4.0 <0.7.0;

interface ICommunity {
  function addTier(uint _threshold, uint _epochs, string calldata _name, string calldata _description) external {}
  function addContent(string calldata _tierName, string calldata _contentHash) external {}
  function cashOut(uint amount) external {}
  function getLiked(address liker) external {}
  function getUnliked(address unliker) external {}
  function getFollowed(address follower) external {}
  function getUnfollowed(address unfollower) external {}
}
